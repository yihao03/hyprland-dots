--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
-- 	name = "no-anim-overlay",
-- 	match = { namespace = "^my-overlay$" },
-- 	no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

-- firefox open in same workspace
hl.window_rule({
	match = { class = "firefox" },
	workspace = "current",
})

hl.window_rule({
	match = { class = "org.mozilla.Thunderbird", title = "Confirm Deletion" },
	workspace = "current",
})

hl.window_rule({
	match = { class = "org.mozilla.Thunderbird", initial_title = "negative:Mozilla Thunderbird" },
	float = true,
})

hl.window_rule({
	match = { title = "Picture-in-Picture" },
	float = true,
	size = { "(monitor_w*0.3)", "(monitor_h*0.3)" },
})

hl.window_rule({
	match = { initial_class = "com.mitchellh.ghostty" },
	workspace = "current",
})

hl.window_rule({
	match = {
		class = "org.telegram.desktop",
		title = "Media viewer",
	},
	workspace = "current",
	fullscreen = true,
})

hl.window_rule({
	match = { class = "org.telegram.desktop", title = "Choose Files" },
	float = true,
	workspace = "current",
})

-- waydroid
hl.window_rule({
	match = { class = "Waydroid" },
	workspace = 10,
})

-- zoom
hl.window_rule({
	match = { class = "Zoom", initial_title = "negative:Zoom Workplace|Meeting" },
	float = true,
})
--------------------------------
-- Bind workspace to monitor  --
--------------------------------
hl.workspace_rule({ workspace = "1", monitor = "DP-3" })
