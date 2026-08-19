#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
LAYOUT_NAME="US-IT.bundle"
SOURCE_PATH="$DIR/keyboard/$LAYOUT_NAME"
DEST_PATH="$HOME/Library/Keyboard Layouts"

if [ -d "$SOURCE_PATH" ]; then
  echo "==> Installing $LAYOUT_NAME to $DEST_PATH..."
  mkdir -p "$DEST_PATH"
  rm -rf "$DEST_PATH/$LAYOUT_NAME"
  cp -r "$SOURCE_PATH" "$DEST_PATH"
  echo "    Installed to user Keyboard Layouts. Enable in System Settings -> Keyboard -> Input Sources."
else
  echo "    Warning: $SOURCE_PATH not found, skipping."
fi
