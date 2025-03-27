#!/usr/bin/env bash
# ============================================================================
# Script: disable-nvidia.sh
# Purpose: Disable NVIDIA drivers and unload GPU modules for silent operation
# Link: https://github.com/arniezhu/nvidia-gpu-toggle
# ============================================================================

YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BLOCK_CONF="/etc/modprobe.d/nvidia-block.conf"
BLACKLIST_CONF="/etc/modprobe.d/blacklist-nvidia.conf"

echo -e "${YELLOW}[NOTE] This script will terminate the graphical session temporarily to safely disable the NVIDIA driver.${NC}"
echo "[INFO] Please run this script via SSH or from a separate TTY (e.g. Ctrl+Alt+F3)."
echo "------------------------------------------------------------"

# --- Stage 1: Check for active NVIDIA processes ---
echo "[INFO] Checking for running processes using NVIDIA GPU..."

NVIDIA_PIDS=$(lsof /dev/nvidia* 2>/dev/null | awk 'NR>1 {print $2}' | sort -u)

if [[ -n "$NVIDIA_PIDS" ]]; then
  echo -e "${YELLOW}[WARNING] The following processes are using NVIDIA GPU:${NC}"
  for pid in $NVIDIA_PIDS; do
    ps -p "$pid" -o pid=,cmd=
  done

  echo
  echo "[ACTION] Kill these processes automatically before proceeding? [y/N] "
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "[INFO] Attempting to terminate NVIDIA processes..."
    for pid in $NVIDIA_PIDS; do
      sudo kill "$pid" && echo "[INFO] Killed PID $pid"
    done
    sleep 3
  else
    echo -e "${YELLOW}[ABORTED] Cannot safely disable NVIDIA while GPU is in use.${NC}"
    exit 1
  fi
fi

# --- Stage 2: Switch to text mode ---
echo "[INFO] Switching to text mode (TTY)..."
sudo systemctl isolate multi-user.target
sleep 3

# --- Stage 3: Unload NVIDIA modules ---
echo "[INFO] Attempting to unload NVIDIA drivers..."
sudo rmmod nvidia_drm 2>/dev/null || echo -e "${YELLOW}[WARNING] Could not unload nvidia_drm${NC}"
sudo rmmod nvidia_modeset 2>/dev/null || echo -e "${YELLOW}[WARNING] Could not unload nvidia_modeset${NC}"
sudo rmmod nvidia_uvm 2>/dev/null || echo -e "${YELLOW}[WARNING] Could not unload nvidia_uvm${NC}"
sudo rmmod nvidia 2>/dev/null || echo -e "${YELLOW}[WARNING] Could not unload nvidia${NC}"

# --- Stage 4: Blacklist and block NVIDIA modules ---
echo "[INFO] Writing blacklist to: $BLACKLIST_CONF"
sudo tee "$BLACKLIST_CONF" > /dev/null <<EOF
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_modeset
blacklist nvidia_uvm
EOF

echo "[INFO] Blocking NVIDIA modules with /bin/false: $BLOCK_CONF"
sudo tee "$BLOCK_CONF" > /dev/null <<EOF
install nvidia /bin/false
install nvidia_uvm /bin/false
install nvidia_drm /bin/false
install nvidia_modeset /bin/false
EOF

# --- Stage 5: Regenerate initramfs ---
echo "[INFO] Updating initramfs..."
sudo update-initramfs -u

# --- Stage 6: Final check and restart GUI if needed ---
echo "------------------------------------------------------------"
if lsmod | grep -q nvidia; then
  echo -e "${YELLOW}[WARNING] Some NVIDIA modules are still loaded.${NC}"
  echo "[INFO] A reboot may be required to fully deactivate the GPU."
else
  echo -e "${GREEN}[SUCCESS] NVIDIA drivers are now OFFLINE. Silent mode activated.${NC}"
fi

# Only prompt if we’re not already in a GUI session
if [[ "$XDG_SESSION_TYPE" != "x11" && "$XDG_SESSION_TYPE" != "wayland" ]]; then
  echo "[ACTION] Return to graphical mode now? [Y/n]"
  read -r resume
  if [[ "$resume" =~ ^[Nn]$ ]]; then
    echo -e "[INFO] You are now in text mode. Run '${BLUE}sudo systemctl start gdm${NC}' to return to GUI."
  else
    echo "[INFO] Restarting graphical session..."
    sudo systemctl start gdm
    echo -e "[INFO] GUI login screen should now be visible."
  fi
fi
