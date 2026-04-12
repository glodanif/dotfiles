if [[ -z "$SSH_CONNECTION" ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
    exec dbus-run-session start-hyprland
fi

