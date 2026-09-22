#!/usr/bin/env bash
# Takes a fresh Mac from nothing to a fully configured developer workstation.
# Idempotent 1-click bootstrap powered by Homebrew, GNU Stow, and Just.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ERR_LOG="${TMPDIR:-/tmp}/dotfiles-errors.log"
rm -f "$ERR_LOG" "${TMPDIR:-/tmp}/dotfiles-brew.log"

echo "🚀 Starting macOS dotfiles bootstrap..."

# Step 0: Authenticate administrator credentials upfront
echo "==> Authenticating administrator credentials upfront..."
sudo -v

# Keep sudo timestamp updated in background until bootstrap finishes
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_KEEP_ALIVE_PID=$!
trap 'kill "$SUDO_KEEP_ALIVE_PID" 2>/dev/null || true' EXIT

# Step 1: Xcode Command Line Tools
echo "==> Step 1: Checking Xcode Command Line Tools..."
if ! xcode-select -p >/dev/null 2>&1; then
  echo "    Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "    Please complete the Xcode Command Line Tools installation prompt, then re-run this script."
  exit 1
else
  echo "    Xcode Command Line Tools already installed."
fi

# Step 2: Homebrew
echo "==> Step 2: Checking Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  echo "    Installing Homebrew non-interactively..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Evaluate Homebrew environment for Apple Silicon or Intel
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Step 3: Symlink repository to ~/.dotfiles
echo "==> Step 3: Linking dotfiles repository..."
if [ "$DIR" != "$HOME/.dotfiles" ]; then
  ln -sfn "$DIR" "$HOME/.dotfiles"
fi

# Step 4: Install Just and GNU Stow
echo "==> Step 4: Installing Just and GNU Stow..."
brew install just stow

# Step 5: Full System Setup via Just
echo "==> Step 5: Running full system setup (folders, keyboard, sync, paste, brew, runtimes, macos, touchid)..."
for f in "$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.zprofile"; do
  if [ -f "$f" ] && [ ! -L "$f" ]; then
    echo "    Backing up default $f to $f.pre-dotfiles..."
    mv "$f" "$f.pre-dotfiles"
  fi
done

just --justfile "$DIR/justfile" setup || {
  echo "⚠️ Just setup finished with non-fatal issues." >> "$ERR_LOG"
}

# Step 6: Import Raycast Configuration
echo "==> Step 6: Importing Raycast settings..."
if [ -f "$DIR/raycast/raycast.rayconfig" ]; then
  echo "    Opening Raycast configuration wizard..."
  open "$DIR/raycast/raycast.rayconfig" 2>/dev/null || true
fi

# Step 7: Final Completion Summary
echo ""
if [ -s "$ERR_LOG" ]; then
  echo "=============================================================================="
  echo "⚠️  Bootstrap completed with some non-fatal warnings or failed packages:"
  echo "=============================================================================="
  cat "$ERR_LOG"
  echo "=============================================================================="
  echo "Review the above issues. Please restart your terminal session or log out to apply all changes."
else
  echo "=============================================================================="
  echo "✨ Bootstrap completed successfully! All steps passed without errors."
  echo "=============================================================================="
  echo "Please restart your terminal session or log out to apply all changes."
fi
