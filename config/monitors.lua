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

----------------------------
---- DISPLAY SHORTCUTS  ----
----------------------------
local mainMod = require("config.constants").mainMod
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

local function toggle_built_in_display()
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
end

local function mirror_screen()
	local monitors = hl.get_monitors()
	if #monitors == 1 then
		hl.notification.create({ text = "No external monitor detected", duration = 3000 })
		return
	end

	local window = hl.get_window("class:at.yrlf.wl_mirror")
	if window then
		hl.notification.create({ text = "Stopping screen mirroring", duration = 3000 })
		hl.exec_cmd("pkill -9 wl-mirror")
	else
		for _, monitor in ipairs(monitors) do
			if monitor.name ~= "eDP-1" then
				hl.notification.create({
					text = "Starting screen mirroring on " .. monitor.description,
					duration = 3000,
				})
				hl.exec_cmd("wl-mirror eDP-1", { monitor = monitor.name, fullscreen = true })
			end
		end

		-- Focus the built in display after a short delay to prevent the spawned wl-mirror
		-- window from stealing focus
		hl.timer(function()
			hl.dispatch(hl.dsp.focus({ monitor = "eDP-1" }))
		end, { timeout = 50, type = "oneshot" })
	end
end

local displayBinds = {
	{ key = "T", desc = "Toggle built-in display", fn = toggle_built_in_display },
	{ key = "M", desc = "Toggle mirroring", fn = mirror_screen },
}

hl.bind(mainMod .. " + P", function()
	local parts = {}
	for i, b in ipairs(displayBinds) do
		parts[i] = b.key .. ": " .. b.desc
	end
	hl.notification.create({
		text = table.concat(parts, ", "),
		duration = 3000,
	})
	hl.dispatch(hl.dsp.submap("displayControl"))
end)

hl.define_submap("displayControl", "reset", function()
	for _, b in ipairs(displayBinds) do
		hl.bind(b.key, b.fn)
	end

	hl.bind("catchall", function()
		hl.notification.create({ text = "Escaping display control", duration = 3000 })
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
