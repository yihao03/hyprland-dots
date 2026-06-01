---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,

		touchpad = {
			natural_scroll = true,
			clickfinger_behavior = true,
		},
	},
})

-- hl.gesture({
-- 	fingers = 3,
-- 	direction = "horizontal",
-- 	action = "scroll_move",
-- })

hl.device({
	name = " mx-anywhere-2s-mouse",
	sensitivity = -0.5, -- -1.0 - 1.0, 0 means no modification.
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
