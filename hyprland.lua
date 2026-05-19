-- Disabled after converting the configuration back to Hyprlang in hyprland.conf.
-- This was the Lua entrypoint; the split Lua files remain as a backup/reference.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")

require("config.monitors")
require("config.autostart")
require("config.env")
require("config.appearance")
require("config.misc")
require("config.input")
require("config.keybinds")
require("config.windowrules")
