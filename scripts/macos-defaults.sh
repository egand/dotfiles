#!/usr/bin/env bash
# macOS System Defaults Configuration Script
# Translates declarative macOS preferences into idempotent defaults write commands
set -euo pipefail

echo "==> Applying macOS system defaults..."

# Close any open System Settings panes to avoid overriding changes
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# ---------------------------------------------------------
# Global Domain (NSGlobalDomain)
# ---------------------------------------------------------
echo "==> Configuring Global Domain preferences..."

# Interface style: Dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Fast key repeat rate and shorter delay before repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 20

# Enable key repeat in Vim/Neovim (disable accent press-and-hold popup)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Show all filename extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Keep menu bar visible on desktop (disable autohide for glanceable clock & status)
defaults write NSGlobalDomain _HIHideMenuBar -bool false

# ---------------------------------------------------------
# Smart Substitutions (Disable for clean coding)
# ---------------------------------------------------------
echo "==> Disabling automatic substitutions (smart quotes, dashes, spellcheck)..."
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# ---------------------------------------------------------
# Dialogs & Audio
# ---------------------------------------------------------
echo "==> Configuring save dialogs and audio feedback..."

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Mute volume change beep feedback
defaults write NSGlobalDomain "com.apple.sound.beep.feedback" -int 0

# ---------------------------------------------------------
# Dock Preferences
# ---------------------------------------------------------
echo "==> Configuring Dock..."

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Instant dock popup (zero animation delay and duration)
defaults write com.apple.dock autohide-delay -float 0.0
defaults write com.apple.dock autohide-time-modifier -float 0.0

# Do not show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Do not automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Disable all Hot Corners (Top-Left, Top-Right, Bottom-Left, Bottom-Right: 1 = None, 0 = No modifier)
defaults write com.apple.dock wvous-tl-corner -int 1
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 1
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 1
defaults write com.apple.dock wvous-br-modifier -int 0

# ---------------------------------------------------------
# Finder Preferences
# ---------------------------------------------------------
echo "==> Configuring Finder..."

# List view by default (Nlsv: List, icnv: Icon, clmv: Column, glyv: Gallery)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Keep desktop clean (hide desktop icons)
defaults write com.apple.finder CreateDesktop -bool false

# Show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show breadcrumb path bar and status bar
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable file extension change warning
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Automatically empty items in the Trash after 30 days
defaults write com.apple.finder FXRemoveOldTrashItems -bool true

# ---------------------------------------------------------
# Screen Capture
# ---------------------------------------------------------
echo "==> Configuring Screen Capture..."

mkdir -p "$HOME/Pictures/Screenshots"
# Save screenshots to dedicated Screenshots folder
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

# Disable dropshadow in window screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Save screenshots in PNG format
defaults write com.apple.screencapture type -string "png"

# ---------------------------------------------------------
# Trackpad (Tap to Click)
# ---------------------------------------------------------
echo "==> Configuring Trackpad (tap to click)..."
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ---------------------------------------------------------
# Desktop Services (.DS_Store suppression)
# ---------------------------------------------------------
echo "==> Configuring Desktop Services (suppress .DS_Store creation)..."
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# ---------------------------------------------------------
# OpenSuperWhisper Preferences
# ---------------------------------------------------------
echo "==> Configuring OpenSuperWhisper preferences..."
defaults write ru.starmel.OpenSuperWhisper hasCompletedOnboarding -bool true
defaults write ru.starmel.OpenSuperWhisper selectedEngine -string "whisper"
defaults write ru.starmel.OpenSuperWhisper whisperLanguage -string "en"
defaults write ru.starmel.OpenSuperWhisper modifierOnlyHotkey -string "rightCommand"
defaults write ru.starmel.OpenSuperWhisper startHiddenInMenuBar -bool true
defaults write ru.starmel.OpenSuperWhisper autoPasteTranscription -bool true
defaults write ru.starmel.OpenSuperWhisper KeyboardShortcuts_toggleRecord -string '{"carbonKeyCode":50,"carbonModifiers":2048}'
defaults write ru.starmel.OpenSuperWhisper KeyboardShortcuts_escape -string '{"carbonKeyCode":53,"carbonModifiers":0}'

# ---------------------------------------------------------
# Power Management (pmset)
# ---------------------------------------------------------
echo "==> Configuring Power Management..."
if [ "$EUID" -eq 0 ]; then
  pmset -b displaysleep 10 disksleep 10 sleep 15
  pmset -c displaysleep 15 disksleep 10 sleep 30
  echo "    Power management settings applied successfully."
elif command -v sudo >/dev/null 2>&1; then
  if sudo -n true 2>/dev/null; then
    sudo pmset -b displaysleep 10 disksleep 10 sleep 15
    sudo pmset -c displaysleep 15 disksleep 10 sleep 30
    echo "    Power management settings applied successfully via sudo."
  else
    echo "    Note: sudo privileges required to configure pmset (run with sudo or authenticate sudo first)."
  fi
else
  echo "    Warning: sudo not available, skipping pmset configuration."
fi

# ---------------------------------------------------------
# Restart affected services
# ---------------------------------------------------------
echo "==> Restarting affected services (Dock, Finder)..."
killall Dock Finder 2>/dev/null || true

echo "==> macOS system defaults configured successfully."
