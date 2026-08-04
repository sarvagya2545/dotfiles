# Better ls
alias ls='eza --icons --group-directories-first'

# Detailed listing
alias ll='eza -lh --icons --git --group-directories-first'

# Detailed listing including hidden files
alias la='eza -lah --icons --git --group-directories-first'

# Tree view
alias tree='eza --tree --icons --group-directories-first'

# Reuse ls completions for eza (avoids defining a separate completion function)
compdef eza=ls

# hide and show desktop apps easily
alias hide_desktop="defaults write com.apple.finder CreateDesktop false; killall Finder"
alias show_desktop="defaults write com.apple.finder CreateDesktop true; killall Finder"
alias toggle_desktop='defaults write com.apple.finder CreateDesktop -bool $(defaults read com.apple.finder CreateDesktop 2>/dev/null | grep -qx 1 && echo false || echo true); killall Finder'
