---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal = "alacritty"
local fileManager = "dolphin"
local noctPrefix = "qs -c noctalia-shell ipc call"
local menu = noctPrefix .. " launcher toggle"

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function()
	-- important stuff
	hl.exec_cmd("qs -c noctalia-shell")
	hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
	hl.exec_cmd("/usr/lib/xdg-desktop-portal")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
	hl.exec_cmd("hyprpm reload")
end)

return { terminal = terminal, fileManager = fileManager, noctPrefix = noctPrefix, menu = menu }
