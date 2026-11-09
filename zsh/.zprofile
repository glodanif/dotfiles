export GPG_TTY=$(tty)
if [[ -z "$SSH_CONNECTION" ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
    mkdir -p ~/.local/share/hyprland
    logfile=~/.local/share/hyprland/hyprland-$(date +%Y%m%d-%H%M%S).log
    ls -t ~/.local/share/hyprland/hyprland-*.log 2>/dev/null | tail -n +20 | xargs -r rm -f
    # exec: leave no shell on tty1. If the VT keyboard is ever live again
    # (see 22-seat.sh), a parked shell would queue every keystroke and run
    # it as a command once the session exits.
    # 0.57 runs the main thread SCHED_RR with RLIMIT_RTTIME 150/200ms; an NVIDIA
    # HDMI connector probe (TV hotplug / FRL training) spins >200ms in-kernel and
    # the kernel SIGKILLs Hyprland → safe mode. Drop once hyprwm/Hyprland#16737 ships.
    # https://github.com/hyprwm/Hyprland/discussions/16648
    export HYPRLAND_NO_RT=1
    exec dbus-run-session start-hyprland > "$logfile" 2>&1
fi

