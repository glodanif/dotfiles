hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.animation({
	leaf = "global",
	enabled = true,
	speed = 10,
	bezier = "default",
})
hl.animation({
	leaf = "border",
	enabled = true,
	speed = 5.39,
	bezier = "easeOutQuint",
})
hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 4.79,
	bezier = "easeOutQuint",
})
hl.animation({
	leaf = "windowsIn",
	enabled = true,
	speed = 4.1,
	bezier = "easeOutQuint",
	style = "popin 87%",
})
hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 1.49,
	bezier = "linear",
	style = "popin 87%",
})
hl.animation({
	leaf = "fadeIn",
	enabled = true,
	speed = 1.73,
	bezier = "almostLinear",
})
hl.animation({
	leaf = "fadeOut",
	enabled = true,
	speed = 1.46,
	bezier = "almostLinear",
})
hl.animation({
	leaf = "fade",
	enabled = true,
	speed = 3.03,
	bezier = "quick",
})
hl.animation({
	leaf = "layers",
	enabled = true,
	speed = 3.81,
	bezier = "easeOutQuint",
})
hl.animation({
	leaf = "layersIn",
	enabled = true,
	speed = 4,
	bezier = "easeOutQuint",
	style = "fade",
})
hl.animation({
	leaf = "layersOut",
	enabled = true,
	speed = 1.5,
	bezier = "linear",
	style = "fade",
})
hl.animation({
	leaf = "fadeLayersIn",
	enabled = true,
	speed = 1.79,
	bezier = "almostLinear",
})
hl.animation({
	leaf = "fadeLayersOut",
	enabled = true,
	speed = 1.39,
	bezier = "almostLinear",
})
hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 1.94,
	bezier = "almostLinear",
	style = "fade",
})
hl.animation({
	leaf = "workspacesIn",
	enabled = true,
	speed = 1.21,
	bezier = "almostLinear",
	style = "fade",
})
hl.animation({
	leaf = "workspacesOut",
	enabled = true,
	speed = 1.94,
	bezier = "almostLinear",
	style = "fade",
})
hl.animation({
	leaf = "zoomFactor",
	enabled = true,
	speed = 7,
	bezier = "quick",
})

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 8,
		border_size = 2,
		-- https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors
		col = {
			active_border = { colors = { "rgba(66b2ffaa)", "rgba(66b2ff77)" }, angle = 45 },
			inactive_border = "rgba(59595900)",
		},
		-- Set to true enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = false,
		-- Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
		allow_tearing = false,
		layout = "dwindle",
	},
	-- Native tabbed window groups (replaces hy3 tab styling from the old plugins.conf)
	group = {
		col = {
			border_active = "rgba(66b2ffaa)",
			border_inactive = "rgba(595959aa)",
			border_locked_active = "rgba(ff5b61aa)",
		},
		groupbar = {
			enabled = true,
			font_size = 11,
			height = 18,
			indicator_height = 0, -- no underline strip under the active tab
			gradients = true,
			rounding = 8,
			gradient_rounding = 8, -- match rounding so fills aren't near-rectangles
			round_only_edges = false, -- round each tab individually (pills)
			gradient_round_only_edges = false,
			text_color = "rgba(ffffffff)",
			col = {
				active = "rgba(66b2ffff)", -- opaque, not the muddy 77 alpha
				inactive = "rgba(454545ff)",
				locked_active = "rgba(ff5b61ff)",
			},
		},
	},
	-- https://wiki.hypr.land/Configuring/Variables/#decoration
	decoration = {
		rounding = 10,
		rounding_power = 2,
		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		-- https://wiki.hypr.land/Configuring/Variables/#blur
		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},
	-- https://wiki.hypr.land/Configuring/Variables/#animations
	animations = {
		enabled = true,
		-- Default curves, see https://wiki.hypr.land/Configuring/Animations/#curves
		--        NAME,           X0,   Y0,   X1,   Y1
		-- Default animations, see https://wiki.hypr.land/Configuring/Animations/
		--           NAME,          ONOFF, SPEED, CURVE,        [STYLE]
	},
	-- Ref https://wiki.hypr.land/Configuring/Workspace-Rules/
	-- "Smart gaps" / "No gaps when only"
	-- uncomment all if you wish to use that.
	-- workspace = w[tv1], gapsout:0, gapsin:0
	-- workspace = f[1], gapsout:0, gapsin:0
	-- windowrule {
	--     name = no-gaps-wtv1
	--     match:float = false
	--     match:workspace = w[tv1]
	--
	--     border_size = 0
	--     rounding = 0
	-- }
	--
	-- windowrule {
	--     name = no-gaps-f1
	--     match:float = false
	--     match:workspace = f[1]
	--
	--     border_size = 0
	--     rounding = 0
	-- }
	-- See https://wiki.hypr.land/Configuring/Dwindle-Layout/ for more
	dwindle = {
		preserve_split = true, -- You probably want this
	},
	-- See https://wiki.hypr.land/Configuring/Master-Layout/ for more
	master = {
		new_status = "master",
	},
	-- https://wiki.hypr.land/Configuring/Variables/#misc
	misc = {
		force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
		-- Walker runs as a persistent gapplication-service, so apps launched from it
		-- inherit a stale boot-time workspace token and open on the wrong monitor
		-- (esp. right after a display-mode switch). Disable tracking so new windows
		-- always open on the currently focused workspace.
		initial_workspace_tracking = 0,
	},
})
