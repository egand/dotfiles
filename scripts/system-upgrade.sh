#!/usr/bin/env bash
# Complete native system upgrade via justfile and notification
set -euo pipefail

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.local/bin:$PATH"
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_NO_QUARANTINE=1
export HOMEBREW_NO_ANALYTICS=1
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

echo "==> [$(date '+%Y-%m-%d %H:%M:%S')] Starting native system upgrade..."

just --justfile "$DIR/justfile" upgrade

echo "==> [$(date '+%Y-%m-%d %H:%M:%S')] System upgrade completed successfully."

# Desktop notification (when run via background launchd)
if command -v osascript >/dev/null 2>&1; then
  osascript -e 'display notification "System upgrade completed successfully." with title "Dotfiles Upgrade"' 2>/dev/null || true
fi
