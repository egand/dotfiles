#!/usr/bin/env bash
# Complete system upgrade: Homebrew packages + Nix Flake + Darwin switch + Git commit
set -euo pipefail

export PATH="/opt/homebrew/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
DIR="$HOME/.dotfiles"

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
  sudo darwin-rebuild switch --flake "$DIR#mac"

  # 3. Amend flake.lock changes into the current commit to keep history clean
  if ! git -C "$DIR" diff --quiet flake.lock 2>/dev/null; then
    git -C "$DIR" add flake.lock
    git -C "$DIR" commit --amend --no-edit || true
    echo "    Updated flake.lock amended to the current commit."
  fi
fi

echo "==> [$(date '+%Y-%m-%d %H:%M:%S')] System upgrade completed successfully."
