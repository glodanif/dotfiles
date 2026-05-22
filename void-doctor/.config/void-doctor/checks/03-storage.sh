section "Storage"

# RAID arrays — only check if arrays are actually configured
if [[ -f /proc/mdstat ]] && grep -q "^md" /proc/mdstat 2>/dev/null; then
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
fi

# LVM — only check if volume groups exist
if command -v vgs &>/dev/null; then
    vg_count=$(sudo vgs --noheadings 2>/dev/null | grep -c "." || true)
    if (( vg_count > 0 )); then
        ok "$vg_count LVM volume group(s) present"
        lv_count=$(sudo lvs --noheadings 2>/dev/null | grep -c "." || true)
        ok "$lv_count logical volume(s) present"
    fi
fi

# Disk health via SMART
if command -v smartctl &>/dev/null; then
    checked=0
    for dev in /dev/sd[a-z] /dev/nvme[0-9]n[0-9]; do
        [[ -e "$dev" ]] || continue
        ((checked++)) || true
        attrs=$(sudo smartctl -a "$dev" 2>/dev/null)

        result=$(echo "$attrs" | grep -oP '(?<=test result: ).*' || true)
        if [[ "$result" == "PASSED" ]]; then
            ok "SMART $dev: PASSED"
        elif [[ -n "$result" ]]; then
            err "SMART $dev: $result"
        fi

        # SSD wear level (ID 231, SSD_Life_Left — VALUE column = % remaining)
        life=$(echo "$attrs" | awk '$1==231{print $4}')
        if [[ -n "$life" ]]; then
            life=$((10#$life))
            if (( life <= 20 )); then
                err "SMART $dev: SSD life critical (${life}% remaining)"
            elif (( life <= 40 )); then
                warn "SMART $dev: SSD life low (${life}% remaining)"
            else
                ok "SMART $dev: SSD life ${life}% remaining"
            fi
        fi

        # Unexpected power losses (ID 174 — RAW_VALUE)
        upl=$(echo "$attrs" | awk '$1==174{print $NF}')
        if [[ -n "$upl" ]] && (( upl > 500 )); then
            warn "SMART $dev: high unexpected power loss count ($upl) — check UPS/shutdown hygiene"
        fi
    done
    (( checked == 0 )) && warn "no drives found for SMART check"
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
