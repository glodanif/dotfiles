local programs = require("programs")

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(
	mainMod .. " + SHIFT + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + ALT + RETURN", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(programs.menu))
-- bind = $mainMod, P, pseudo, # dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("monitors-layout-toggle"))
hl.bind(
	mainMod .. " + B",
	hl.dsp.exec_cmd(programs.browser .. " --enable-features=WebRTCPipeWireCapturer --profile-directory=Default")
)
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(programs.terminal .. " -e " .. programs.tasks))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + ALT + SPACE", hl.dsp.exec_cmd("walker --provider menus:main"))

-- TAB cycles focus through the windows of the active monitor's workspace (was hy3:togglefocuslayer).
-- Both dispatchers live in one callback so the raise always happens after the focus change;
-- as two separate binds on the same key the order is up to Hyprland.
hl.bind("SUPER + TAB", function()
	hl.dispatch(hl.dsp.window.cycle_next({ next = true }))
	hl.dispatch(hl.dsp.window.bring_to_top())
end, { description = "Cycle focus to next window" })

-- Reverse cycle. code:23 is TAB — with SHIFT held the keysym becomes ISO_Left_Tab, the
-- keycode does not, so the name "TAB" would not match here.
-- cycle_next has no `prev` field: it is silently ignored and yields a forward cycle,
-- so reverse has to be spelled next = false.
-- No bring_to_top here, unlike the forward bind: cycle_next walks the z-order list, and
-- raising the window it just landed on pushes it past the one behind it, so the next
-- press comes straight back — you ping-pong between two windows instead of cycling.
hl.bind("SUPER + SHIFT + code:23", function()
	hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
end, { description = "Cycle focus to previous window" })

-- Move workspaces to other monitors
hl.bind("SUPER + ALT + LEFT", function()
	local w = hl.get_active_workspace()
	if not w then
		return
	end
	hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = "l" }))
end, { description = "Move workspace to left monitor" })
hl.bind("SUPER + ALT + RIGHT", function()
	local w = hl.get_active_workspace()
	if not w then
		return
	end
	hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = "r" }))
end, { description = "Move workspace to right monitor" })
hl.bind("SUPER + ALT + UP", function()
	local w = hl.get_active_workspace()
	if not w then
		return
	end
	hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = "u" }))
end, { description = "Move workspace to up monitor" })
hl.bind("SUPER + ALT + DOWN", function()
	local w = hl.get_active_workspace()
	if not w then
		return
	end
	hl.dispatch(hl.dsp.workspace.move({ workspace = w.id, monitor = "d" }))
end, { description = "Move workspace to down monitor" })

-- Move window within the layout
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))

-- Move window, entering/leaving groups in the way (was hy3 "visible" variant)
hl.bind(mainMod .. " + CONTROL + SHIFT + left", hl.dsp.window.move({ into_or_create_group = "l" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + down", hl.dsp.window.move({ into_or_create_group = "d" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + up", hl.dsp.window.move({ into_or_create_group = "u" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + right", hl.dsp.window.move({ into_or_create_group = "r" }))

-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Window groups — native Hyprland tabbed groups (replaces hy3 containers)
hl.bind(mainMod .. " + z", hl.dsp.group.toggle())
hl.bind(mainMod .. " + d", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + s", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + a", hl.dsp.group.next())
hl.bind(mainMod .. " + SHIFT + a", hl.dsp.group.prev())
hl.bind(mainMod .. " + x", hl.dsp.group.lock_active({ action = "toggle" }))
hl.bind(mainMod .. " + e", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + e", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + r", hl.dsp.window.move({ out_of_group = true }))

hl.bind("Print", hl.dsp.exec_cmd("take-screenshot"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | walker --dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("power-menu"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("mic-toggle"))

-- Resize active window
hl.bind(
	"SUPER + code:34",
	hl.dsp.window.resize({ x = -100, y = 0, relative = true }),
	{ description = "Expand window left" }
)
hl.bind(
	"SUPER + code:35",
	hl.dsp.window.resize({ x = 100, y = 0, relative = true }),
	{ description = "Shrink window left" }
)
hl.bind(
	"SUPER + SHIFT + code:34",
	hl.dsp.window.resize({ x = 0, y = -100, relative = true }),
	{ description = "Shrink window up" }
)
hl.bind(
	"SUPER + SHIFT + code:35",
	hl.dsp.window.resize({ x = 0, y = 100, relative = true }),
	{ description = "Expand window down" }
)

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())
-- Scroll over a group's titlebar to switch tabs (native groupbar)
hl.bind(mainMod .. " + mouse_down", hl.dsp.group.prev())
hl.bind(mainMod .. " + mouse_up", hl.dsp.group.next())
-- NOTE: hy3:warpcursor had no native equivalent — SUPER+Q is now free to rebind

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Alt+Shift switches keyboard layout on ALL keyboards, kept in sync by layout-switch
-- (replaces xkb grp:alt_shift_toggle, which only switched the keyboard being pressed)
hl.bind("ALT + SHIFT_L", hl.dsp.exec_cmd("layout-switch"))
hl.bind("ALT + SHIFT_R", hl.dsp.exec_cmd("layout-switch"))
hl.bind("SHIFT + ALT_L", hl.dsp.exec_cmd("layout-switch"))
hl.bind("SHIFT + ALT_R", hl.dsp.exec_cmd("layout-switch"))
