--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.workspace_rule({
	workspace = "s[true]",
	layout = "dwindle",
})

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
hl.layer_rule({
	name = "noctalia",
	match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$" },
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})

hl.layer_rule({
	name = "hide-notifications",
	match = { namespace = "noctalia-notification$" },
	no_screen_share = true,
})

hl.window_rule({
	match = { initial_title = "Noctalia Settings" },
	no_screen_share = true,
	workspace = "current",
})

hl.window_rule({
	match = { class = "eu.betterbird.Betterbird", initial_title = "negative:.*Betterbird|Write.*" },
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
	float = true,
	workspace = "current",
	fullscreen = true,
})

hl.window_rule({
	match = { class = "org.telegram.desktop", title = "Choose Files" },
	float = true,
})

hl.window_rule({
	match = { initial_class = "^brave-web[.]whatsapp[.]com__-Default$" },
	workspace = "special:magic",
})

-- zoom
hl.window_rule({
	match = { class = "Zoom", initial_title = "negative:Zoom Workplace|Zoom Workplace - .*|Meeting" },
	float = true,
})

hl.window_rule({
	match = { class = "Zoom", initial_title = "Meeting" },
	suppress_event = "activate activatefocus",
})

hl.window_rule({
	match = { title = "as_toolbar" },
	opacity = 0.5,
})

-- onlyoffice
hl.window_rule({
	match = { class = "DesktopEditors" },
	center = true,
})

-- libreoffice
hl.window_rule({
	match = { class = "libreoffice-impress" },
	scrolling_width = 1,
})

hl.window_rule({
	match = { class = "libreoffice-impress", title = "Console:.*" },
	suppress_event = "activate activatefocus",
})

hl.window_rule({
	match = { class = "libreoffice-impress", title = "Presenting: .*" },
	scrolling_width = 0.75,
	fullscreen_state = "0 3",
})

hl.window_rule({
	match = { class = "com.github.xournalpp.xournalpp" },
	workspace = "current",
})

hl.window_rule({
	match = { class = "granola", title = "Nub" },
	move = { "(monitor_w * 0.95)", "30" },
	pin = true,
	decorate = false,
	no_blur = true,
})

hl.window_rule({
	match = { class = "org.gnome.Nautilus|dev.noctalia.Noctalia|xdg-desktop-portal-gtk" },
	float = true,
	rounding = 18,
	rounding_power = 3.5,
	size = { "(monitor_w * 0.5)", "(monitor_h * 0.5)" },
})
