hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

hl.device({
	name = "logitech-usb-receiver-mouse",
	sensitivity = 0.15,
	accel_profile = "custom 0.2 0.0 0.15 0.5 1.4 2.0 2.6",
})

hl.config({
	input = {
		kb_layout = "us,ru,ua",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 1,
		numlock_by_default = true,
		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
		touchpad = {
			natural_scroll = false,
		},
	},
	-- See https://wiki.hypr.land/Configuring/Gestures
})
