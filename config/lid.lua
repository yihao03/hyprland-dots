local mainMod = require("config.keybinds").mainMod
local lid_closed = false
local toggle_built_in = false
local built_in_disabled = false

hl.bind("switch:on:Lid Switch", function()
	local monitors = hl.get_monitors()
	lid_closed = true
	if #monitors == 1 then
		hl.dispatch(
			hl.dsp.exec_cmd("sh -c 'qs -c noctalia-shell ipc call lockScreen lock && sleep 1 && systemctl suspend'")
		)
	else
		hl.monitor({ output = "eDP-1", disabled = true })
	end
end, { locked = true })

hl.bind("switch:off:Lid Switch", function()
	lid_closed = false
	hl.monitor({ output = "eDP-1", disabled = false })
	hl.exec_cmd("hyprctl reload")
end, { locked = true })

hl.bind(mainMod .. " + P", function()
	if lid_closed then
		return
	end

	local monitors = hl.get_monitors()
	if #monitors == 1 then
		hl.notification.create({ text = "No external monitor detected", duration = 3000 })
		return
	end
	built_in_disabled = not built_in_disabled
	if built_in_disabled then
		toggle_built_in = true
	end
	hl.monitor({ output = "eDP-1", disabled = built_in_disabled })
end)

hl.on("monitor.removed", function()
	if toggle_built_in then
		toggle_built_in = false
		return
	end

	if not lid_closed then
		built_in_disabled = false
		hl.monitor({ output = "eDP-1", disabled = built_in_disabled })
		hl.exec_cmd("hyprctl reload")
	end
end)
