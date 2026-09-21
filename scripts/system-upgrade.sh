#!/usr/bin/env bash
# Complete native system upgrade: Homebrew packages + Mise runtimes + Stow sync
set -euo pipefail

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.local/bin:$PATH"
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_NO_QUARANTINE=1
export HOMEBREW_NO_ANALYTICS=1
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

echo "==> [$(date '+%Y-%m-%d %H:%M:%S')] Starting native system upgrade..."

# 1. Upgrade Homebrew formulae & GUI casks
if command -v brew >/dev/null 2>&1; then
  echo "==> Upgrading Homebrew packages..."
  brew update
  brew upgrade || true
  brew upgrade --cask --no-quarantine || true
  xattr -r -d com.apple.quarantine /Applications/Ghostty.app 2>/dev/null || true
fi

# 2. Upgrade Mise language runtimes and global tools
if command -v mise >/dev/null 2>&1; then
  echo "==> Upgrading Mise tools..."
  mise upgrade || true
fi

# 3. Resync dotfile symlinks via Stow
if command -v stow >/dev/null 2>&1 && [ -d "$DIR/stow" ]; then
  echo "==> Resyncing dotfile symlinks..."
  mkdir -p "$HOME/.config" "$HOME/Library/LaunchAgents"
  (cd "$DIR/stow" && stow -t "$HOME" --restow *) || true
fi

echo "==> [$(date '+%Y-%m-%d %H:%M:%S')] System upgrade completed successfully."

# Desktop notification (when run via background launchd)
if command -v osascript >/dev/null 2>&1; then
  osascript -e 'display notification "System upgrade completed successfully." with title "Dotfiles Upgrade"' 2>/dev/null || true
fi
