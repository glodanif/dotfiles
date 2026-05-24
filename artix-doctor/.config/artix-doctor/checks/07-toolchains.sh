section "Development Toolchains"

command -v rustup &>/dev/null && ok "rustup installed" || err "rustup not installed" "Install:" "sudo pacman -S rustup"
command -v cargo &>/dev/null && ok "cargo available" || err "cargo not available" "Install a default toolchain:" "rustup default stable"
command -v flutter &>/dev/null && ok "flutter in PATH" || err "flutter not in PATH" "Install Flutter and add its bin/ directory to PATH."
command -v dart &>/dev/null && ok "dart in PATH" || warn "dart not in PATH" "Ships with Flutter — ensure flutter/bin is on PATH."
command -v adb &>/dev/null && ok "adb in PATH" || warn "adb not in PATH" "Install:" "sudo pacman -S android-tools"
command -v java &>/dev/null && ok "java in PATH" || warn "java not in PATH" "Install a JDK:" "sudo pacman -S jdk-openjdk"

[[ -d ~/.jdks ]] && ok "~/.jdks exists" || warn "~/.jdks missing" "Created when a JDK is installed via JetBrains IDEs, or:" "mkdir -p ~/.jdks"
[[ -d ~/.android ]] && ok "~/.android exists" || warn "~/.android missing" "Created on first adb/Android Studio run, or:" "mkdir -p ~/.android"

command -v espflash &>/dev/null && ok "espflash in PATH" || warn "espflash not in PATH" "Install:" "cargo install espflash"
rustup target list --installed 2>/dev/null | grep -q "riscv32imac-unknown-none-elf" && ok "riscv32imac-unknown-none-elf target installed" || warn "riscv32imac-unknown-none-elf target not installed" "Add it:" "rustup target add riscv32imac-unknown-none-elf"
