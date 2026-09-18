section "Seat & login"

# The compositor's seat (elogind via libseat) sets tty1's keyboard to K_OFF.
# If it's live, every keystroke also lands in tty1's line discipline — typed
# text leaks to the console and a stray ^C SIGINTs the session.
if pgrep -x Hyprland &>/dev/null; then
    kbd_mode -C /dev/tty1 2>/dev/null | grep -q Disabled \
        && ok "tty1 keyboard disabled while compositor runs" \
        || err "tty1 keyboard still live — keystrokes leak into the VT" \
               "Fix any system/ drift below, then reboot:" "cd ~/dotfiles && ./refresh.sh"
fi

# Root-owned files tracked under system/ (greetd config + conf.d: config kept
# out of $HOME, plymouth quit before sessions start). Drift means the fix
# above isn't actually live.
for f in $HOME/dotfiles/system/**/*(.N); do
    t=/${f#$HOME/dotfiles/system/}
    [[ "$(stat -c %U "$t" 2>/dev/null)" == root ]] && cmp -s "$f" "$t" \
        && ok "$t matches repo" \
        || err "$t missing, not root-owned, or differs from repo" "Apply:" "cd ~/dotfiles && ./refresh.sh"
done
