# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export TERM=xterm-256color
export COLORTERM=truecolor

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"
plugins=(zsh-autosuggestions) 

source $ZSH/oh-my-zsh.sh

# User configuration
# export HOMEBREW_NO_AUTO_UPDATE=1

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Less editor commands config
# export LESSOPEN="| $(brew --prefix source-highlight)/bin/src-hilite-lesspipe.sh %s"
# export LESSOPEN="| /usr/local/opt/source-highlight/bin/src-hilite-lesspipe.sh %s"
# export LESS=' -R --use-color -N -J --line-num-width 5 --incsearch'
# export SOURCE_HIGHLIGHT_STYLE=esc
export MANPAGER="sh -c 'col -bx | batcat -l man -p'"

export EDITOR=nvim

# PATH
export PATH="$HOME/dotfiles/bin:$PATH"

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

export NVM_DIR="$HOME/.nvm"
# Load nvm only if it hasn't been loaded yet
if [ -z "$NVM_LOADED" ]; then
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    export NVM_LOADED=1
fi

bindkey -s ^f "tmux-sessionizer\n"

export PATH="$HOME/.local/bin:$PATH"
eval "$(direnv hook zsh)"   # or 'zsh' if using zsh

# opencode
export PATH=/home/ubuntu/.opencode/bin:$PATH

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

uz-show() {
  local fifo=/tmp/uz-adhoc-fifo
  [[ -p $fifo ]] || mkfifo "$fifo"
  ueberzugpp layer --silent -o sixel < "$fifo" &
  local pid=$!

  exec 3>"$fifo"   # open our own persistent write fd — prevents EOF
  echo "{\"action\": \"add\", \"identifier\": \"adhoc\", \"x\": 0, \"y\": 0, \"width\": 60, \"height\": 30, \"path\": \"$1\"}" >&3

  echo "Press Enter to close..."
  read -r

  echo '{"action": "remove", "identifier": "adhoc"}' >&3
  exec 3>&-        # now close it — ueberzugpp gets EOF and exits cleanly
  wait "$pid" 2>/dev/null
}
