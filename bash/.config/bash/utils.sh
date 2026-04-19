# ── Output ────────────────────────────────────────────────
section() {
  local msg="$1"
  local color="${2:-\e[32m}"
  echo -e "${color}"
  echo -e "$msg"
  echo -e "─────────────────────────────────────────────\e[0m"
}

check() { echo "[ $1 ] $2"; }
ok()    { check "OK " "$1"; }
fail()  { check "ERR" "$1"; }
warn()  { check "WRN" "$1"; }

# ── Interaction ───────────────────────────────────────────
confirm() {
  local msg="${1:-Continue?}"
  read -r -p "$msg [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

press_any_key() {
  sleep 0.2
  echo -n "${1:-Press any key to exit...}"
  read -r -n 1
  echo
}

# ── Idle prevention ───────────────────────────────────────
keep_screen_on() {
  hyprctl dispatch tagwindow +noidle &>/dev/null || true
  trap 'hyprctl dispatch tagwindow -- -noidle &>/dev/null || true' EXIT
}

