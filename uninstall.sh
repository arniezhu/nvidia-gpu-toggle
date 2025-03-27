#!/usr/bin/env bash
# ============================================================================
# Script: uninstall.sh
# Purpose: Remove NVIDIA GPU toggle controller and clean config
# Link: https://github.com/arniezhu/nvidia-gpu-toggle
# ============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTALL_DIR="$HOME/.local/nvidia-gpu-toggle"
BLACKLIST_CONF="/etc/modprobe.d/blacklist-nvidia.conf"
BLOCK_CONF="/etc/modprobe.d/nvidia-block.conf"

# --- Step 1: Remove script directory ---
if [[ -d "$INSTALL_DIR" ]]; then
  rm -rf "$INSTALL_DIR"
  echo "[INFO] Removed script directory: $INSTALL_DIR"
fi

# --- Step 2: Remove modprobe configs ---
if [[ -f "$BLACKLIST_CONF" ]]; then
  sudo rm -f "$BLACKLIST_CONF"
  echo "[INFO] Removed: $BLACKLIST_CONF"
fi

if [[ -f "$BLOCK_CONF" ]]; then
  sudo rm -f "$BLOCK_CONF"
  echo "[INFO] Removed: $BLOCK_CONF"
fi

# --- Step 3: Remove aliases ---
SHELL_RC="$HOME/.bashrc"
[[ "$SHELL" == *zsh* ]] && SHELL_RC="$HOME/.zshrc"
sed -i '/# NVIDIA GPU Toggle Aliases/,+2d' "$SHELL_RC"
echo "[INFO] Removed aliases from: $SHELL_RC"

# --- Step 4: Final notice ---
echo -e "[ACTION REQUIRED] Reload your shell config: ${BLUE}source $SHELL_RC${NC}"
echo -e "${GREEN}[SUCCESS] Uninstalled cleanly.${NC}"
