-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
local start_cmds = {
	-- important stuff
	-- Sync Wayland session vars into systemd user manager + D-Bus activation
	-- env so portals (xdg-desktop-portal-hyprland) and Electron/Qt apps like
	-- Zoom see XDG_SESSION_TYPE=wayland (Zoom logs isNativeWayland=0 and shows
	-- black share previews when this is missing).
	"systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP XDG_SEAT XDG_VTNR",
	"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP XDG_SEAT XDG_VTNR",
	"systemctl --user set-environment XDG_SESSION_CLASS=user XDG_SESSION_TYPE=wayland DESKTOP_SESSION=hyprland",
	"systemctl --user start --no-block hyprland-session.target",
	"noctalia",
	"XDG_MENU_PREFIX=arch- kbuildsycoca6",
	"gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'",
	"systemd-inhibit --what=handle-lid-switch --who='Hyprland' --why='Custom lid handling' --mode=block sleep infinity &",
	"hypridle",
	{ cmd = "Telegram", opts = { workspace = "special:magic" } },
	{ cmd = "thunderbird", opts = { workspace = "special:magic" } },
	"brave-origin-nightly --app=https://web.whatsapp.com",
	"gdbus wait --session org.kde.StatusNotifierWatcher && QT_QPA_PLATFORM=xcb synology-drive start",
	"hyprpm reload",
}

hl.on("hyprland.start", function()
	for _, item in ipairs(start_cmds) do
		if type(item) == "string" then
			hl.exec_cmd(item)
		else
			hl.exec_cmd(item.cmd, item.opts)
		end
	end
end)

hl.on("hyprland.shutdown", function()
	hl.exec_cmd("synology-drive stop")
end)
