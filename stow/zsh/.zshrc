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
alias upgrade="just -d ~/.dotfiles upgrade"

# ==============================================================================
# Homebrew Auto-Sync Wrapper
# Automatically records installed/uninstalled packages in ~/.dotfiles/Brewfile
# ==============================================================================
brew() {
  command brew "$@"
  local exit_code=$?

  if [[ $exit_code -eq 0 && ("$1" == "install" || "$1" == "uninstall" || "$1" == "remove") ]]; then
    local brewfile="$HOME/.dotfiles/Brewfile"
    if [[ -f "$brewfile" ]]; then
      local action="$1"
      shift
      local is_cask=0
      local pkgs=()

      for arg in "$@"; do
        if [[ "$arg" == "--cask" ]]; then
          is_cask=1
        elif [[ "$arg" != -* ]]; then
          pkgs+=("$arg")
        fi
      done

      for pkg in "${pkgs[@]}"; do
        if [[ "$action" == "install" ]]; then
          local entry
          if (( is_cask )); then
            entry="cask \"$pkg\""
          else
            entry="brew \"$pkg\""
          fi
          if ! grep -qF "$entry" "$brewfile"; then
            echo "$entry" >> "$brewfile"
            echo "📝 Added $entry to ~/.dotfiles/Brewfile"
          fi
        elif [[ "$action" == "uninstall" || "$action" == "remove" ]]; then
          if grep -E -q "^(brew|cask) \"$pkg\"" "$brewfile"; then
            sed -i '' -E "/^(brew|cask) \"$pkg\"/d" "$brewfile"
            echo "🗑️  Removed \"$pkg\" from ~/.dotfiles/Brewfile"
          fi
        fi
      done
    fi
  fi

  return $exit_code
}
