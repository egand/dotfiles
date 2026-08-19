#!/usr/bin/env bash
# Complete system upgrade: Homebrew packages + Nix Flake + Darwin switch + Git commit
set -euo pipefail

export PATH="/opt/homebrew/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

echo "==> [$(date '+%Y-%m-%d %H:%M:%S')] Starting system upgrade..."

# 1. Upgrade Homebrew formulae & GUI casks
if command -v brew >/dev/null 2>&1; then
  echo "==> Upgrading Homebrew packages..."
  brew update
  brew upgrade || true
  brew upgrade --cask || true
fi

# 2. Update Nix Flake dependencies & apply rebuild
if [ -d "$DIR" ] && command -v nix >/dev/null 2>&1; then
  echo "==> Updating Nix Flake lockfile..."
  nix flake update --flake "$DIR"

  echo "==> Applying darwin-rebuild switch..."
  if command -v darwin-rebuild >/dev/null 2>&1; then
    sudo darwin-rebuild switch --flake "$DIR#mac"
  else
    sudo nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake "$DIR#mac"
  fi

  # 3. Create a dedicated commit for flake.lock if there are changes
  if ! git -C "$DIR" diff --quiet flake.lock 2>/dev/null; then
    git -C "$DIR" add flake.lock
    git -C "$DIR" commit -m "chore(flake): update lockfile" || true
    echo "    Updated flake.lock committed."
  fi
fi

echo "==> [$(date '+%Y-%m-%d %H:%M:%S')] System upgrade completed successfully."

# Desktop notification (when run via background launchd)
if command -v osascript >/dev/null 2>&1; then
  osascript -e 'display notification "System upgrade completed successfully." with title "Dotfiles Upgrade"' 2>/dev/null || true
fi
