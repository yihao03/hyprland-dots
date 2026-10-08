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

		touchpad = {
			natural_scroll = true,
			clickfinger_behavior = true,
		},
	},
})

hl.device({
	name = " mx-anywhere-2s-mouse",
	sensitivity = -0.5, -- -1.0 - 1.0, 0 means no modification.
	accel_profile = "flat",
})

hl.device({
	name = "syna2ba6:00-06cb:cf00-touchpad",
	sensitivity = 0.2,
	accel_profile = "adaptive",
	drag_lock = 1,
})

hl.device({
	name = "at-translated-set-2-keyboard",
	kb_options = "caps:swapescape",
	resolve_binds_by_sym = true,
})
