------------------
---- MONITORS ----
------------------

local constants = require("config.constants")
local main_mod = constants.main_mod
local noct_prefix = constants.noct_prefix
local timeout = constants.timeout

local BUILT_IN_OUTPUT = "eDP-1"

hl.monitor({
	output = "desc:Acer Technologies EK221Q H 1335088483W01",
	mode = "1920x1080@100",
	position = "auto-center-up",
})

hl.monitor({
	output = "desc:Beihai Century Joint Innovation Technology Co.Ltd X240 0000000000000",
	mode = "1920x1080@120",
	position = "auto-center-left",
	cm = "auto",
})

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
	output = BUILT_IN_OUTPUT,
	mode = "preferred",
	position = "auto",
	scale = "1.5",
	icc = "/home/yihao/.local/share/icc/default.icm",
	-- cm = "hdr",
})

----------------------------
---- DISPLAY SHORTCUTS  ----
----------------------------
local lid_closed = false
local suppress_next_removed = false
local built_in_disabled = false

local function notify_no_external_monitor()
	hl.notification.create({ text = "No external monitor detected", timeout = timeout.medium })
end

hl.bind("switch:on:Lid Switch", function()
	local monitors = hl.get_monitors()
	lid_closed = true
	if #monitors == 1 and not built_in_disabled then
		hl.dispatch(hl.dsp.exec_cmd(noct_prefix .. " session lock-and-suspend"))
	else
		-- Disabling BUILT_IN_OUTPUT emits monitor.removed. Use the same one-shot guard as
		-- the manual toggle so it is not mistaken for an external unplug.
		suppress_next_removed = true
		hl.monitor({ output = BUILT_IN_OUTPUT, disabled = true })
	end
end, { locked = true })

hl.bind("switch:off:Lid Switch", function()
	lid_closed = false
	hl.monitor({ output = BUILT_IN_OUTPUT, disabled = false })
	hl.exec_cmd("hyprctl reload")
end, { locked = true })

local function toggle_built_in_display()
	local monitors = hl.get_monitors()
	if #monitors == 1 and monitors[1].name == BUILT_IN_OUTPUT then
		notify_no_external_monitor()
		return
	end

	if lid_closed then return end

	built_in_disabled = not built_in_disabled
	if built_in_disabled then suppress_next_removed = true end
	hl.monitor({ output = BUILT_IN_OUTPUT, disabled = built_in_disabled })
end

local function mirror_screen()
	local monitors = hl.get_monitors()
	if #monitors == 1 then
		notify_no_external_monitor()
		return
	end

	local window = hl.get_window("class:at.yrlf.wl_mirror")
	if window then
		hl.notification.create({ text = "Stopping screen mirroring", timeout = timeout.medium })
		hl.exec_cmd("pkill -9 wl-mirror")
	else
		for _, monitor in ipairs(monitors) do
			if monitor.name ~= BUILT_IN_OUTPUT then
				hl.notification.create({
					text = "Starting screen mirroring on " .. monitor.description,
					timeout = timeout.medium,
				})
				hl.exec_cmd("wl-mirror " .. BUILT_IN_OUTPUT, { monitor = monitor.name, fullscreen = true })
			end
		end

		-- Focus the built in display after a short delay to prevent the spawned wl-mirror
		-- window from stealing focus
		hl.timer(
			function() hl.dispatch(hl.dsp.focus({ monitor = BUILT_IN_OUTPUT })) end,
			{ timeout = 50, type = "oneshot" }
		)
	end
end

local display_binds = {
	{ key = "T", desc = "Toggle built-in display", fn = toggle_built_in_display },
	{ key = "M", desc = "Toggle mirroring", fn = mirror_screen },
}

hl.bind(main_mod .. " + P", function()
	local parts = {}
	for i, b in ipairs(display_binds) do
		parts[i] = b.key .. ": " .. b.desc
	end
	hl.notification.create({
		text = table.concat(parts, ", "),
		timeout = timeout.medium,
	})
	hl.dispatch(hl.dsp.submap("displayControl"))
end)

hl.define_submap("displayControl", "reset", function()
	for _, b in ipairs(display_binds) do
		hl.bind(b.key, b.fn)
	end

	hl.bind(
		"catchall",
		function() hl.notification.create({ text = "Escaping display control", timeout = timeout.medium }) end
	)
end)

hl.on("monitor.removed", function()
	if suppress_next_removed then
		suppress_next_removed = false
		return
	end

	if not lid_closed then
		built_in_disabled = false
		hl.monitor({ output = BUILT_IN_OUTPUT, disabled = built_in_disabled })
		hl.exec_cmd("hyprctl reload")
	else
		hl.dsp.exec_cmd(noct_prefix .. " session lock-and-suspend")
	end
end)
