section "Storage"

# RAID arrays
if [[ -f /proc/mdstat ]]; then
    array_count=$(grep -c "^md" /proc/mdstat 2>/dev/null || true)
    if (( array_count > 0 )); then
        while IFS= read -r name; do
            state=$(grep -A2 "^${name}" /proc/mdstat | grep "blocks" | grep -oP '\[[U_]+\]' || true)
            if [[ -z "$state" ]]; then
                warn "RAID $name: status unknown"
            elif [[ "$state" == *_* ]]; then
                err "RAID $name: degraded $state"
            else
                ok "RAID $name: healthy $state"
            fi
        done < <(grep "^md" /proc/mdstat | awk '{print $1}')
    else
        warn "no active RAID arrays in /proc/mdstat"
    fi
else
    warn "/proc/mdstat not available"
fi

# LVM
if command -v vgs &>/dev/null; then
    vg_count=$(sudo vgs --noheadings 2>/dev/null | grep -c "." || true)
    if (( vg_count > 0 )); then
        ok "$vg_count LVM volume group(s) present"
        lv_count=$(sudo lvs --noheadings 2>/dev/null | grep -c "." || true)
        ok "$lv_count logical volume(s) present"
    else
        warn "no LVM volume groups found"
    fi
fi

# Disk health via SMART
if command -v smartctl &>/dev/null; then
    checked=0
    for dev in /dev/sd[a-z] /dev/nvme[0-9]n[0-9]; do
        [[ -e "$dev" ]] || continue
        result=$(sudo smartctl -H "$dev" 2>/dev/null | grep -oP '(?<=test result: ).*' || true)
        if [[ "$result" == "PASSED" ]]; then
            ok "SMART $dev: PASSED"
            ((checked++)) || true
        elif [[ -n "$result" ]]; then
            err "SMART $dev: $result"
            ((checked++)) || true
        fi
    done
    (( checked == 0 )) && warn "no drives found for SMART check (install smartmontools)"
else
    warn "smartctl not installed (install smartmontools for disk health checks)"
fi

# Filesystem usage
any_warn=0
while IFS= read -r line; do
    pct=$(echo "$line" | awk '{print $5}' | tr -d '%')
    mnt=$(echo "$line" | awk '{print $6}')
    [[ "$pct" =~ ^[0-9]+$ ]] || continue
    if (( pct >= 90 )); then
        err "disk usage critical: $mnt at ${pct}%"
        any_warn=1
    elif (( pct >= 80 )); then
        warn "disk usage high: $mnt at ${pct}%"
        any_warn=1
    fi
done < <(df -h 2>/dev/null | tail -n +2 | grep -v "^tmpfs\|^devtmpfs\|^udev\|^/dev/loop")
(( any_warn == 0 )) && ok "all filesystems below 80% usage"
