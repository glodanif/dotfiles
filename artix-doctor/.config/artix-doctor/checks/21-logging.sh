section "Logging"

# syslog-ng starts cleanly and reports "status: started" even when every log{}
# path in its config is commented out — which is the Artix default. The daemon
# then writes nothing at all, and the first time you find out is when you go
# looking for the kernel log after a hang and /var/log turns out to be empty.
sng_conf=/etc/syslog-ng/syslog-ng.conf
if [[ -f $sng_conf ]]; then
    # Block *definitions* read "destination d_x {"; only the references inside
    # log{} read "destination(d_x);", so this matches wiring, not declarations.
    if grep -v '^[[:space:]]*#' "$sng_conf" | grep -q 'destination('; then
        ok "syslog-ng has an active log path"
    else
        err "syslog-ng runs but every log{} path is commented out — nothing is being logged" "Uncomment a destination in $sng_conf, then:" "sudo rc-service syslog-ng restart"
    fi

    # A destination can be wired up and still produce nothing (bad perms, full
    # disk, daemon wedged). Only the file's mtime proves it is really writing.
    if grep -v '^[[:space:]]*#' "$sng_conf" | grep -q 'destination(d_everything)'; then
        if [[ ! -f /var/log/everything.log ]]; then
            err "d_everything is wired up but /var/log/everything.log does not exist" "Restart the daemon and read the errors:" "sudo rc-service syslog-ng restart"
        elif [[ -n $(find /var/log/everything.log -mmin -1440 2>/dev/null) ]]; then
            ok "/var/log/everything.log written within 24h"
        else
            warn "/var/log/everything.log untouched for 24h — syslog-ng may be wedged" "Restart it:" "sudo rc-service syslog-ng restart"
        fi
    fi
fi

# The point of keeping a log is capturing a kernel oops or an Alt+SysRq+W
# blocked-task dump when the machine wedges. That only works if syslog-ng's
# system() source actually picks up /dev/kmsg; if it doesn't, every other
# assertion here still passes and the log is useless for diagnosing a hang.
if [[ -f /var/log/everything.log ]]; then
    if [[ -r /var/log/everything.log ]]; then
        kern_lines=$(grep -c ' kernel: ' /var/log/everything.log 2>/dev/null)
    elif sudo -n true 2>/dev/null; then
        kern_lines=$(sudo -n grep -c ' kernel: ' /var/log/everything.log 2>/dev/null)
    else
        kern_lines=""
    fi

    if [[ -z $kern_lines ]]; then
        warn "cannot read /var/log/everything.log to confirm kernel messages are captured" "Join the log group (takes effect at next login):" "sudo gpasswd -a $(id -un) log"
    elif (( kern_lines > 0 )); then
        ok "kernel messages reaching the log ($kern_lines lines)"
    else
        err "no kernel messages in the log — an oops or SysRq dump would not survive a reboot" "Check that the system() source reads /dev/kmsg:" "grep -n 'system()' $sng_conf"
    fi
fi

# Without magic SysRq the only way out of a wedged shutdown is the power
# button, which destroys the unsynced tail of the very log that would have
# explained it. SysRq+W (blocked task dump) is what names the stuck service.
sysrq=$(cat /proc/sys/kernel/sysrq 2>/dev/null || echo 0)
if [[ ${sysrq:-0} -ne 0 ]]; then
    ok "magic SysRq enabled (kernel.sysrq=$sysrq)"
else
    err "magic SysRq disabled — no REISUB and no SysRq+W task dump when the machine wedges" "Enable it persistently:" "echo 'kernel.sysrq=1' | sudo tee /etc/sysctl.d/99-sysrq.conf && sudo sysctl --system"
fi

# /etc/logrotate.d/syslog-ng ships with the syslog-ng package, but logrotate is
# a separate package and Arch/Artix ship only a systemd timer to drive it — so
# on OpenRC nothing ever runs it and everything.log grows without bound on the
# root filesystem. The rules being present is not the same as them firing.
if command -v logrotate &>/dev/null; then
    ok "logrotate installed"
    lr_hook=/etc/cron.daily/logrotate
    if [[ -x $lr_hook ]]; then
        ok "logrotate cron.daily hook present"
    else
        err "logrotate installed but nothing runs it — Artix ships only a systemd timer" "Create the hook:" "printf '#!/bin/sh\\nexec /usr/bin/logrotate /etc/logrotate.conf\\n' | sudo tee $lr_hook && sudo chmod +x $lr_hook"
    fi
else
    err "logrotate not installed — /var/log/everything.log will grow without bound" "Install it:" "sudo pacman -S logrotate"
fi

# greetd owns a VT outright. An agetty respawning on the same tty fights it for
# keystrokes: both print a login prompt and each key goes to whichever reader
# wins, so the console looks alive but accepts nothing. The symptom (dead
# keyboard, working Ctrl+Alt+Fn) looks like a kernel fault and is not.
greetd_conf=$(sed -n 's/.*--config \([^"]*\).*/\1/p' /etc/conf.d/greetd 2>/dev/null)
[[ -z $greetd_conf ]] && greetd_conf=/etc/greetd/config.toml
greetd_vt=$(grep -oE '^[[:space:]]*vt[[:space:]]*=[[:space:]]*[0-9]+' "$greetd_conf" 2>/dev/null | grep -oE '[0-9]+$')
if [[ -n $greetd_vt ]]; then
    if rc-update show default 2>/dev/null | grep -qE "^\s*agetty\.tty$greetd_vt\s"; then
        err "agetty.tty$greetd_vt and greetd both own vt$greetd_vt — they race for keystrokes and the console accepts no input" "Drop the agetty:" "sudo rc-update del agetty.tty$greetd_vt default && sudo rc-service agetty.tty$greetd_vt stop"
    else
        ok "greetd owns vt$greetd_vt alone"
    fi
fi
