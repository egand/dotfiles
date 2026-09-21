export PATH := "/opt/homebrew/bin:/opt/homebrew/sbin:" + env_var('PATH')

# Default recipe (alias for sync)
default: sync

# Run complete setup on a fresh machine
setup: folders keyboard sync paste brew runtimes macos touchid

# Mirror configs to $HOME via GNU Stow
sync:
    mkdir -p "$HOME/.config" "$HOME/Library/LaunchAgents" "$HOME/.local/bin"
    (cd stow && stow -t "$HOME" --restow *)
    @if [ -f scripts/smart-paste.swift ] && [ ! -f "$HOME/.local/bin/smart-paste" ]; then just paste; fi
    @if [ -f scripts/awdl ] && [ ! -L "$HOME/.local/bin/awdl" ]; then ln -sfn "$PWD/scripts/awdl" "$HOME/.local/bin/awdl"; fi

# Compile smart-paste Swift helper for Herdr multiplexer
paste:
    mkdir -p "$HOME/.local/bin"
    swiftc -O scripts/smart-paste.swift -o "$HOME/.local/bin/smart-paste"

# Unlink a specific stow package
unlink package:
    (cd stow && stow -t "$HOME" -D {{ package }})

# Install and update packages via Homebrew Bundle
brew:
    brew bundle --file=Brewfile

# Install polyglot runtime toolchains declared in mise
runtimes:
    @if command -v mise >/dev/null 2>&1; then mise install; fi

# Apply macOS system preferences
macos:
    bash scripts/macos-defaults.sh

# Configure Touch ID authentication for sudo
touchid:
    bash scripts/setup-touchid.sh

# Install custom keyboard layout
keyboard:
    bash scripts/setup-keyboard.sh

# Create clean developer and personal workspace taxonomy
folders:
    bash scripts/setup-folders.sh

# Run daily upgrade (Homebrew, Mise, and Stow sync)
upgrade:
    brew update && brew upgrade
    brew upgrade --cask --no-quarantine
    -xattr -r -d com.apple.quarantine /Applications/Ghostty.app 2>/dev/null
    mise upgrade
    just sync

# Check git status and verify stow symlinks
status:
    @git status -s
    @echo "==> Verifying stow packages..."
    @if command -v stow >/dev/null 2>&1 && [ -d stow ]; then \
        (cd stow && stow -t "$HOME" --simulate --restow * 2>&1) || true; \
    else \
        echo "    (stow not installed or stow directory missing; skipping symlink check)"; \
    fi

# Full bootstrap on a fresh machine
bootstrap:
    bash bootstrap.sh
