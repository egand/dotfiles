#!/usr/bin/env bash
# Non-destructive Homebrew synchronization and verification tool
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
HOMEBREW_NIX="$DIR/homebrew.nix"
MODE="${1:---check}"

if ! command -v brew >/dev/null 2>&1; then
  exit 0
fi

if [ ! -f "$HOMEBREW_NIX" ]; then
  echo "Error: $HOMEBREW_NIX not found" >&2
  exit 1
fi

INSTALLED_BREWS=$(brew leaves 2>/dev/null | sort)
INSTALLED_CASKS=$(brew list --cask 2>/dev/null | sort)

MISSING_BREWS=()
for b in $INSTALLED_BREWS; do
  if ! grep -q "\"$b\"" "$HOMEBREW_NIX"; then
    MISSING_BREWS+=("$b")
  fi
done

MISSING_CASKS=()
for c in $INSTALLED_CASKS; do
  if ! grep -q "\"$c\"" "$HOMEBREW_NIX"; then
    MISSING_CASKS+=("$c")
  fi
done

if [ "$MODE" == "--check" ]; then
  if [ ${#MISSING_BREWS[@]} -gt 0 ] || [ ${#MISSING_CASKS[@]} -gt 0 ]; then
    echo "💡 Homebrew state notice:"
    if [ ${#MISSING_BREWS[@]} -gt 0 ]; then
      echo "   Untracked formulae: ${MISSING_BREWS[*]}"
    fi
    if [ ${#MISSING_CASKS[@]} -gt 0 ]; then
      echo "   Untracked casks:    ${MISSING_CASKS[*]}"
    fi
    echo "   Remember to add them to ~/.dotfiles/homebrew.nix to keep your declarative config complete."
  else
    echo "✅ All installed Homebrew packages are recorded in homebrew.nix"
  fi
fi
