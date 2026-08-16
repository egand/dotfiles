#!/usr/bin/env bash
# Syncs currently installed Homebrew leaves and casks back into homebrew.nix
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
HOMEBREW_NIX="$DIR/homebrew.nix"
QUIET="${1:-}"

if ! command -v brew >/dev/null 2>&1; then
  exit 0
fi

BREWS=$(brew leaves | sort | awk '{print "      \"" $1 "\""}')
CASKS=$(brew list --cask | sort | awk '{print "      \"" $1 "\""}')

cat <<EOF > "$HOMEBREW_NIX"
{ user, ... }:

{
  nix-homebrew = {
    enable = true;
    inherit user;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];

    brews = [
$BREWS
    ];

    casks = [
$CASKS
    ];
  };
}
EOF

if [ "$QUIET" != "--quiet" ]; then
  echo "==> Synchronized brews and casks to homebrew.nix"
fi
