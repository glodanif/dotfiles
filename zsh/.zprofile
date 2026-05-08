if [[ -z "$SSH_CONNECTION" ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
    mkdir -p ~/.local/share/hyprland
    logfile=~/.local/share/hyprland/hyprland-$(date +%Y%m%d-%H%M%S).log
    ls -t ~/.local/share/hyprland/hyprland-*.log 2>/dev/null | tail -n +20 | xargs -r rm -f
    exec dbus-run-session start-hyprland > "$logfile" 2>&1
fi

