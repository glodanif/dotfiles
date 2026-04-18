section "Fonts"

required_fonts=(
    "JetBrainsMono Nerd Font"
    "Noto Color Emoji"
    "Noto Sans CJK JP"
    "Noto Sans CJK KR"
    "Lato"
    "Montserrat"
    "SUSE Mono"
)

for font in "${required_fonts[@]}"; do
    first_word=$(echo "$font" | awk '{print $1}')
    if fc-match "$font" 2>/dev/null | grep -qiF "$first_word"; then
        ok "$font installed"
    else
        err "$font not installed"
    fi
done

