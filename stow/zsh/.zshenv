# Environment Variables & System PATH
# Sourced for all zsh instances (interactive and non-interactive)

if [[ -d /opt/homebrew ]]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
  export HOMEBREW_REPOSITORY="/opt/homebrew"
fi

# Mise Shims (Ensures VS Code, GUI apps, and subshells find active runtimes)
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Antigravity & User Local Binaries
export PATH="$HOME/.antigravity/antigravity/bin:$HOME/.local/bin:$PATH"


# Default Editor
export EDITOR="code"
export VISUAL="code"

# Homebrew Configurations
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_NO_QUARANTINE=1
export HOMEBREW_NO_ANALYTICS=1
