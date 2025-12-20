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


create_directories() {
    info "Creating optimized folder structure..."

    # ==============================================================================
    # 1. DEVELOPER WORKSPACE (~/Developer)
    # ==============================================================================
    # WHY: Kept local (NO iCloud sync).
    #      Prevents sync issues with 'node_modules', build artifacts, and heavy Unity caches.
    #      macOS automatically assigns a specialized icon to a folder named "Developer".
    info "Setting up Developer environment..."

    # -> General Projects
    # WHAT: Your main coding playground. Java, Python, Zig, Rust, Web Apps.
    # EXAMPLES: 'my-todo-app', 'zig-compiler-test', 'python-scraper'.
    mkdir -p "$HOME/Developer/workspaces/projects"

    # -> Game Development
    # WHAT: Specific folder for Game Engines (Unity, Godot, Unreal).
    # WHY: These projects contain massive binary files that shouldn't be mixed with lightweight code.
    # EXAMPLES: 'SuperMarioClone_Unity', 'Godot-Platformer'.
    mkdir -p "$HOME/Developer/workspaces/games"

    # -> University Code
    # WHAT: Code strictly related to university assignments/exams.
    # EXAMPLES: 'CS101-Algorithms', 'Java-Exam-Final-Project'.
    mkdir -p "$HOME/Developer/workspaces/uni-code"

    # -> Scratchpad (The "Dirty" Zone)
    # WHAT: Temporary code. Safe to delete at any time.
    # 'ai-tests': Copy-pasting code from Claude/ChatGPT to see if it runs.
    # 'temp': Quick experiments, cloning a repo just to read one file.
    mkdir -p "$HOME/Developer/scratchpad/ai-tests"
    mkdir -p "$HOME/Developer/scratchpad/temp"

    # -> Tools & Config
    # WHAT: Your personal scripts, binaries, or global configs.
    # EXAMPLES: 'backup-script.sh', 'docker-compose-global.yml'.
    mkdir -p "$HOME/Developer/tools"

    # -> Repositories
    # Open Source projects cloned from GitHub for study/reference
    mkdir -p "$HOME/Developer/repos"


    # ==============================================================================
    # 2. UNIVERSITY & DOCUMENTS (~/Documents)
    # ==============================================================================
    # WHY: Synced via iCloud. Available on iPhone/iPad.
    #      Perfect for text files, PDFs, and bureaucratic docs.
    info "Setting up University & Documents..."

    # -> Current Semester
    # WHAT: Active study material.
    # EXAMPLES: 'Math-Analysis-Slides.pdf', 'Physics-Notes.md'.
    mkdir -p "$HOME/Documents/university/current-semester"

    # -> Archive
    # WHAT: Old semesters. Keep it clean!
    # EXAMPLES: 'Year-1', 'Semester-1', 'Passed-Exams'.
    mkdir -p "$HOME/Documents/university/archive"

    # -> Personal Docs
    # WHAT: Life administration.
    # EXAMPLES: 'ID-Card-Scan.pdf', 'Rent-Contract.pdf', 'Resume.pdf'.
    mkdir -p "$HOME/Documents/personal/docs"

    # -> Cheatsheets
    # WHAT: Quick reference guides for development.
    # EXAMPLES: 'Vim-Shortcuts.pdf', 'Unity-Lifecycle-Chart.png', 'Git-Commands.md'.
    mkdir -p "$HOME/Documents/cheatsheets"


    # ==============================================================================
    # 3. CREATIVE ASSETS (~/Assets)
    # ==============================================================================
    # WHY: The "Supermarket" for your creative work. Local storage (Heavy files).
    #      These are SOURCE files to be imported into Unity/Blender when needed.
    info "Setting up Assets library..."

    # -> 3D Models
    # 'kitbash': Downloaded models to build scenes quickly (e.g., 'SciFi-Crate.obj').
    # 'exports': Your own Blender creations exported as FBX/GLTF for Unity.
    mkdir -p "$HOME/Assets/3d-models/kitbash"
    mkdir -p "$HOME/Assets/3d-models/exports"

    # -> Textures
    # WHAT: Image files for 3D materials or 2D games.
    # EXAMPLES: 'Wood_Texture_Albedo.png', 'UI_Button_Sprite.png'.
    mkdir -p "$HOME/Assets/textures"

    # -> Audio SFX (Sound Effects)
    # WHAT: Non-musical sounds for games.
    # EXAMPLES: 'Explosion_01.wav', 'UI_Click.wav', 'Footsteps_Grass.wav'.
    mkdir -p "$HOME/Assets/audio-sfx"

    # -> Blender Saves
    # WHAT: Work-in-progress .blend files (before exporting).
    # EXAMPLES: 'Main_Character_Sculpt.blend'.
    mkdir -p "$HOME/Assets/blender-saves"


    # ==============================================================================
    # 4. MUSIC PRODUCTION (~/Music)
    # ==============================================================================
    # WHY: Standard location for DAWs (Bitwig). Local storage.
    info "Setting up Music production..."

    # -> Bitwig Projects
    # WHAT: Your songs/tracks.
    # EXAMPLES: 'My-Techno-Track.bwproject'.
    mkdir -p "$HOME/Music/bitwig-projects"

    # -> VST Presets
    # WHAT: Saved settings for your synthesizers.
    # EXAMPLES: 'My-Fat-Bass-Patch.fxp'.
    mkdir -p "$HOME/Music/vst-presets"

    # -> Sample Library (The Ingredients)
    # 'drums': Single hits (One-shots). EXAMPLES: 'Kick.wav', 'Snare.wav'.
    # 'loops': Musical phrases. EXAMPLES: 'Funky-Bass-Loop-120bpm.wav'.
    # 'fx': Sound design elements. EXAMPLES: 'Riser.wav', 'White-Noise.wav'.
    # 'vocals': Human voice files. EXAMPLES: 'Acapella.wav', 'Adlib-Yeah.wav'.
    # 'packs': Full folders downloaded from Splice/Cymatics.
    mkdir -p "$HOME/Music/sample-library/drums"
    mkdir -p "$HOME/Music/sample-library/loops"
    mkdir -p "$HOME/Music/sample-library/fx"
    mkdir -p "$HOME/Music/sample-library/vocals"
    mkdir -p "$HOME/Music/sample-library/packs"


    # ==============================================================================
    # 5. HEAVY MEDIA (~/Movies)
    # ==============================================================================
    # WHY: Video files are too large for iCloud.
    info "Setting up Media folders..."

    # -> University Recordings
    # WHAT: Long video lessons or tutorials.
    # EXAMPLES: 'Lecture-01-DataStructures.mp4'.
    mkdir -p "$HOME/Movies/uni-recordings"

    info "Folder structure created successfully!"
}

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

install_rosetta() {
    # Controllo se siamo su Apple Silicon (arm64)
    if [[ "$(uname -m)" == "arm64" ]]; then
        # Controllo se Rosetta è già installato
        if /usr/bin/pgrep oahd >/dev/null 2>&1; then
            info "Rosetta 2 is already installed. Skipping."
        else
            info "Installing Rosetta 2..."
            # --agree-to-license evita che ti chieda di premere "A"
            softwareupdate --install-rosetta --agree-to-license
        fi
    else
        info "Intel Mac detected. Rosetta 2 not needed."
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
        uv
        go # The Go programming language
        ripgrep
        shellcheck
        tlrc
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
        orbstack
        linearmouse
        yaak
        nvidia-geforce-now
        steam
        betterdisplay
        blender
        unity-hub
        discord
        google-chrome
        whatsapp
        telegram
        epic-games
        obsidian
        qbittorrent
        visual-studio-code
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

setup_keyboard_layout() {
    info "Installing custom keyboard layout (System-wide)..."

    local layout_name="US-IT.bundle"
    local source_path="$HOME/.dotfiles/keyboard/$layout_name"
    # NOTA: Destinazione senza ~ (tilde), va nella root Library
    local dest_path="/Library/Keyboard Layouts/"

    if [ -d "$source_path" ]; then
        info "Requesting sudo permissions to write to /Library/..."

        # Copia con privilegi di amministrazione
        # Rimuove versioni precedenti per evitare conflitti
        sudo rm -rf "$dest_path/$layout_name"
        sudo cp -r "$source_path" "$dest_path"

        # Corregge i permessi per assicurarsi che root sia il proprietario (standard per /Library)
        sudo chown -R root:wheel "$dest_path/$layout_name"

        info "Layout $layout_name installed to System Library."
        info "⚠️  IMPORTANT: You must RESTART (or Log Out) to see the new layout."
        info "   Then go to: Settings -> Keyboard -> Input Sources -> Edit -> + -> Others -> US-IT"
    else
        echo "Warning: Custom layout $layout_name not found in $source_path. Skipping."
    fi
}

# Function to set up dotfiles using GNU Stow
stow_dotfiles() {
    info "Setting up dotfiles with GNU Stow..."

    # List of directories within your dotfiles repo to be "stowed".
    local stow_dirs=(
        zsh
        #aerospace
        ghostty
        #sketchybar
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
    install_rosetta
    install_homebrew
    install_brew_packages
    install_nvm
    info "Finished installing nvm."
    install_sdkman
    info "Finished installing sdkman."
    stow_dotfiles

    create_directories

    info "Setup complete! Please restart your terminal for all changes to take effect."
    setup_keyboard_layout

}

# Run the main function
main
