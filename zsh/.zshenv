export JAVA_HOME="$HOME/.jdks/openjdk-26"
export ANDROID_HOME="$HOME/Development/Tools/android-sdk"

export PATH="\
$HOME/.cargo/bin:\
$JAVA_HOME/bin:\
$HOME/Development/Tools/flutter/bin:\
$ANDROID_HOME/cmdline-tools/latest/bin:\
$ANDROID_HOME/platform-tools:\
$HOME/.local/bin:\
$PATH"

# Go defaults GOPATH to ~/go; AUR Go packages (fvs2 etc.) pull go in as a
# makedep, fill the module cache, then leave the dir behind when go is removed
# as an orphan. Mirrored in ~/.config/go/env for non-zsh callers.
export GOPATH="$HOME/.local/share/go"

export EDITOR=nvim
export VISUAL=nvim
export BAT_THEME=ansi
export SUDO_EDITOR="$EDITOR"

