---------------------
---- KEYBINDINGS ----
---------------------

local constants = require("config.constants")
local mainMod = constants.mainMod
local noctPrefix = constants.noctPrefix

-- open apps
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(constants.terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(constants.browser))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.window.signal({ signal = 9 }))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(constants.fileManager))

-- noctalia commands
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd(constants.noctPrefix .. " panel-toggle session"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(constants.noctPrefix .. " panel-toggle control-center"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(constants.noctPrefix .. " panel-toggle clipboard"))
hl.bind("ALT + Tab", function()
	for _, layer in ipairs(hl.get_layers()) do
		if layer.namespace == "noctalia-window-switcher" then
			return
		end
	end
	hl.dispatch(hl.dsp.exec_cmd(constants.noctPrefix .. " window-switcher"))
end, { non_consuming = true })
hl.bind(mainMod .. " + SHIFT + F23", hl.dsp.exec_cmd(constants.menu))

-- command to lock: command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'

-- Windowing controls
hl.bind(mainMod .. " + V", function()
	hl.dispatch(hl.dsp.window.float({ toggle = true }))
	local monitor = hl.get_active_monitor()
	if monitor then
		hl.dispatch(hl.dsp.window.resize({ x = monitor.width / 2, y = monitor.height / 2 }))
	end
end)
hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + F", function()
	local opts = { action = "toggle", internal = 2, client = 2 }
	-- prevent helium from going fullscreen and hiding sidebar
	local class = hl.get_active_window().initial_class
	if class == "helium" or class == "brave-origin-nightly" then
		opts.client = 0
	end
	hl.dispatch(hl.dsp.window.fullscreen_state(opts))
end)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("ALT + mouse:272", hl.dsp.window.resize(), { mouse = true })

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Move the windows
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- Resize windows
hl.bind(mainMod .. " + ALT + H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
end

-- Switch to next/previous workspace
hl.bind(mainMod .. " + N", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + CTRL + N", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.focus({ workspace = "prev" }))
hl.bind(mainMod .. " + ALT + N", hl.dsp.focus({ workspace = "emptym", on_current_monitor = true }))
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Swap monitors
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "+1" }))
hl.bind(mainMod .. " + ALT + T", hl.dsp.workspace.move({ monitor = "+1" }))

-- special workspace (communication)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move windows to workspace
hl.bind(mainMod .. " + M", function()
	if hl.get_active_window() == nil then
		hl.notification.create({ text = "No active window", duration = 3000 })
		return
	end
	hl.notification.create({ text = "Select workspace to move window to", duration = 3000 })
	hl.dispatch(hl.dsp.submap("moveToWorkspace"))
end)

hl.define_submap("moveToWorkspace", function()
	for i = 1, 10 do
		hl.bind(tostring(i % 10), hl.dsp.window.move({ workspace = i }))
	end

	hl.bind("N", hl.dsp.window.move({ workspace = "m+1" }))
	hl.bind("P", hl.dsp.window.move({ workspace = "m-1" }))
	hl.bind("E", hl.dsp.window.move({ workspace = "emptym", on_current_monitor = true }))

	hl.bind("escape", function()
		hl.notification.create({ text = "Escaped moving window", duration = 2000 })
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
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(noctPrefix .. " brightness-up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noctPrefix .. " brightness-down"), { locked = true, repeating = true })

hl.bind("XF86Calculator", hl.dsp.exec_cmd(noctPrefix .. " media toggle"), { locked = true })

-- Printscreen
hl.bind("Print", hl.dsp.exec_cmd(noctPrefix .. " screenshot-region"))
