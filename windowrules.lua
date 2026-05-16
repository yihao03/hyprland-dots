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

-- waydroid
hl.window_rule({
	match = { class = "Waydroid" },
	workspace = 10,
})

--------------------------------
-- Bind workspace to monitor  --
--------------------------------
hl.workspace_rule({ workspace = "1", monitor = "DP-3" })
