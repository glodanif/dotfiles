#!/bin/zsh
pacman -Qqen > packages-official.txt
pacman -Qqem > packages-aur.txt
for d in */; do [[ $d == system/ ]] || stow --no-folding "$d"; done

# system/ mirrors / for root-owned files; install only what differs.
# ponytail: everything goes in as 0644 root:root — add a mode map if an executable (local.d hook) moves in here.
for f in system/**/*(.N); do
    t=/${f#system/}
    cmp -s "$f" "$t" || sudo install -Dm644 -o root -g root "$f" "$t"
done
