# this stops the global rc files from running
# unsetopt GLOBAL_RCS

# ---------- XDG Base directories ----------
# Centralizes config/cache/data locations

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ---------- Editor ----------
export EDITOR="nvim"
export VISUAL="nvim"

# ---------- GPG ----------
export GPG_TTY=$(tty)

# ---------- HOMEBREW ----------
export HOMEBREW_NO_AUTO_UPDATE=1

# ---------- PATH ----------
# Personal binaries / scripts
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/opt/local/bin:$PATH"
# wezterm cli
export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"
# mysql
export PATH="/usr/local/mysql/bin:$PATH"
# duckdb
export PATH="$HOME/.duckdb/cli/latest:$PATH"
# opencode script installs here
export PATH="$HOME/.opencode/bin:$PATH"
# LLVM (need this for c++ 20)
export PATH="/usr/local/opt/llvm@15/bin:$PATH"
# Image magick
export PATH="/opt/local/lib/ImageMagick7/bin:$PATH"
export PKG_CONFIG_PATH="/opt/local/lib/ImageMagick7/lib/pkgconfig:$PKG_CONFIG_PATH"
# brew
export PATH="/usr/local/bin:$PATH"

# ---------- Pager ---------- 
# custom syntax highlighting for man pages
export MANPAGER='sh -c "col -bx | bat -l cman -p"'
export MANROFFOPT="-c"
export BAT_THEME='CoolNight' # custom theme for man pages
