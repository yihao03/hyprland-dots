local M = {}

local opened_by_alt_tab = false

local function object_value(value, key)
	if value == nil then return nil end

	local ok, result = pcall(function() return value[key] end)

	return ok and result or nil
end

local function selection_state()
	local workspace_id = object_value(hl.get_active_workspace(), "id")
	local window_address = object_value(hl.get_active_window(), "address")
	return tostring(workspace_id) .. ":" .. tostring(window_address)
end

local function navigate_to_first_column()
	local previous_state
	local max_steps = #(hl.get_windows() or {}) + #(hl.get_workspaces() or {}) + 1

	for _ = 1, max_steps do
		local current_state = selection_state()
		if current_state == previous_state then return end

		previous_state = current_state
		hl.plugin.scrolloverview.navigate("left")
	end
end

local function navigate_column(dir)
	local previous_state = selection_state()
	hl.plugin.scrolloverview.navigate(dir)

	if selection_state() == previous_state then navigate_to_first_column() end
end

local function open_overview(direction)
	hl.config({
		plugin = {
			scrolloverview = {
				layout = "horizontal",
				scale = 0.3,
			},
		},
	})
	hl.plugin.scrolloverview.overview("on")
	opened_by_alt_tab = true
	navigate_column(direction)
end

function M.next() open_overview("right") end

function M.prev() open_overview("left") end

function M.close()
	if opened_by_alt_tab then
		hl.plugin.scrolloverview.overview("off")
		opened_by_alt_tab = false
	end
end

return M
