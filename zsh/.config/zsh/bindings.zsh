# =========================================================
# Keybindings
# =========================================================

function zvm_config() {
    # Cursor shape per vi mode
    ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLOCK
    ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
    ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

    # Disable command mode line highlight
    ZVM_VI_HIGHLIGHT_BACKGROUND=none
    ZVM_VI_HIGHLIGHT_FOREGROUND=none
    ZVM_VI_HIGHLIGHT_EXTRASTYLE=none
}


# zsh-vi-mode resets all bindings on init, so custom bindings
# must be registered via this hook to survive.
zvm_after_init() {
    # tmux-sessionizer
    bindkey -s ^f "tmux-sessionizer\n"
    
    # fzf history for vim insert mode
    bindkey -M viins '^R' fzf-history-widget
}
