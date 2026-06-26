local mainMod = require("config.constants").mainMod

local function setup_hyprexpo()
	if hl.plugin.hyprexpo == nil then
		return
	end

	hl.config({
		plugin = {
			hyprexpo = {
				columns = 3,
				gaps_in = 0,
				gaps_out = 0,
				bg_col = "rgb(111111)",
				workspace_method = "first 1",
				gesture_distance = 200,
				cancel_key = "escape",
				show_cursor = 1,
			},
		},
	})

	hl.bind(mainMod .. "+ tab", function()
		hl.plugin.hyprexpo.expo("toggle")
	end)

	hl.gesture({
		fingers = 3,
		direction = "up",
		action = function()
			hl.plugin.hyprexpo.expo("open")
		end,
	})

	hl.gesture({
		fingers = 3,
		direction = "down",
		action = function()
			hl.plugin.hyprexpo.expo("close")
		end,
	})

	hl.define_submap("hyprexpo", function()
		hl.bind("h", function()
			hl.plugin.hyprexpo.kb_focus("left")
		end)
		hl.bind("l", function()
			hl.plugin.hyprexpo.kb_focus("right")
		end)
		hl.bind("k", function()
			hl.plugin.hyprexpo.kb_focus("up")
		end)
		hl.bind("j", function()
			hl.plugin.hyprexpo.kb_focus("down")
		end)
		hl.bind("return", function()
			hl.plugin.hyprexpo.kb_confirm()
		end)
		hl.bind("escape", function()
			hl.plugin.hyprexpo.expo("cancel")
		end)
	end)
end

local function setup_dynamic_cursors()
	if hl.plugin.dynamic_cursors == nil then
		return
	end

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

setup_hyprexpo()
setup_dynamic_cursors()
