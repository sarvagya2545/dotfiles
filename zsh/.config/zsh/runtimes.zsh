
# fnm
FNM_PATH="/home/ubuntu/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

# uv
if command -v uv &>/dev/null; then
  eval "$(uv generate-shell-completion zsh)"
  eval "$(uvx --generate-shell-completion zsh)"
fi

# direnv (keep last: it snapshots the environment)
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi
