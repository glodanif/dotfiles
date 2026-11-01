#!/bin/zsh
pacman -Qqen > packages-official.txt
pacman -Qqem > packages-aur.txt
for d in */; do [[ $d == system/ ]] || stow --no-folding "$d"; done

# system/ mirrors / for root-owned files; install only what differs.
# ponytail: 0644 root:root except sudoers.d — add a mode map if an executable (local.d hook) moves in here.
for f in system/**/*(.N); do
    t=/${f#system/}
    if [[ $t == /etc/sudoers.d/* ]]; then
        # 0750 dir: only root can compare. A broken sudoers file locks out sudo, so validate first.
        sudo cmp -s "$f" "$t" && continue
        visudo -cqf "$f" || { echo "invalid sudoers, skipped: $f"; continue; }
        sudo install -Dm440 -o root -g root "$f" "$t"
    else
        cmp -s "$f" "$t" || sudo install -Dm644 -o root -g root "$f" "$t"
    fi
done
