------------------
---- MONITORS ----
------------------

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
	output = "eDP-1",
	mode = "preferred",
	position = "auto",
	scale = "1.5",
	-- icc = "/home/yihao/.local/share/icc/default.icm",
	cm = "auto",
	bitdepth = 10,
})

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
	mirror = "eDP-1",
})

----------------------------
---- DISPLAY SHORTCUTS  ----
----------------------------
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
	hl.notification.create({
		text = "D: disable built-in display, M: Mirror screen, H: Hide mirroring",
		duration = 5000,
	})
	hl.dispatch(hl.dsp.submap("displayControl"))
end)

hl.define_submap("displayControl", "reset", function()
	hl.bind("D", function()
		local monitors = hl.get_monitors()
		if #monitors == 1 and monitors[1].name == "eDP-1" then
			hl.notification.create({ text = "No external monitor detected", duration = 3000 })
			return
		end

		if lid_closed then
			return
		end
		built_in_disabled = not built_in_disabled
		if built_in_disabled then
			toggle_built_in = true
		end
		hl.monitor({ output = "eDP-1", disabled = built_in_disabled })
	end)

	hl.bind("M", function()
		local monitors = hl.get_monitors()
		if #monitors == 1 then
			hl.notification.create({ text = "No external monitor detected", duration = 3000 })
			return
		end

		for _, monitor in ipairs(monitors) do
			if monitor.name ~= "eDP-1" then
				hl.exec_cmd("wl-mirror eDP-1", { monitor = monitor.name, fullscreen = true })
				return
			end
		end
	end)

	hl.bind("H", function()
		local window = hl.get_window("class:at.yrlf.wl_mirror")
		if window then
			hl.dispatch(hl.dsp.dpms({ monitor = window.monitor.name, action = "toggle" }))
		else
			hl.notification.create({ text = "No mirrored monitor found", duration = 3000 })
		end
	end)
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
