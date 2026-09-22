#!/usr/bin/env bash
# Install custom keyboard layout (US-IT) to User and System Library, and auto-select via TIS if available.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
LAYOUT_BUNDLE="US-IT.bundle"
SOURCE_BUNDLE="$DIR/keyboard/$LAYOUT_BUNDLE"
KEYLAYOUT_FILE="$SOURCE_BUNDLE/Contents/Resources/US-IT.keylayout"
ICNS_FILE="$SOURCE_BUNDLE/Contents/Resources/US-IT.icns"

USER_DEST="$HOME/Library/Keyboard Layouts"
SYS_DEST="/Library/Keyboard Layouts"

if [ ! -d "$SOURCE_BUNDLE" ]; then
  echo "    Warning: $SOURCE_BUNDLE not found, skipping keyboard setup."
  exit 0
fi

echo "==> Installing $LAYOUT_BUNDLE to user Keyboard Layouts..."
mkdir -p "$USER_DEST"
rm -rf "$USER_DEST/$LAYOUT_BUNDLE" "$USER_DEST/US-IT.keylayout" "$USER_DEST/US-IT.icns"
cp -r "$SOURCE_BUNDLE" "$USER_DEST/"
if [ -f "$KEYLAYOUT_FILE" ]; then cp "$KEYLAYOUT_FILE" "$USER_DEST/"; fi
if [ -f "$ICNS_FILE" ]; then cp "$ICNS_FILE" "$USER_DEST/"; fi
touch "$USER_DEST"

# Also install system-wide if sudo credentials are available
if sudo -n true 2>/dev/null; then
  echo "==> Installing layout system-wide to $SYS_DEST (for login screen & all users)..."
  sudo rm -rf "$SYS_DEST/$LAYOUT_BUNDLE" "$SYS_DEST/US-IT.keylayout" "$SYS_DEST/US-IT.icns"
  sudo cp -r "$SOURCE_BUNDLE" "$SYS_DEST/"
  if [ -f "$KEYLAYOUT_FILE" ]; then sudo cp "$KEYLAYOUT_FILE" "$SYS_DEST/"; fi
  if [ -f "$ICNS_FILE" ]; then sudo cp "$ICNS_FILE" "$SYS_DEST/"; fi
  sudo chmod -R 755 "$SYS_DEST/$LAYOUT_BUNDLE" 2>/dev/null || true
  sudo touch "$SYS_DEST"
fi

# Attempt programmatic activation via Carbon Text Input Services
TIS_STATUS="$(swift - 2>/dev/null << 'SWIFT'
import Carbon
import Foundation

guard let list = TISCreateInputSourceList(nil, true)?.takeRetainedValue() as? [TISInputSource] else {
    print("status:not_indexed")
    exit(0)
}

for source in list {
    guard let idPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { continue }
    let id = Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue() as String
    if id.contains("US-IT") || id.lowercased().contains("us-it") {
        let isEnPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsEnabled)
        let isEnabled = isEnPtr != nil && CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(isEnPtr!).takeUnretainedValue())
        if isEnabled {
            let selectErr = TISSelectInputSource(source)
            if selectErr == 0 {
                print("status:selected")
                exit(0)
            }
        } else {
            _ = TISEnableInputSource(source)
            let selectErr = TISSelectInputSource(source)
            if selectErr == 0 {
                print("status:selected")
                exit(0)
            }
            print("status:indexed_pending_user_enable")
            exit(0)
        }
    }
}
print("status:not_indexed")
SWIFT
)"

case "$TIS_STATUS" in
  "status:selected")
    echo "✨ US-IT keyboard layout is active and selected!"
    ;;
  "status:indexed_pending_user_enable"|"status:not_indexed"|*)
    echo "ℹ️  US-IT layout installed successfully."
    echo "    macOS requires a logout or restart before custom keyboard layouts can be selected."
    echo "    After logging back in:"
    echo "    1. Open System Settings -> Keyboard -> Input Sources (click 'Edit...')."
    echo "    2. Click '+' and select 'Others' in the sidebar (or search 'US-IT')."
    echo "    3. Select 'US-IT' and click 'Add'."
    echo "    (Once added in Settings, running 'just keyboard' will auto-select it)."
    ;;
esac
