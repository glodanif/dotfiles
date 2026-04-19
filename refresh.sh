#!/bin/zsh
pacman -Qqen > packages-official.txt
pacman -Qqem > packages-aur.txt
for d in */; do stow --no-folding "$d"; done

