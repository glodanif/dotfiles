if [[ -z "$SSH_CONNECTION" ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
    mkdir -p ~/.local/share/hyprland
    exec dbus-run-session start-hyprland > ~/.local/share/hyprland/hyprland.log 2>&1
fi

