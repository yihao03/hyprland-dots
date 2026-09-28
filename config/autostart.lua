-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- uwsm/systemd owns session env and long-lived daemons (noctalia,
-- lid-inhibit, synology-drive user units), so only one-shots and
-- workspace-placed apps stay here. Interactive apps are scoped via
-- utils.scoped_cmd (runapp / `uwsm app`) like keybind launches.
local utils = require("config.utils")

local start_cmds = {
	"gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'",
	utils.scoped_cmd("brave-origin-nightly --app=https://web.whatsapp.com"),
	{ cmd = utils.scoped_cmd("Telegram"), opts = { workspace = "special:magic" } },
	{ cmd = utils.scoped_cmd("betterbird"), opts = { workspace = "special:magic" } },
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
