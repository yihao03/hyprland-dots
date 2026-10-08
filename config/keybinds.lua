---------------------
---- KEYBINDINGS ----
---------------------

local utils = require("config.utils")
local lt = utils.lt
local gt = utils.gt
local if_neighbor = utils.if_neighbor
local if_any_neighbor = utils.if_any_neighbor
local move_workspace_id = utils.move_workspace_id
local organize_workspaces = utils.organize_workspaces
local layout_binding = utils.layout_binding
local toggle_tiled_layout = utils.toggle_tiled_layout

local constants = require("config.constants")
local default_layout = constants.default_layout
local main_mod = constants.main_mod
local noct_prefix = constants.noct_prefix
local timeout = constants.timeout

-- Open apps in their own systemd scopes.
hl.bind(main_mod .. " + Q", utils.launch_app(constants.terminal))
hl.bind(main_mod .. " + B", utils.launch_app(constants.browser))
hl.bind(main_mod .. " + SHIFT + B", utils.launch_app(constants.browser .. " --incognito"))
hl.bind(main_mod .. " + W", hl.dsp.window.close())
hl.bind(main_mod .. " + CTRL + W", hl.dsp.window.signal({ signal = 9 })) -- SIGKILL
hl.bind(main_mod .. " + SHIFT + W", hl.dsp.window.signal({ signal = 3 })) -- SIGQUIT
hl.bind(main_mod .. " + E", utils.launch_app(constants.file_manager))

-- noctalia commands
hl.bind(main_mod .. " + CTRL + L", hl.dsp.exec_cmd(constants.noct_prefix .. " panel-toggle session"))
hl.bind(main_mod .. " + A", hl.dsp.exec_cmd(constants.noct_prefix .. " panel-toggle control-center"))
hl.bind(main_mod .. " + SHIFT + V", hl.dsp.exec_cmd(constants.noct_prefix .. " panel-toggle clipboard"))
hl.bind("ALT + Tab", function()
	for _, layer in ipairs(hl.get_layers()) do
		if layer.namespace == "noctalia-window-switcher" then return end
	end
	hl.dispatch(hl.dsp.exec_cmd(constants.noct_prefix .. " window-switcher"))
end, { non_consuming = true })
hl.bind(main_mod .. " + SHIFT + F23", hl.dsp.exec_cmd(constants.menu))

-- Stop the UWSM session gracefully.
hl.bind(main_mod .. " + CTRL + Q", hl.dsp.exec_cmd("uwsm stop"))

if default_layout == "dwindle" then
	hl.gesture({
		fingers = 3,
		direction = "horizontal",
		action = "workspace",
	})
elseif default_layout == "scrolling" then
	hl.gesture({
		fingers = 3,
		direction = "horizontal",
		action = "scroll_move",
		scale = 5,
	})
	hl.gesture({
		fingers = 3,
		direction = "vertical",
		action = "workspace",
	})
end

hl.gesture({
	fingers = 4,
	direction = "pinch",
	action = function() utils.toggle_fullscreen() end,
})

-- Windowing controls
hl.bind(main_mod .. " + V", function()
	hl.dispatch(hl.dsp.window.float({ toggle = true }))
	local monitor = hl.get_active_monitor()
	if monitor then hl.dispatch(hl.dsp.window.resize({ x = monitor.width / 2, y = monitor.height / 2 })) end
end)
hl.bind(
	main_mod .. " + T",
	layout_binding({
		dwindle = hl.dsp.layout("togglesplit"),
		scrolling = hl.dsp.layout("consume_or_expel prev"),
	})
)
hl.bind(main_mod .. " + CTRL + T", toggle_tiled_layout)
hl.bind(main_mod .. " + F", function() utils.toggle_fullscreen() end)
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("ALT + mouse:272", hl.dsp.window.resize(), { mouse = true })

-- Move focus with main_mod + H/J/K/L, including floating windows.
hl.bind(
	main_mod .. " + H",
	layout_binding({
		dwindle = hl.dsp.focus({ direction = "left" }),
		scrolling = if_neighbor("x", lt, hl.dsp.layout("focus l"), hl.dsp.focus({ direction = "left" })),
	})
)
hl.bind(
	main_mod .. " + L",
	layout_binding({
		dwindle = hl.dsp.focus({ direction = "right" }),
		scrolling = if_neighbor("x", gt, hl.dsp.layout("focus r"), hl.dsp.focus({ direction = "right" })),
	})
)
hl.bind(
	main_mod .. " + K",
	layout_binding({
		dwindle = if_neighbor(
			"y",
			lt,
			hl.dsp.focus({ direction = "up" }),
			hl.dsp.focus({ workspace = "r-1" }),
			hl.dsp.focus({ direction = "up" })
		),
		scrolling = if_neighbor(
			"y",
			lt,
			hl.dsp.layout("focus u"),
			hl.dsp.focus({ workspace = "r-1" }),
			hl.dsp.focus({ direction = "up" })
		),
	})
)
hl.bind(
	main_mod .. " + J",
	layout_binding({
		dwindle = if_neighbor(
			"y",
			gt,
			hl.dsp.focus({ direction = "down" }),
			hl.dsp.focus({ workspace = "r+1" }),
			hl.dsp.focus({ direction = "down" })
		),
		scrolling = if_neighbor(
			"y",
			gt,
			hl.dsp.layout("focus d"),
			hl.dsp.focus({ workspace = "r+1" }),
			hl.dsp.focus({ direction = "down" })
		),
	})
)
hl.bind(
	main_mod .. " + mouse_up",
	layout_binding({ scrolling = hl.dsp.layout("focus l") }),
	{ mouse = true, non_consuming = false }
)
hl.bind(
	main_mod .. " + mouse_down",
	layout_binding({ scrolling = hl.dsp.layout("focus r") }),
	{ mouse = true, non_consuming = false }
)

-- Move the windows
hl.bind(
	main_mod .. " + SHIFT + H",
	layout_binding({
		dwindle = hl.dsp.window.move({ direction = "left" }),
		scrolling = if_any_neighbor("y", hl.dsp.window.move({ direction = "left" }), hl.dsp.layout("swapcol l")),
	})
)
hl.bind(
	main_mod .. " + SHIFT + L",
	layout_binding({
		dwindle = hl.dsp.window.move({ direction = "right" }),
		scrolling = if_any_neighbor("y", hl.dsp.window.move({ direction = "right" }), hl.dsp.layout("swapcol r")),
	})
)
local move_up_or_workspace =
	if_neighbor("y", lt, hl.dsp.window.move({ direction = "up" }), hl.dsp.window.move({ workspace = "r-1" }))
local move_down_or_workspace =
	if_neighbor("y", gt, hl.dsp.window.move({ direction = "down" }), hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(
	main_mod .. " + SHIFT + K",
	layout_binding({
		dwindle = move_up_or_workspace,
		scrolling = move_up_or_workspace,
	})
)
hl.bind(
	main_mod .. " + SHIFT + J",
	layout_binding({
		dwindle = move_down_or_workspace,
		scrolling = move_down_or_workspace,
	})
)

hl.bind(
	main_mod .. " + ALT + E",
	layout_binding({
		common = hl.dsp.focus({ workspace = "emptym", on_current_monitor = true }),
	})
)
hl.bind(main_mod .. " + CTRL + J", layout_binding({ common = function() move_workspace_id(1) end }))
hl.bind(main_mod .. " + CTRL + K", layout_binding({ common = function() move_workspace_id(-1) end }))

-- Resize windows
hl.bind(
	main_mod .. " + ALT + H",
	layout_binding({
		dwindle = hl.dsp.window.resize({ x = -50, y = 0, relative = true }),
		scrolling = hl.dsp.layout("colresize -0.1"),
	}),
	{ repeating = true }
)
hl.bind(
	main_mod .. " + ALT + L",
	layout_binding({
		dwindle = hl.dsp.window.resize({ x = 50, y = 0, relative = true }),
		scrolling = hl.dsp.layout("colresize +0.1"),
	}),
	{ repeating = true }
)
hl.bind(main_mod .. " + ALT + J", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
hl.bind(main_mod .. " + ALT + K", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })

-- Switch workspaces with main_mod + [0-9]
-- Move active window to a workspace with main_mod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
end

-- Switch to next/previous workspace
hl.bind(main_mod .. " + SHIFT + mouse_down", hl.dsp.focus({ workspace = "r-1" }), { mouse = true })
hl.bind(main_mod .. " + SHIFT + mouse_up", hl.dsp.focus({ workspace = "r+1" }), { mouse = true })
-- Swap monitors
hl.bind(main_mod .. " + SHIFT + T", hl.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "+1" }))
hl.bind(main_mod .. " + ALT + T", hl.dsp.workspace.move({ monitor = "+1" }))

-- special workspace (communication)
hl.bind(main_mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(main_mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- organize workspaces
hl.bind(main_mod .. " + CTRL + O", function()
	hl.notification.create({ text = "Organizing workspaces", timeout = timeout.medium })
	organize_workspaces()
end)

-- Move windows to workspace
hl.bind(main_mod .. " + M", function()
	if hl.get_active_window() == nil then
		hl.notification.create({ text = "No active window", timeout = timeout.medium })
		return
	end
	hl.notification.create({ text = "Select workspace to move window to", timeout = timeout.medium })
	hl.dispatch(hl.dsp.submap("moveToWorkspace"))
end)

hl.define_submap("moveToWorkspace", function()
	for i = 1, 10 do
		hl.bind(tostring(i % 10), hl.dsp.window.move({ workspace = i }))
	end

	hl.bind("N", hl.dsp.window.move({ workspace = "m+1" }))
	hl.bind("P", hl.dsp.window.move({ workspace = "m-1" }))
	hl.bind("SHIFT + N", hl.dsp.window.move({ workspace = "e+1" }))
	hl.bind("SHIFT + P", hl.dsp.window.move({ workspace = "e-1" }))
	hl.bind("E", function()
		hl.dispatch(hl.dsp.window.move({ workspace = "emptym", on_current_monitor = true }))
		hl.dispatch(hl.dsp.submap("reset"))
	end)

	hl.bind("escape", function()
		hl.notification.create({ text = "Escaped moving window", timeout = timeout.short })
		hl.dispatch(hl.dsp.submap("reset"))
	end)
end)

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd(noct_prefix .. " brightness-up all 5"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd(noct_prefix .. " brightness-down all 5"),
	{ locked = true, repeating = true }
)

hl.bind("XF86Calculator", hl.dsp.exec_cmd(noct_prefix .. " media toggle"), { locked = true })

-- Printscreen
hl.bind("Print", hl.dsp.exec_cmd(noct_prefix .. " screenshot-region"))
