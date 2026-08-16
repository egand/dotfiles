#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
LAYOUT_NAME="US-IT.bundle"
SOURCE_PATH="$DIR/keyboard/$LAYOUT_NAME"
DEST_PATH="/Library/Keyboard Layouts"

if [ -d "$SOURCE_PATH" ]; then
  echo "==> Installing $LAYOUT_NAME to $DEST_PATH (requires sudo)..."
  sudo rm -rf "$DEST_PATH/$LAYOUT_NAME"
  sudo cp -r "$SOURCE_PATH" "$DEST_PATH"
  sudo chown -R root:wheel "$DEST_PATH/$LAYOUT_NAME"
  echo "    Installed. Restart or Log Out to enable in Settings -> Keyboard -> Input Sources."
else
  echo "    Warning: $SOURCE_PATH not found, skipping."
fi
