local mode = require("display-mode")

-- Workspace-to-monitor placement for the current display mode. "default" marks which
-- workspace each monitor comes up with. Declaring this is what makes startup
-- deterministic: monitors-layout-toggle's moveworkspacetomonitor passes cannot hold
-- an empty workspace, so without these rules ws1 kept landing on the wrong output.
if mode == "tv" then
	hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1", default = true })
	for i = 2, 7 do
		hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1" })
	end
else
	hl.workspace_rule({ workspace = "1", monitor = "DP-2", default = true })
	hl.workspace_rule({ workspace = "2", monitor = "DP-1", default = true })
	for i = 3, 7 do
		hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1" })
	end
end

hl.window_rule({
	name = "suppress-maximize-events",
	match = {
		class = ".*",
	},
	-- Ignore maximize requests from all apps. You'll probably like this.
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	-- Fix some dragging issues with XWayland
	no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = {
		class = "hyprland-run",
	},
	move = "20 monitor_h-120",
	float = true,
})

hl.window_rule({
	name = "float-run",
	match = {
		title = ".* - float$",
	},
	float = true,
	center = true,
	size = "1024 650",
	immediate = true,
})

hl.window_rule({
	name = "thunar-process",
	match = {
		class = "^thunar$",
		title = "^File Operation Progress$",
	},
	float = true,
})

hl.window_rule({
	name = "thunar-rename",
	match = {
		class = "^thunar$",
		title = "^Rename.*",
	},
	float = true,
})

hl.window_rule({
	name = "xdg-file-picker",
	match = {
		class = "^xdg-desktop-portal-gtk$",
	},
	float = true,
	center = true,
	size = "1024 700",
})
