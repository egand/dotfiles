#!/usr/bin/env bash
# Native macOS Sonoma / Sequoia Touch ID PAM Configuration
# Enables Touch ID for sudo via /etc/pam.d/sudo_local (survives macOS updates)
set -euo pipefail

TARGET="/etc/pam.d/sudo_local"
TEMPLATE="/etc/pam.d/sudo_local.template"

# Ensure script runs with root permissions
if [ "$EUID" -ne 0 ]; then
  echo "==> Requesting sudo privileges to configure Touch ID PAM module..."
  exec sudo bash "$0" "$@"
fi

# Clean up legacy Nix symlink if present to establish a standalone native configuration
if [ -L "$TARGET" ]; then
  echo "==> Replacing legacy symlink at $TARGET with native file..."
  rm -f "$TARGET"
fi

if [ ! -f "$TARGET" ]; then
  if [ -f "$TEMPLATE" ]; then
    echo "==> Creating $TARGET from $TEMPLATE with Touch ID enabled..."
    sed -E 's/^#[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so/auth       sufficient     pam_tid.so/' "$TEMPLATE" > "$TARGET"
  else
    echo "==> Creating $TARGET with Touch ID enabled..."
    cat <<'EOF' > "$TARGET"
# sudo_local: local config file which survives system update and is included for sudo
auth       sufficient     pam_tid.so
EOF
  fi
  chmod 644 "$TARGET"
  chown root:wheel "$TARGET" 2>/dev/null || true
  echo "    Successfully created $TARGET."
else
  echo "==> $TARGET exists. Ensuring Touch ID is configured..."
  if grep -q "pam_tid.so" "$TARGET"; then
    if grep -E -q "^#[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so" "$TARGET"; then
      echo "    Uncommenting pam_tid.so in $TARGET..."
      sed -i '' -E 's/^#[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so/auth       sufficient     pam_tid.so/' "$TARGET"
      echo "    Successfully enabled pam_tid.so in $TARGET."
    else
      echo "    Touch ID (pam_tid.so) is already active in $TARGET."
    fi
  else
    echo "    Adding pam_tid.so to top of $TARGET..."
    TMP_FILE="$(mktemp)"
    {
      echo "# sudo_local: local config file which survives system update and is included for sudo"
      echo "auth       sufficient     pam_tid.so"
      cat "$TARGET"
    } > "$TMP_FILE"
    cat "$TMP_FILE" > "$TARGET"
    rm -f "$TMP_FILE"
    chmod 644 "$TARGET"
    chown root:wheel "$TARGET" 2>/dev/null || true
    echo "    Successfully added pam_tid.so to $TARGET."
  fi
fi

echo "==> Touch ID PAM configuration complete."
