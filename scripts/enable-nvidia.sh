#!/usr/bin/env bash
# ============================================================================
# Script: enable-nvidia.sh
# Purpose: Enable NVIDIA drivers and load GPU modules for AI tasks
# Link: https://github.com/arniezhu/nvidia-gpu-toggle
# ============================================================================

YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BLOCK_CONF="/etc/modprobe.d/nvidia-block.conf"
BLACKLIST_CONF="/etc/modprobe.d/blacklist-nvidia.conf"

# --- Stage 1: Remove blacklist and /bin/false blocks ---
echo "[INFO] Removing module blacklist: $BLACKLIST_CONF"
sudo rm -f "$BLACKLIST_CONF"

echo "[INFO] Removing /bin/false block rules: $BLOCK_CONF"
sudo rm -f "$BLOCK_CONF"

# --- Stage 2: Regenerate initramfs ---
echo "[INFO] Updating initramfs..."
sudo update-initramfs -u

# --- Stage 3: Load NVIDIA modules ---
echo "[INFO] Loading NVIDIA modules..."
sudo modprobe nvidia
sudo modprobe nvidia_uvm
sudo modprobe nvidia_modeset
sudo modprobe nvidia_drm

# --- Stage 4: Check if X11/Wayland is running ---
IS_GUI_RUNNING=false

if loginctl show-session "$(loginctl | awk '/tty/ {print $1; exit}')" -p Type 2>/dev/null | grep -qiE 'x11|wayland'; then
  IS_GUI_RUNNING=true
fi

# --- Stage 5: Launch GUI if not already active ---
if [[ "$IS_GUI_RUNNING" == false ]]; then
  echo "[ACTION] Return to graphical mode now? [Y/n]"
  read -r resume
  if [[ "$resume" =~ ^[Nn]$ ]]; then
    echo -e "[INFO] You are now in text mode. Run '${BLUE}sudo systemctl start gdm${NC}' to return to GUI."
  else
    echo "[INFO] Restarting graphical session..."
    sudo systemctl start gdm
    echo -e "[INFO] GUI login screen should now be visible."
  fi
else
  echo "[INFO] Graphical session already active. No need to restart GUI."
fi

# --- Stage 6: Final status ---
echo
nvidia-smi || echo -e "${YELLOW}[WARNING] NVIDIA-SMI failed. Check if drivers loaded properly.${NC}"
echo -e "${GREEN}[SUCCESS] NVIDIA drivers are now ONLINE and ready for AI acceleration.${NC}"
