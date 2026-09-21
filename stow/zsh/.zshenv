# Environment Variables & System PATH
# Sourced for all zsh instances (interactive and non-interactive)

# Homebrew environment
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Antigravity & User Local Binaries
export PATH="$HOME/.antigravity/antigravity/bin:$HOME/.local/bin:$PATH"

# Default Editor
export EDITOR="code"
export VISUAL="code"

# Homebrew Configurations
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_NO_QUARANTINE=1
export HOMEBREW_NO_ANALYTICS=1
