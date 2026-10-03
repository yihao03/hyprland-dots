local M = {}

-- Cached "are we inside an active uwsm session?" check (resolved once at
-- config load; uwsm presence can't change without a relogin).
local _under_uwsm = nil
local function _check(cmd)
	local handle = io.popen(cmd .. " >/dev/null 2>&1; echo -n $?")
	if not handle then return false end
	local out = handle:read("*a")
	handle:close()
	return out == "0"
end

function M.under_uwsm()
	if _under_uwsm == nil then _under_uwsm = _check("uwsm check is-active") end
	return _under_uwsm
end

-- Prefix interactive app launches with runapp (or `uwsm app` as fallback)
-- when running inside an active uwsm session, so each app gets its own
-- systemd scope instead of piling into the compositor's unit.
-- See https://github.com/c4rlo/runapp.
local _scoped_prefix = nil

local function scoped_prefix()
	if _scoped_prefix == nil then
		if M.under_uwsm() then
			if _check("command -v runapp") then
				_scoped_prefix = "runapp "
			elseif _check("command -v uwsm") then
				_scoped_prefix = "uwsm app -- "
			else
				_scoped_prefix = ""
			end
		else
			_scoped_prefix = ""
		end
	end
	return _scoped_prefix
end

-- Raw prefixed command string, for autostart entries that need Hypr exec
-- opts (workspace, monitor, ...) which launch_app() can't carry.
function M.scoped_cmd(cmd) return scoped_prefix() .. cmd end

function M.launch_app(cmd) return hl.dsp.exec_cmd(scoped_prefix() .. cmd) end

M.lt = function(a, b) return a < b end
M.gt = function(a, b) return a > b end

local timeout = require("config.constants").timeout

local function get_active_tiled_workspace() return hl.get_active_special_workspace() or hl.get_active_workspace() end

-- Select an action at keypress time so each workspace can use its own layout.
function M.layout_binding(actions)
	return function()
		local workspace = get_active_tiled_workspace()
		if not workspace then
			hl.dispatch(hl.dsp.pass())
			return
		end

		local action = actions[workspace.tiled_layout] or actions.common
		if type(action) == "function" then
			action()
		elseif action then
			hl.dispatch(action)
		else
			hl.notification.create({
				text = "No action defined for layout: " .. workspace.tiled_layout,
				timeout = timeout.short,
			})
		end
	end
end

function M.toggle_tiled_layout()
	local workspace = get_active_tiled_workspace()
	if not workspace then return end

	local next_layout = workspace.tiled_layout == "scrolling" and "dwindle" or "scrolling"
	local selector = workspace.special and tostring(workspace.name) or tostring(workspace.id)
	hl.workspace_rule({ workspace = selector, layout = next_layout })
	hl.notification.create({ text = "Layout: " .. next_layout, timeout = timeout.short })
end

function M.window_x(win)
	local at = win.at
	return type(at) == "table" and (at.x or at[1]) or at
end
function M.window_y(win)
	local at = win.at
	return type(at) == "table" and (at.y or at[2]) or 0
end

local function window_size(win, axis)
	local size = win.size
	return type(size) == "table" and (size[axis] or size[axis == "x" and 1 or 2]) or size
end

function M.has_neighbor(axis, cmp)
	local workspace = get_active_tiled_workspace()
	local win = hl.get_active_window()
	-- Floating windows overlay the layout instead of participating in it,
	-- so they are invisible to neighbor detection in both roles.
	if not workspace or not win or win.floating then return false end

	local along = axis == "x" and M.window_x or M.window_y
	local across = axis == "x" and M.window_y or M.window_x
	local cross_axis = axis == "x" and "y" or "x"

	local position = along(win)
	local cross_start = across(win)
	local cross_end = cross_start + window_size(win, cross_axis)
	for _, candidate in ipairs(workspace:get_windows()) do
		if candidate.address ~= win.address and not candidate.floating and cmp(along(candidate), position) then
			local candidate_start = across(candidate)
			local candidate_end = candidate_start + window_size(candidate, cross_axis)
			-- A neighbor must overlap perpendicular to the movement direction.
			if candidate_start < cross_end and candidate_end > cross_start then return true end
		end
	end
	return false
end

function M.has_any_neighbor(axis) return M.has_neighbor(axis, M.lt) or M.has_neighbor(axis, M.gt) end

-- Return a keypress-time action dispatching `primary` when a neighbor exists
-- in the given direction, otherwise `fallback`.
function M.if_neighbor(axis, cmp, primary, fallback)
	return function()
		if M.has_neighbor(axis, cmp) then
			hl.dispatch(primary)
		else
			hl.dispatch(fallback)
		end
	end
end

function M.if_any_neighbor(axis, primary, fallback)
	return function()
		if M.has_any_neighbor(axis) then
			hl.dispatch(primary)
		else
			hl.dispatch(fallback)
		end
	end
end

-- Placeholder ID used to rotate two workspaces without collision.
-- Staged with small delays so Hyprland processes each rename in order.
local SWAP_PLACEHOLDER_ID = 99

function M.swap_workspaces(curr_id, target_id)
	if not curr_id or not target_id then return end
	hl.timer(
		function() hl.dispatch(hl.dsp.workspace.change_id({ workspace = target_id, id = SWAP_PLACEHOLDER_ID })) end,
		{ timeout = 1, type = "oneshot" }
	)
	hl.timer(
		function() hl.dispatch(hl.dsp.workspace.change_id({ workspace = curr_id, id = target_id })) end,
		{ timeout = 10, type = "oneshot" }
	)
	hl.timer(
		function() hl.dispatch(hl.dsp.workspace.change_id({ workspace = SWAP_PLACEHOLDER_ID, id = curr_id })) end,
		{ timeout = 20, type = "oneshot" }
	)
end

-- Move the active workspace ID within the same monitor, skipping IDs
-- owned by other monitors. Creates the ID if empty, swaps if occupied.
function M.move_workspace_id(direction)
	local ws = hl.get_active_workspace()
	if not ws then return end

	local curr_id = ws.id
	local target_id = curr_id + direction
	if target_id < 1 then return end

	local target_ws = hl.get_workspace(target_id)
	while target_ws and target_ws.monitor ~= ws.monitor do
		target_id = target_id + direction
		if target_id < 1 then return end
		target_ws = hl.get_workspace(target_id)
	end

	if not target_ws then
		hl.dispatch(hl.dsp.workspace.change_id({ workspace = curr_id, id = target_id }))
	else
		M.swap_workspaces(curr_id, target_id)
	end
end

-- Split workspaces into ones to keep, grouped by monitor, and empty workspace
-- IDs to drop. A monitor with no populated workspaces must keep its active
-- empty workspace; Hyprland cannot remove the workspace currently displayed
-- by a monitor.
local function partition_workspaces()
	local kept_by_monitor = {}
	local empty_by_monitor = {}
	local active_id_by_monitor = {}
	local monitor_names = {}
	local empty_ids = {}
	local max_id = 0

	for _, monitor in ipairs(hl.get_monitors()) do
		if monitor.active_workspace then active_id_by_monitor[monitor.name] = monitor.active_workspace.id end
	end

	for _, ws in ipairs(hl.get_workspaces()) do
		if ws.id >= 1 and ws.monitor then
			max_id = math.max(max_id, ws.id)
			local monitor_name = ws.monitor.name
			local group = kept_by_monitor[monitor_name]
			if not group then
				group = {}
				kept_by_monitor[monitor_name] = group
				empty_by_monitor[monitor_name] = {}
				table.insert(monitor_names, monitor_name)
			end
			if ws.windows == 0 then
				table.insert(empty_by_monitor[monitor_name], ws.id)
			else
				table.insert(group, ws.id)
			end
		end
	end

	for monitor_name, empties in pairs(empty_by_monitor) do
		local group = kept_by_monitor[monitor_name]
		local keep_empty_id = nil
		if #group == 0 and #empties > 0 then
			keep_empty_id = active_id_by_monitor[monitor_name] or empties[1]
			table.insert(group, keep_empty_id)
		end
		for _, workspace_id in ipairs(empties) do
			if workspace_id ~= keep_empty_id then table.insert(empty_ids, workspace_id) end
		end
	end

	return kept_by_monitor, monitor_names, empty_ids, max_id
end

-- Flatten grouped workspace IDs ordered by monitor name, then ID. Also
-- returns the final ID of the first workspace on `focus_monitor` so a
-- dropped active workspace can be refocused after compacting.
local function flatten_workspace_ids(kept_by_monitor, monitor_names, focus_monitor)
	table.sort(monitor_names)
	local workspace_ids = {}
	local focus_id = nil
	for _, monitor_name in ipairs(monitor_names) do
		local group = kept_by_monitor[monitor_name]
		table.sort(group)
		for _, workspace_id in ipairs(group) do
			table.insert(workspace_ids, workspace_id)
			-- Kept workspaces are renumbered to 1..N in this order, so the
			-- position is the final ID.
			if focus_id == nil and monitor_name == focus_monitor then focus_id = #workspace_ids end
		end
	end
	return workspace_ids, focus_id
end

local function change_workspace_id(workspace, id)
	hl.dispatch(hl.dsp.workspace.change_id({ workspace = workspace, id = id }))
end

function M.organize_workspaces()
	local active_ws = hl.get_active_workspace()
	local active_monitor = active_ws and active_ws.monitor and active_ws.monitor.name or nil

	local kept_by_monitor, monitor_names, empty_ids, max_id = partition_workspaces()
	local dropped_ids = {}
	for _, workspace_id in ipairs(empty_ids) do
		dropped_ids[workspace_id] = true
	end
	local active_dropped = active_ws ~= nil and dropped_ids[active_ws.id] == true
	local workspace_ids, focus_id = flatten_workspace_ids(kept_by_monitor, monitor_names, active_monitor)
	if #workspace_ids == 0 then return end

	-- Stage through temporary IDs: change_id refuses targets already in
	-- use, so park dropped empties above max_id first, then move kept
	-- workspaces through temps to 1..N. Parked empties evaporate once
	-- unfocused; a dropped active workspace is refocused below.
	local temp_id = max_id + 1
	for _, workspace_id in ipairs(empty_ids) do
		change_workspace_id(workspace_id, temp_id)
		temp_id = temp_id + 1
	end
	local first_temp_id = temp_id
	for index, workspace_id in ipairs(workspace_ids) do
		change_workspace_id(workspace_id, first_temp_id + index - 1)
	end
	for index = 1, #workspace_ids do
		change_workspace_id(first_temp_id + index - 1, index)
	end

	if active_dropped then
		if focus_id ~= nil then
			hl.dispatch(hl.dsp.focus({ workspace = focus_id }))
		else
			hl.dispatch(hl.dsp.focus({ workspace = "emptym", on_current_monitor = true }))
		end
	end
end

return M
