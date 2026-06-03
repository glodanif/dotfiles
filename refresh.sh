#!/bin/sh
xbps-query -m | sed 's/-[^-]*$//' | sort > packages-void.txt
for d in */; do stow --no-folding "$d"; done

