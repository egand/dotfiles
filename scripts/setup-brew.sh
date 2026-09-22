#!/usr/bin/env bash
# Resilient Homebrew Bundle runner
# Continues on non-fatal package failures, logs errors, and queues messages for the end-of-run summary.
set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
ERR_LOG="${TMPDIR:-/tmp}/dotfiles-errors.log"
BREW_LOG="${TMPDIR:-/tmp}/dotfiles-brew.log"
BREWFILE="$DIR/Brewfile"

if ! command -v brew >/dev/null 2>&1; then
  echo "Error: Homebrew is not installed or not in PATH." | tee -a "$ERR_LOG"
  exit 1
fi

echo "==> Installing packages from Brewfile via Homebrew Bundle..."
if [ ! -f "$BREWFILE" ]; then
  echo "Error: Brewfile not found at $BREWFILE" | tee -a "$ERR_LOG"
  exit 1
fi

# Run brew bundle, streaming output to console and capturing to log
# We use a subshell and temporary pipe to preserve real-time streaming
set +e
brew bundle --file="$BREWFILE" 2>&1 | tee "$BREW_LOG"
BUNDLE_STATUS=${PIPESTATUS[0]}
set -e

if [ "$BUNDLE_STATUS" -eq 0 ]; then
  echo "    Homebrew bundle completed successfully."
else
  echo ""
  echo "⚠️  Some Homebrew packages or casks failed to install."
  echo "    Continuing setup without aborting..."
  {
    echo "--- Homebrew Package Failures (Brewfile) ---"
    # Extract failed lines from brew bundle log
    grep -E "(Error|failed!|Warning: Cask|unavailable|disabled)" "$BREW_LOG" || cat "$BREW_LOG"
    echo "Full log saved to: $BREW_LOG"
    echo ""
  } >> "$ERR_LOG"
fi

exit 0
