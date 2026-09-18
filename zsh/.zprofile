export GPG_TTY=$(tty)
if [[ -z "$SSH_CONNECTION" ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
    mkdir -p ~/.local/share/hyprland
    logfile=~/.local/share/hyprland/hyprland-$(date +%Y%m%d-%H%M%S).log
    ls -t ~/.local/share/hyprland/hyprland-*.log 2>/dev/null | tail -n +20 | xargs -r rm -f
    # exec: leave no shell on tty1. If the VT keyboard is ever live again
    # (see 22-seat.sh), a parked shell would queue every keystroke and run
    # it as a command once the session exits.
    exec dbus-run-session start-hyprland > "$logfile" 2>&1
fi

