#!/usr/bin/env bash
# Takes a fresh Mac from nothing to a fully configured developer workstation.
# Idempotent 1-click bootstrap powered by Homebrew, GNU Stow, and Just.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
echo "🚀 Starting macOS dotfiles bootstrap..."

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

# Step 5: Provision Workspace Folders & Keyboard
echo "==> Step 5: Provisioning workspace folders and keyboard layout..."
just --justfile "$DIR/justfile" folders
just --justfile "$DIR/justfile" keyboard

# Step 6: Backup default shell configs & Mirror Dotfiles via GNU Stow
echo "==> Step 6: Stowing configuration files to $HOME..."
for f in "$HOME/.zshrc" "$HOME/.zshenv" "$HOME/.zprofile"; do
  if [ -f "$f" ] && [ ! -L "$f" ]; then
    echo "    Backing up default $f to $f.pre-dotfiles..."
    mv "$f" "$f.pre-dotfiles"
  fi
done
just --justfile "$DIR/justfile" sync

# Step 7: Compile Smart Paste Helper (Herdr Multiplexer Dependency)
echo "==> Step 7: Compiling smart-paste Swift helper..."
just --justfile "$DIR/justfile" paste

# Step 8: Install Packages & Applications via Brewfile
echo "==> Step 8: Installing packages, casks, and Nerd Fonts from Brewfile..."
just --justfile "$DIR/justfile" brew

# Step 9: Install Language Runtimes (Mise)
echo "==> Step 9: Installing language runtimes via Mise..."
just --justfile "$DIR/justfile" runtimes

# Step 10: Apply macOS System Preferences
echo "==> Step 10: Applying macOS system defaults..."
just --justfile "$DIR/justfile" macos

# Step 11: Configure Touch ID for sudo
echo "==> Step 11: Configuring Touch ID for sudo..."
just --justfile "$DIR/justfile" touchid

# Step 12: Import Raycast Configuration
echo "==> Step 12: Importing Raycast settings..."
if [ -f "$DIR/raycast/raycast.rayconfig" ]; then
  echo "    Opening Raycast configuration wizard..."
  open "$DIR/raycast/raycast.rayconfig"
fi

echo "✨ Bootstrap completed successfully! Please restart your terminal session or log out to apply all changes."
