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
