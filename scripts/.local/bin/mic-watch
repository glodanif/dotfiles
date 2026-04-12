#!/bin/zsh

SOURCE="alsa_input.usb-0c76_USB_PnP_Audio_Device-00.mono-fallback"

print_status() {
    MUTED=$(pactl get-source-mute "$SOURCE" | grep -c "yes")
    ACTIVE=$(pactl list source-outputs | grep -c "Source Output #")

    if [ "$ACTIVE" -gt 0 ]; then
        [ "$MUTED" -eq 1 ] &&
            echo '{"text":"","class":"muted","tooltip":"Mic in use (muted)"}' ||
            echo '{"text":"","class":"active","tooltip":"Mic in use"}'
    else
        echo '{"text":"","class":"idle","tooltip":""}'
    fi
}

print_status

pactl subscribe | while read -r line; do
    case "$line" in
        *"on source #"*|*"on source-output #"*)
            kill $TIMER_PID 2>/dev/null
            { sleep 0.3; print_status; } &
            TIMER_PID=$!
            ;;
    esac
done
