#!/bin/bash
set -euo pipefail

REPO="Dellety/macos-vision-ocr"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="ocr"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[info]${NC} $1"; }
warn()  { echo -e "${YELLOW}[warn]${NC} $1"; }
error() { echo -e "${RED}[error]${NC} $1"; exit 1; }

BINARY_PATH="$INSTALL_DIR/$BINARY_NAME"

# Remove the CLI binary
if [ -f "$BINARY_PATH" ]; then
    info "Removing $BINARY_PATH ..."
    if [ -w "$INSTALL_DIR" ]; then
        rm -f "$BINARY_PATH"
    else
        sudo rm -f "$BINARY_PATH"
    fi
    info "Binary removed."
else
    warn "Binary not found at $BINARY_PATH — nothing to remove."
fi

# Verify
if command -v "$BINARY_NAME" >/dev/null 2>&1; then
    warn "'$BINARY_NAME' is still on PATH (possibly installed elsewhere): $(command -v "$BINARY_NAME")"
else
    info "Successfully uninstalled. Run 'curl -fsSL https://raw.githubusercontent.com/${REPO}/main/install.sh | bash' to reinstall."
fi
