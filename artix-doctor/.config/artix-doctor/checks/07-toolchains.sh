section "Development Toolchains"

command -v rustup &>/dev/null && ok "rustup installed" || err "rustup not installed"
command -v cargo &>/dev/null && ok "cargo available" || err "cargo not available"
command -v flutter &>/dev/null && ok "flutter in PATH" || err "flutter not in PATH"
command -v dart &>/dev/null && ok "dart in PATH" || warn "dart not in PATH"
command -v adb &>/dev/null && ok "adb in PATH" || warn "adb not in PATH"
command -v java &>/dev/null && ok "java in PATH" || warn "java not in PATH"

[[ -d ~/.jdks ]] && ok "~/.jdks exists" || warn "~/.jdks missing"
[[ -d ~/.android ]] && ok "~/.android exists" || warn "~/.android missing"

command -v espflash &>/dev/null && ok "espflash in PATH" || warn "espflash not in PATH"
rustup target list --installed 2>/dev/null | grep -q "riscv32imac-unknown-none-elf" && ok "riscv32imac-unknown-none-elf target installed" || warn "riscv32imac-unknown-none-elf target not installed (run: rustup target add riscv32imac-unknown-none-elf)"
