#!/usr/bin/env bash
# ============================================================================
# Script: install.sh
# Purpose: Setup the NVIDIA GPU toggle controller
# Link: https://github.com/arniezhu/nvidia-gpu-toggle
# ============================================================================

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPTS_DIR="$HOME/.local/nvidia-gpu-toggle"

# --- Sanity check ---
if [[ "$EUID" -eq 0 ]]; then
  echo -e "${YELLOW}[WARNING] Do not run this script as root. Exiting.${NC}"
  exit 1
fi

# --- Step 1: Install scripts ---
mkdir -p "$SCRIPTS_DIR"
cp scripts/enable-nvidia.sh "$SCRIPTS_DIR/"
cp scripts/disable-nvidia.sh "$SCRIPTS_DIR/"
chmod +x "$SCRIPTS_DIR/"*.sh

echo "[INFO] Scripts installed to: $SCRIPTS_DIR"

# --- Step 2: Add aliases ---
SHELL_RC="$HOME/.bashrc"
[[ "$SHELL" == *zsh* ]] && SHELL_RC="$HOME/.zshrc"

if ! grep -q "nvidia-on" "$SHELL_RC"; then
  cat <<EOF >> "$SHELL_RC"

# NVIDIA GPU Toggle Aliases
alias nvidia-on='sudo $SCRIPTS_DIR/enable-nvidia.sh'
alias nvidia-off='sudo $SCRIPTS_DIR/disable-nvidia.sh'
EOF

  echo "[INFO] Aliases added to: $SHELL_RC"
else
  echo "[INFO] Aliases already exist in $SHELL_RC"
fi

# --- Step 3: Final info ---
echo -e "[ACTION REQUIRED] Reload your shell config: ${BLUE}source $SHELL_RC${NC}"
echo -e "${GREEN}[SUCCESS] Installation complete.${NC}"
