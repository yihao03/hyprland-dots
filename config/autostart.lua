-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

local function set_sunset()
	hl.exec_cmd("hyprsunset")
	-- Set hyprsunset based on time (matches hyprsunset.conf profiles)
	local hour = tonumber(os.date("%H"))
	local minute = tonumber(os.date("%M"))
	local time_minutes = hour * 60 + minute
	local sunrise = 7 * 60 + 30 -- 7:30
	local sunset = 18 * 60 -- 18:00

	if time_minutes >= sunrise and time_minutes < sunset then
		hl.exec_cmd("hyprctl hyprsunset identity")
	else
		hl.exec_cmd("hyprctl hyprsunset temperature 4000")
	end
end

hl.on("hyprland.start", function()
	-- important stuff
	hl.exec_cmd("qs -c noctalia-shell")
	hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
	hl.exec_cmd("/usr/lib/xdg-desktop-portal")
	hl.exec_cmd("XDG_MENU_PREFIX=arch- kbuildsycoca6")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("Telegram", { workspace = "special:magic" })
	hl.exec_cmd("thunderbird", { workspace = "special:magic" })

	hl.exec_cmd("hyprpm reload")
	set_sunset()
end)
