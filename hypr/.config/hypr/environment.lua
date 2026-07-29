-- hl.env passes values through literally — unlike hyprlang, it does not expand
-- $HOME / $XDG_RUNTIME_DIR — so resolve them here.
local home = os.getenv("HOME")
local runtimeDir = os.getenv("XDG_RUNTIME_DIR")

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("PATH", home .. "/.cargo/bin:/usr/local/bin:/usr/bin:/bin:" .. home .. "/.local/bin")
hl.env("SSH_AUTH_SOCK", runtimeDir .. "/gcr/ssh")
