export PATH := "/opt/homebrew/bin:/opt/homebrew/sbin:" + env_var('PATH')

# Default recipe (alias for sync)
default: sync

# Run complete setup on a fresh machine
setup:
    @rm -f "${TMPDIR:-/tmp}/dotfiles-errors.log" "${TMPDIR:-/tmp}/dotfiles-brew.log"
    @just folders || echo "⚠️ Folders setup reported an issue." >> "${TMPDIR:-/tmp}/dotfiles-errors.log"
    @just keyboard || echo "⚠️ Keyboard setup reported an issue." >> "${TMPDIR:-/tmp}/dotfiles-errors.log"
    @just sync || echo "⚠️ Sync setup reported an issue." >> "${TMPDIR:-/tmp}/dotfiles-errors.log"
    @just paste || echo "⚠️ Paste helper compilation reported an issue." >> "${TMPDIR:-/tmp}/dotfiles-errors.log"
    @just brew || echo "⚠️ Brew bundle reported an issue." >> "${TMPDIR:-/tmp}/dotfiles-errors.log"
    @just runtimes || echo "⚠️ Mise runtimes setup reported an issue." >> "${TMPDIR:-/tmp}/dotfiles-errors.log"
    @just macos || echo "⚠️ macOS defaults setup reported an issue." >> "${TMPDIR:-/tmp}/dotfiles-errors.log"
    @just touchid || echo "⚠️ Touch ID setup reported an issue." >> "${TMPDIR:-/tmp}/dotfiles-errors.log"
    @just summary

# Mirror configs to $HOME via GNU Stow without folding directories
sync:
    mkdir -p "$HOME/.config/herdr" "$HOME/Library/LaunchAgents" "$HOME/.local/bin"
    (cd stow && stow --no-folding -t "$HOME" --restow *)
    @if [ -f scripts/smart-paste.swift ] && [ ! -f "$HOME/.local/bin/smart-paste" ]; then just paste; fi
    @if [ -f scripts/awdl ] && [ ! -L "$HOME/.local/bin/awdl" ]; then ln -sfn "$PWD/scripts/awdl" "$HOME/.local/bin/awdl"; fi

# Compile smart-paste Swift helper for Herdr multiplexer
paste:
    mkdir -p "$HOME/.local/bin"
    swiftc -O scripts/smart-paste.swift -o "$HOME/.local/bin/smart-paste"

# Unlink a specific stow package
unlink package:
    (cd stow && stow -t "$HOME" -D {{ package }})

# Install and update packages via Homebrew Bundle (resilient)
brew:
    bash scripts/setup-brew.sh

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

# Display setup completion summary and any recorded errors
summary:
    @if [ -s "${TMPDIR:-/tmp}/dotfiles-errors.log" ]; then \
        echo ""; \
        echo "=============================================================================="; \
        echo "⚠️  Setup completed with some non-fatal warnings or package failures:"; \
        echo "=============================================================================="; \
        cat "${TMPDIR:-/tmp}/dotfiles-errors.log"; \
        echo "=============================================================================="; \
        echo "Review the log files indicated above or re-run specific recipes (e.g. 'just brew')."; \
    else \
        echo ""; \
        echo "=============================================================================="; \
        echo "✨ Setup completed successfully! All steps passed without errors."; \
        echo "=============================================================================="; \
    fi

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
        (cd stow && stow --no-folding -t "$HOME" --simulate --restow * 2>&1) || true; \
    else \
        echo "    (stow not installed or stow directory missing; skipping symlink check)"; \
    fi

# Full bootstrap on a fresh machine
bootstrap:
    bash bootstrap.sh
