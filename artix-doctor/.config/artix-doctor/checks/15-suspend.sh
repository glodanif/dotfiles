section "Suspend / Resume"

# hypridle drives the whole idle chain (screensaver -> dpms -> lock -> suspend);
# if it isn't running, none of those timeouts fire.
if pgrep -x hypridle &>/dev/null; then
    ok "hypridle running (idle -> suspend chain active)"
else
    warn "hypridle not running (idle screensaver/lock/suspend will not fire)" "Start it (usually via Hyprland exec-once):" "hypridle &"
fi

# The elogind system-sleep hook restores the NVIDIA GPU on resume; if a driver
# update drops it, clients can come back corrupted after wake.
if [[ -x /usr/lib/elogind/system-sleep/nvidia ]]; then
    ok "elogind NVIDIA sleep hook present (GPU restored on resume)"
else
    warn "elogind NVIDIA sleep hook missing (GPU clients may break on resume)" "Reinstall the driver utils to restore the hook:" "sudo pacman -S nvidia-utils"
fi
