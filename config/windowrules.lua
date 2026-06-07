--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

-- local suppressMaximizeRule = hl.window_rule({
-- 	-- Ignore maximize requests from all apps. You'll probably like this.
-- 	name = "suppress-maximize-events",
-- 	match = { class = ".*" },
--
-- 	suppress_event = "maximize",
-- })
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

hl.window_rule({
	match = { class = "org.mozilla.Thunderbird", initial_title = "negative:Mozilla Thunderbird" },
	float = true,
	workspace = "current",
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
	fullscreen = true,
	workspace = "emptynm",
})

-- zoom
hl.window_rule({
	match = { class = "Zoom", initial_title = "negative:Zoom Workplace|Meeting" },
	float = true,
	pin = true,
})

hl.window_rule({
	match = { class = "Zoom", title = "Meeting" },
	fullscreen_state = "1 3",
})

hl.window_rule({
	match = { class = "Zoom", title = "zoom_linux_float_video_window" },
	float = true,
	pin = true,
	move = { "monitor_w * 0.8", "monitor_h * 0.2" },
})

hl.window_rule({
	match = { class = "Zoom", title = "as_toolbar" },
	pin = true,
	move = { "monitor_w * 0.5 - (window_w * 0.5)", "20" },
})

-- onlyoffice
hl.window_rule({
	match = { class = "DesktopEditors" },
	center = true,
})
