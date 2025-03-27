# NVIDIA GPU Toggle Controller

A lightweight utility to enable or disable NVIDIA GPU drivers on demand.
Reduce noise, save power, and take full control of your GPU resources.

![License](https://img.shields.io/github/license/arniezhu/nvidia-gpu-toggle?style=flat-square&logo=github)
![Platform](https://img.shields.io/badge/Platform-Ubuntu%20%7C%20Debian-blue?style=flat-square&logo=ubuntu)
![Shell](https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh-brightgreen?style=flat-square&logo=gnubash)
![Clean Uninstall](https://img.shields.io/badge/Uninstall-One%20Command-brightgreen?style=flat-square&logo=gnubash&logoColor=white)
![Status](https://img.shields.io/badge/Status-Stable-success?style=flat-square&logo=checkmarx)

---

## Features
- Enable or disable NVIDIA GPU drivers on demand
- Reduce noise and power consumption when GPU is idle
- Simple aliases for fast control: `nvidia-on` and `nvidia-off`
- Clean and lightweight, pure shell scripts (Bash/Zsh compatible)
- Tested on Ubuntu Desktop and Server editions
- No reboot required to toggle drivers

---

## Use Cases
This tool is for users who need fine-grained control over their NVIDIA GPU drivers,
especially to reduce noise and save power when the GPU is idle.

You may benefit from this tool if you:
- Use **turbine-cooled NVIDIA GPUs** (e.g., RTX 3090 blower style) that run loud even when idle
- Want to **reduce fan noise** and **lower power consumption** when not using the GPU
- Run **AI workloads** or **GPU-intensive tasks** only at specific times, and want to disable the GPU driver during idle periods
- Prefer to manually control when your **GPU drivers are loaded or unloaded**, without rebooting
- Have a **multi-GPU setup** and want to selectively disable specific cards (advanced users)

---

## Supported Systems

- ✅ Ubuntu 20.04 / 22.04 / 24.04 LTS Desktop & Server
- ✅ Debian 11 / 12 (partial support, requires manual initramfs updates)
- ❌ Not compatible with Arch, Fedora, or other non-Debian-based distros
  (may require manual adaptation of `initramfs` commands)

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/arniezhu/nvidia-gpu-toggle.git
   cd nvidia-gpu-toggle
   ```

2. Run the installer:
   ```bash
   chmod +x install.sh && ./install.sh
   ```

This will:
- Copy toggle scripts to `~/.local/nvidia-gpu-toggle/`
- Create `/etc/modprobe.d/blacklist-nvidia.conf` to prevent auto-loading drivers
- Add aliases (`nvidia-on` / `nvidia-off`) to your shell config (`.bashrc` / `.zshrc`)

---

## Uninstallation

To completely remove the NVIDIA GPU Toggle Controller from your system, run:

```bash
chmod +x uninstall.sh && ./uninstall.sh
```

This will:
- Remove all toggle scripts from `~/.local/nvidia-gpu-toggle/`
- Delete all modprobe configs (`blacklist-nvidia.conf` / `nvidia-block.conf`)
- Clean aliases (`nvidia-on` / `nvidia-off`) from your shell config (`.bashrc` / `.zshrc`)

---

## Usage

Run the following commands to control your GPU drivers:

```bash
nvidia-on     # Enable NVIDIA drivers
nvidia-off    # Disable NVIDIA drivers
```

- `nvidia-on` loads the NVIDIA driver modules and removes them from the blacklist
- `nvidia-off` unloads the NVIDIA driver modules and adds them to the blacklist to prevent auto-loading on boot
- If aliases are missing, run: `source ~/.bashrc` or `source ~/.zshrc`

---

## ⚠️  Notes

- **Do NOT run `install.sh` with sudo or as root!**
- The script automatically uses `sudo` for privileged operations (writing blacklist config, updating initramfs, etc.)
- Disabling the NVIDIA driver will prevent the GUI from working if no other GPU is present
- Tested with NVIDIA RTX 3090, 3080, and other cards (blower/turbine coolers benefit the most)
- For best results, run `nvidia-off` via SSH or from a separate TTY (e.g. Ctrl+Alt+F3)
