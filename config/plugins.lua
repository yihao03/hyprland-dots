local constants = require("config.constants")
local utils = require("config.utils")
local main_mod = constants.main_mod
local lt = utils.lt
local gt = utils.gt
local if_neighbor = utils.if_neighbor
local if_any_neighbor = utils.if_any_neighbor
local layout_binding = utils.layout_binding
local toggle_tiled_layout = utils.toggle_tiled_layout

local function setup_hyprscroll_overview()
	if hl.plugin.scrolloverview == nil then return end
	local so = hl.plugin.scrolloverview

	-- .config/hypr/hyprland.lua
	hl.config({
		plugin = {
			scrolloverview = {
				gesture_distance = 100, -- how far is the "max" for the gesture
				scale = 0.3, -- preferred overview scale
				workspace_gap = 20,
				layout = "vertical", -- vertical or horizontal
				wallpaper = 0, -- 0: global only, 1: per-workspace only, 2: both
				blur = true, -- blur only the main overview wallpaper

				shadow = {
					enabled = false,
					range = 50,
					render_power = 3,
					color = 0xee1a1a1a,
				},
			},
		},
	})

	hl.gesture({
		fingers = 3,
		direction = "pinchout",
		action = function() hl.dispatch(so.overview("on all")) end,
	})

	hl.gesture({
		fingers = 3,
		direction = "pinchin",
		action = function() hl.dispatch(so.overview("off")) end,
	})

	hl.bind(main_mod .. " + tab", function() so.overview("toggle all") end)

	hl.define_submap("scrolloverview", function()
		-- navigate the overview
		hl.bind("h", so.navigate("left"))
		hl.bind("l", so.navigate("right"))
		hl.bind("k", so.navigate("up"))
		hl.bind("j", so.navigate("down"))

		-- move the windows
		hl.bind(
			main_mod .. " + H",
			layout_binding({
				dwindle = hl.dsp.window.move({ direction = "left" }),
				scrolling = if_any_neighbor("y", hl.dsp.window.move({ direction = "left" }), hl.dsp.layout("swapcol l")),
			})
		)
		hl.bind(
			main_mod .. " + L",
			layout_binding({
				dwindle = hl.dsp.window.move({ direction = "right" }),
				scrolling = if_any_neighbor("y", hl.dsp.window.move({ direction = "right" }), hl.dsp.layout("swapcol r")),
			})
		)
		local move_up_or_workspace =
			if_neighbor("y", lt, hl.dsp.window.move({ direction = "up" }), hl.dsp.window.move({ workspace = "r-1" }))
		local move_down_or_workspace =
			if_neighbor("y", gt, hl.dsp.window.move({ direction = "down" }), hl.dsp.window.move({ workspace = "r+1" }))
		hl.bind(
			main_mod .. " + K",
			layout_binding({
				dwindle = move_up_or_workspace,
				scrolling = move_up_or_workspace,
			})
		)
		hl.bind(
			main_mod .. " + J",
			layout_binding({
				dwindle = move_down_or_workspace,
				scrolling = move_down_or_workspace,
			})
		)
		hl.bind(
			"T",
			layout_binding({
				dwindle = hl.dsp.layout("togglesplit"),
				scrolling = hl.dsp.layout("consume_or_expel prev"),
			})
		)
		hl.bind("SHIFT + T", toggle_tiled_layout)
		hl.bind("d", hl.dsp.window.close())

		hl.bind("return", so.overview("off"))
		hl.bind("escape", so.overview("off"))
		hl.bind("mouse:272", function()
			so.overview("select")
			so.overview("off")
		end, { mouse = true })
		hl.bind("mouse:274", function() so.window("close") end, { mouse = true })
	end)
end

local function setup_dynamic_cursors()
	if hl.plugin.dynamic_cursors == nil then return end

	hl.config({
		plugin = {
			dynamic_cursors = {

				-- enables the plugin
				enabled = true,

				-- sets the cursor behaviour, supports these values:
				-- tilt    - tilt the cursor based on x-velocity
				-- rotate  - rotate the cursor based on movement direction
				-- stretch - stretch the cursor shape based on direction and velocity
				-- none    - do not change the cursor's behaviour
				mode = "tilt",

				-- minimum angle difference in degrees after which the shape is changed
				-- smaller values are smoother, but more expensive for hw cursors
				threshold = 2,

				-- for mode = "rotate"
				rotate = {

					-- length in px of the simulated stick used to rotate the cursor
					-- most realistic if this is your actual cursor size
					length = 20,

					-- clockwise offset applied to the angle in degrees
					-- this will apply to ALL shapes
					offset = 0.0,
				},

				-- for mode = "tilt"
				tilt = {

					-- controls how powerful the tilt is, the lower, the more power
					-- this value controls at which speed (px/s) the full tilt is reached
					limit = 3000,

					-- relationship between speed and tilt, supports these values:
					-- linear             - a linear function is used
					-- quadratic          - a quadratic function is used (most realistic to actual air drag)
					-- negative_quadratic - negative version of the quadratic one, feels more aggressive
					-- see `activation` in `src/mode/utils.cpp` for how exactly the calculation is done
					activation = "negative_quadratic",

					-- time window (ms) over which the speed is calculated
					-- higher values will make slow motions smoother but more delayed
					window = 100,

					-- full tilt for each side (°)
					full = 60,
				},

				-- for mode = "stretch"
				stretch = {

					-- controls how much the cursor is stretched
					-- this value controls at which speed (px/s) the full stretch is reached
					-- the full stretch being twice the original length
					limit = 3000,

					-- relationship between speed and stretch amount, supports these values:
					-- linear             - a linear function is used
					-- quadratic          - a quadratic function is used
					-- negative_quadratic - negative version of the quadratic one, feels more aggressive
					-- see `activation` in `src/mode/utils.cpp` for how exactly the calculation is done
					activation = "quadratic",

					-- time window (ms) over which the speed is calculated
					-- higher values will make slow motions smoother but more delayed
					window = 100,
				},

				-- configure shake to find
				-- magnifies the cursor if its is being shaken
				shake = {
					-- enables shake to find
					enabled = true,

					-- controls how soon a shake is detected
					-- lower values mean sooner
					threshold = 4.0,

					-- magnification level immediately after shake start
					base = 2.0,
					-- magnification increase per second when continuing to shake
					speed = 4.0,
					-- how much the speed is influenced by the current shake intensity
					influence = 2.0,

					-- maximal magnification the cursor can reach
					-- values below 1 disable the limit (e.g. 0)
					limit = 0.0,

					-- time in milliseconds the cursor will stay magnified after a shake has ended
					timeout = 300,

					-- show cursor behaviour `tilt`, `rotate`, etc. while shaking
					effects = false,

					-- enable ipc events for shake
					-- see the `ipc` section below
					ipc = false,
				},

				-- use hyprcursor to get a higher resolution texture when the cursor is magnified
				-- see the `hyprcursor` section below
				hyprcursor = {

					-- use nearest-neighbour (pixelated) scaling when magnifying beyond texture size
					-- this will also have effect without hyprcursor support being enabled
					-- 0 - never use pixelated scaling
					-- 1 - use pixelated when no highres image
					-- 2 - always use pixelated scaling
					nearest = 1,

					-- enable dedicated hyprcursor support
					enabled = true,

					-- resolution in pixels to load the magnified shapes at
					-- be warned that loading a very high-resolution image will take a long time and might impact memory consumption
					-- -1 means we use [normal cursor size] * [shake:base option]
					resolution = -1,

					-- shape to use when clientside cursors are being magnified
					-- see the shape-name property of shape rules for possible names
					-- specifying clientside will use the actual shape, but will be pixelated
					fallback = "clientside",
				},
			},
		},
	})
end

local function setup_glass()
	if not hl.plugin.hyprglass then return end
	local hg = hl.plugin.hyprglass

	hg.config({
		enabled = false,
		default_theme = "dark",
		default_preset = "clear",
		tint_color = 0x8899aa22,

		brightness = 0.9,
		dark = { brightness = 0.82 },
		light = { adaptive_boost = 0.5 },

		layers = { enabled = 1 },
	})

	-- Presets
	hg.preset("clear", {
		glass_opacity = 0.8,
		blur_strength = 1.5,
		dark = { brightness = 0.7 },
		light = { brightness = 1.2 },
	})

	hg.preset("glass", {
		chromatic_aberration = 0.4,
		blur_strength = 0.7,
		blur_iterations = 2,
		lens_distortion = 0.3,
		refraction_strength = 5.0,
		fresnel_strength = 0.4,
		specular_strength = 0.8,
		glass_opacity = 1.0,
		edge_thickness = 0.03,
		tint_color = 0xffffff00,
	})

	hg.preset("notification-glass", {
		chromatic_aberration = 0.2,
		blur_strength = 0.5,
		blur_iterations = 2,
		lens_distortion = 2.0,
		refraction_strength = 2,
		fresnel_strength = 0.4,
		specular_strength = 0.8,
		glass_opacity = 1.0,
		edge_thickness = 0.03,
		tint_color = 0xffffff00,
	})

	hg.preset("contrasted", {
		inherits = "high_contrast",
		contrast = 1.2,
		adaptive_dim = 1.5,
		dark = { tint_color = 0x02142aa9 },
	})

	-- Layer surfaces: each call whitelists the namespace and configures it
	hg.layer(
		"noctalia-notification",
		{ preset = "notification-glass", mask_threshold = 0.3, realtime = true, realtime_fps = 30 }
	)
	hg.layer("noctalia-panel", { preset = "glass", mask_threshold = 0.3, realtime = true, realtime_fps = 30 })
end

setup_hyprscroll_overview()
setup_dynamic_cursors()
setup_glass()
