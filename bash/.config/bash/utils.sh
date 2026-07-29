# ── Output ────────────────────────────────────────────────
section() {
  local msg="$1"
  local color="${2:-\e[32m}"
  echo -e "${color}"
  echo -e "$msg"
  echo -e "─────────────────────────────────────────────\e[0m"
}

check() { echo -e "[ $1 ] $2\e[0m"; }
ok()    { check "\e[1;32mOK \e[0m" "$1"; }
fail()  { check "\e[1;31mERR\e[0m" "$1"; }
warn()  { check "\e[1;33mWRN\e[0m" "$1"; }

# ── Interaction ───────────────────────────────────────────
confirm() {
  local msg="${1:-Continue?}"
  read -r -p "$msg [Y/n] " reply
  # empty input = yes
  [[ -z "$reply" || "$reply" =~ ^[Yy]$ ]]
}

press_any_key() {
  sleep 0.2
  echo -n "${1:-Press any key to exit...}"
  if [[ -n "$ZSH_VERSION" ]]; then
    read -rsk 1
  else
    read -rsn 1
  fi
  echo
}

# ── Idle prevention ───────────────────────────────────────
# Hyprland's Lua config parses `hyprctl dispatch` arguments as Lua source, so
# dispatchers are hl.dsp.* calls — the legacy `dispatch <name> <args>` form errors
# with exit 7. allow_idle is a function so traps don't need nested quoting.
allow_idle() {
  hyprctl dispatch 'hl.dsp.window.tag({ tag = "-noidle" })' &>/dev/null || true
}

keep_screen_on() {
  hyprctl dispatch 'hl.dsp.window.tag({ tag = "+noidle" })' &>/dev/null || true
  trap allow_idle EXIT
}

