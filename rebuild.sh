#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

if [ "$DIR" != "$HOME/.dotfiles" ]; then
  ln -sfn "$DIR" "$HOME/.dotfiles"
fi

if command -v darwin-rebuild >/dev/null 2>&1; then
  exec sudo darwin-rebuild switch --flake "$HOME/.dotfiles#mac" "$@"
else
  exec sudo nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake "$HOME/.dotfiles#mac" "$@"
fi
