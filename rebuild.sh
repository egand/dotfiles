#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

if [ "$DIR" != "$HOME/.dotfiles" ]; then
  ln -sfn "$DIR" "$HOME/.dotfiles"
fi

if [ -f "$DIR/scripts/smart-paste.swift" ]; then
  mkdir -p "$HOME/.local/bin"
  swiftc -O "$DIR/scripts/smart-paste.swift" -o "$HOME/.local/bin/smart-paste"
fi

if command -v darwin-rebuild >/dev/null 2>&1; then
  sudo darwin-rebuild switch --flake "$HOME/.dotfiles#mac" "$@"
else
  sudo nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake "$HOME/.dotfiles#mac" "$@"
fi

# Post-rebuild: Live reload Herdr server configuration if running
if command -v herdr >/dev/null 2>&1 && herdr status server 2>/dev/null | grep -q "status: running"; then
  echo "🔄 Reloading Herdr configuration..."
  herdr server reload-config >/dev/null 2>&1 || true
fi
