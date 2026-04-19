#!/bin/bash
# install.sh — Downloads and installs the latest APE CLI release on Linux.
#
# Usage:
#   curl -fsSL https://www.ccisne.dev/finite_ape_machine/install.sh | bash
#
# What it does:
#   1. Detects Linux x64
#   2. Downloads the latest .tar.gz from GitHub Releases
#   3. Extracts to ~/.ape/
#   4. Symlinks to ~/.local/bin (XDG standard, in default PATH)
#   5. Runs `ape target get`
#   6. Verifies with `ape version`

set -euo pipefail

REPO="ccisnedev/finite_ape_machine"
INSTALL_DIR="$HOME/.ape"
BIN_DIR="$INSTALL_DIR/bin"
ASSET_NAME="ape-linux-x64.tar.gz"

# ─── Platform check ──────────────────────────────────────────────────────────

ARCH=$(uname -m)
OS=$(uname -s)

if [ "$OS" != "Linux" ]; then
  echo "Error: APE CLI install.sh is for Linux only. Got: $OS" >&2
  exit 1
fi

if [ "$ARCH" != "x86_64" ]; then
  echo "Error: APE CLI requires x86_64. Got: $ARCH" >&2
  exit 1
fi

# ─── Fetch latest release ────────────────────────────────────────────────────

echo ">>> Fetching latest release..."
RELEASE_URL="https://api.github.com/repos/$REPO/releases/latest"
RELEASE_JSON=$(curl -fsSL -H "Accept: application/vnd.github+json" "$RELEASE_URL")

TAG=$(echo "$RELEASE_JSON" | grep -o '"tag_name":\s*"[^"]*"' | head -1 | sed 's/.*"tag_name":\s*"\([^"]*\)".*/\1/')
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | grep -o '"browser_download_url":\s*"[^"]*'"$ASSET_NAME"'"' | head -1 | sed 's/.*"browser_download_url":\s*"\([^"]*\)".*/\1/')

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Error: No $ASSET_NAME asset found in release $TAG." >&2
  exit 1
fi

echo "    Release: $TAG"
echo "    Asset:   $ASSET_NAME"

# ─── Download and extract ────────────────────────────────────────────────────

TEMP_FILE=$(mktemp /tmp/ape-XXXXXX.tar.gz)

echo ">>> Downloading..."
curl -fsSL -o "$TEMP_FILE" "$DOWNLOAD_URL"

# Clean previous installation
if [ -d "$INSTALL_DIR" ]; then
  echo ">>> Removing previous installation..."
  rm -rf "$INSTALL_DIR"
fi

echo ">>> Extracting..."
mkdir -p "$INSTALL_DIR"
tar xzf "$TEMP_FILE" -C "$INSTALL_DIR"
rm -f "$TEMP_FILE"

# Make binary executable
chmod +x "$BIN_DIR/ape"

# ─── PATH integration ────────────────────────────────────────────────────────

# Symlink to ~/.local/bin (XDG standard, in default PATH on most distros)
LINK_DIR="$HOME/.local/bin"
LINK_PATH="$LINK_DIR/ape"
mkdir -p "$LINK_DIR"

if [ -L "$LINK_PATH" ] && [ "$(readlink "$LINK_PATH")" = "$BIN_DIR/ape" ]; then
  echo ">>> Symlink already configured: $LINK_PATH -> $BIN_DIR/ape"
else
  ln -sf "$BIN_DIR/ape" "$LINK_PATH"
  echo ">>> Symlink configured: $LINK_PATH -> $BIN_DIR/ape"
fi

# Ensure ~/.local/bin is in PATH for current session
if [[ ":$PATH:" != *":$LINK_DIR:"* ]]; then
  export PATH="$LINK_DIR:$PATH"
  echo ">>> Added $LINK_DIR to PATH for this session"
else
  echo ">>> PATH already includes $LINK_DIR"
fi

# ─── Deploy and verify ───────────────────────────────────────────────────────

echo ">>> Deploying APE to all targets..."
"$BIN_DIR/ape" target get

echo ">>> Verifying installation..."
VERSION_OUTPUT=$("$BIN_DIR/ape" version)
echo "    $VERSION_OUTPUT"

echo ""
echo ">>> APE CLI installed successfully!"
echo "    Location: $INSTALL_DIR"
echo "    Restart your terminal to use 'ape' from any directory."
