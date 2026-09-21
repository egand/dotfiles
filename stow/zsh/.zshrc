# Interactive Zsh Configuration
# Managed via GNU Stow: ~/.dotfiles/stow/zsh/.zshrc

# ==============================================================================
# History Settings
# ==============================================================================
HISTSIZE=100000
SAVEHIST=100000
HISTFILE="$HOME/.zsh_history"
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE

# ==============================================================================
# Keybindings & Completion
# ==============================================================================
autoload -Uz compinit
compinit -C

bindkey '^f' autosuggest-accept

# ==============================================================================
# Tool Integrations
# ==============================================================================

# Starship prompt
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# Zoxide (smart cd)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# FZF fuzzy finder
if command -v fzf &>/dev/null; then
  eval "$(fzf --zsh 2>/dev/null || fzf --shell zsh)"
fi

# Direnv
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# Mise (runtime manager)
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# Zsh Autosuggestions
if [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Zsh Syntax Highlighting (must be loaded after custom widgets)
if [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ==============================================================================
# Aliases
# ==============================================================================

# Navigation
alias ..="cd .."
alias ...="cd ../.."

# Modern CLI replacements
alias ls="eza --icons"
alias ll="eza -la --icons --git"
alias tree="eza --tree --icons"
alias cat="bat"
alias du="dust"
alias df="duf"
alias top="btop"

# Antigravity CLI
alias ag="antigravity"
alias aga="antigravity --auto"

# Git
alias g="git"
alias gst="git status"
alias gaa="git add -A"
alias gc="git commit -m"
alias gp="git push"
alias gl="git pull"
alias sw="git switch"
alias lg="lazygit"

# System upgrade
alias upgrade="~/.dotfiles/scripts/system-upgrade.sh"

# ==============================================================================
# Functions
# ==============================================================================

# - AWDL (AirDrop) Toggle for Low-Latency Gaming -
awdl() {
  case "$1" in
    on|enable)
      sudo ifconfig awdl0 up
      echo "📡 AWDL enabled (AirDrop/AirPlay active)"
      ;;
    off|disable)
      sudo ifconfig awdl0 down
      echo "🎮 AWDL disabled (Low-Latency Gaming Mode active)"
      ;;
    status)
      if ifconfig awdl0 2>/dev/null | grep -q "status: active"; then
        echo "📡 AWDL: Active (AirDrop ON)"
      else
        echo "🎮 AWDL: Inactive (Gaming Mode ON)"
      fi
      ;;
    toggle)
      if ifconfig awdl0 2>/dev/null | grep -q "status: active"; then
        sudo ifconfig awdl0 down
        echo "🎮 AWDL disabled (Gaming Mode ON)"
      else
        sudo ifconfig awdl0 up
        echo "📡 AWDL enabled (AirDrop ON)"
      fi
      ;;
    *)
      echo "Usage: awdl {on|off|status|toggle}"
      ;;
  esac
}

_awdl_completion() {
  local -a commands=(
    "on:Enable AWDL/AirDrop"
    "off:Disable AWDL (Gaming mode)"
    "status:Check current AWDL status"
    "toggle:Toggle between active and inactive"
  )
  _describe 'command' commands
}
compdef _awdl_completion awdl
