#!/usr/bin/env bash

# Idempotent script to set up a new macOS machine.
#
# Usage:
#   1. Clone your dotfiles repository:
#      git clone https://github.com/your-user/dotfiles.git ~/.dotfiles
#   2. Run this script from the dotfiles directory:
#      cd ~/.dotfiles && ./install.sh
#
# The script can be run multiple times without causing issues.

# --- Shell settings ---
# Exit immediately if a command exits with a non-zero status.
#set -e

export XDG_CONFIG_HOME="$HOME/.config"
export NVM_DIR="$HOME/.nvm"
export SDKMAN_DIR="$HOME/.sdkman"

# --- Color definitions for output ---
# This makes the script's output easier to read.
readonly GREEN='\033[0;32m'
readonly NC='\033[0m' # No Color

# --- Helper function for logging ---
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# --- Main functions ---

# Function to install Homebrew
install_homebrew() {
    info "Checking for Homebrew installation..."
    # Check if the 'brew' command is available in the system's PATH.
    if command -v brew &> /dev/null; then
        info "Homebrew is already installed. Updating..."
        brew update
    else
        info "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# Function to install packages and applications using Homebrew
install_brew_packages() {
    info "Installing command-line packages..."
    # List of command-line tools to install.
    local packages=(
        git
        stow
        ripgrep # A modern, fast 'grep' alternative
        fd      # A modern, fast 'find' alternative
        eza     # A modern, fast 'ls' alternative
        tmux    # A terminal multiplexer
        neovim  # A modern Vim-fork
        ffmpeg # A complete, cross-platform solution to record, convert and stream audio and video
        tree    # A recursive directory listing command that produces a depth-indented listing of files
        jq      # A lightweight and flexible command-line JSON processor
        bat     # A cat clone with syntax highlighting and Git integration
        zsh     # Z shell, a powerful shell with scripting capabilities
        zsh-autosuggestions # Zsh plugin for fish-like autosuggestions
        zsh-syntax-highlighting # Zsh plugin for syntax highlighting
        zsh-completions
        zsh-history-substring-search
        pyenv # A tool to manage multiple Python versions
        go # The Go programming language
        ripgrep
        shellcheck
    )

    for package in "${packages[@]}"; do
        # Use 'brew list' to check if a package is already installed.
        if brew list "$package" &> /dev/null; then
            info "$package is already installed. Skipping."
        else
            info "Installing $package..."
            brew install "$package"
        fi
    done

    info "Installing GUI applications..."
    # List of GUI applications to install using Homebrew Cask.
    local casks=(
        sf-symbols
        font-sf-mono
        font-sf-pro
        font-hack-nerd-font
        font-jetbrains-mono
        font-fira-code
        ghostty # A terminal emulator for macOS
        raycast # A fast, keyboard-driven launcher for macOS
        obsidian
        nikitabobko/tap/aerospace
        zed
    )

    for cask in "${casks[@]}"; do
        # Use 'brew list --cask' to check if a cask is already installed.
        if brew list --cask "$cask" &> /dev/null; then
            info "$cask is already installed. Skipping."
        else
            info "Installing $cask..."
            brew install --cask "$cask"
        fi
    done
}

install_nvm() {
    info "Checking for nvm (Node Version Manager)..."
    # The idempotent check is the existence of the NVM directory.
    if [ -d "$NVM_DIR" ]; then
        info "nvm is already installed. Skipping installation."
    else
        info "nvm not found. Installing..."
        # Install nvm using the official script.
        export PROFILE=/dev/null # Prevent nvm from modifying the shell profile.
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    fi

    info "Configuring default Node.js version..."
    # Source nvm script to make the 'nvm' command available in this script session.
    # This is necessary to install a Node version right after installing nvm itself.
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        source "$NVM_DIR/nvm.sh"
        # Install the latest Long-Term Support (LTS) version of Node.
        info "Installing latest LTS version of Node.js..."
        nvm install --lts
        # Set this LTS version as the default for new shell sessions.
        nvm alias default lts/*
    else
        echo "Error: Could not source nvm.sh. Please check the installation."
    fi
}

install_sdkman() {
    info "Checking for sdkman (SDK Manager for JVM)..."
    if [ -d "$SDKMAN_DIR" ]; then
        info "sdkman is already installed. Skipping installation."
    else
        info "Installing sdkman without modifying shell configs..."
        # The key is `rcupdate=false` to prevent changes to .zshrc
        curl -s "https://get.sdkman.io?ci=true&rcupdate=false" | bash
    fi

    # Source sdkman script to make the command available.
    if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
        source "$SDKMAN_DIR/bin/sdkman-init.sh"
        info "Installing and setting default Java version (latest LTS)..."
        # 'sdk install' is idempotent.
        local java_version="21-tem"
        sdk install java $java_version
    else
        echo "Error: Could not source sdkman-init.sh. Please check the installation." >&2
    fi
}

# Function to set up dotfiles using GNU Stow
stow_dotfiles() {
    info "Setting up dotfiles with GNU Stow..."

    # List of directories within your dotfiles repo to be "stowed".
    local stow_dirs=(
        zsh
        aerospace
        ghostty
        sketchybar
        starship
        zed
    )

    for dir in "${stow_dirs[@]}"; do
        info "Applying configuration for $dir..."
        # The '--restow' flag first unstows (removes links) and then stows again.
        # This makes the operation idempotent and safe to run multiple times.
        # It ensures the links are always correct, even if they were manually changed.
        stow --restow "$dir"
    done
}

# --- Main execution flow ---

main() {
    info "Starting macOS setup..."
    info "Applying macOS defaults..."
    if source "$HOME/.dotfiles/macos/set-defaults.sh"; then
        info "Successfully applied macOS defaults."
    else
        echo "Error: Failed to apply macOS defaults." >&2
        exit 1
    fi
    install_homebrew
    install_brew_packages
    install_nvm
    info "Finished installing nvm."
    install_sdkman
    info "Finished installing sdkman."
    stow_dotfiles


    info "Setup complete! Please restart your terminal for all changes to take effect."
}

# Run the main function
main
