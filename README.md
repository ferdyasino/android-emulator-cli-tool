# 🛠 Android Emulator CLI Tool  
![Linux](https://img.shields.io/badge/Linux-Supported-blue)
![Bash](https://img.shields.io/badge/Shell-Bash-brightgreen)
![Android](https://img.shields.io/badge/Android-Emulator-orange)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/Version-v2.3.0-purple)

A powerful **terminal-based Android Emulator Manager** for Linux developers.  
Manage AVDs like a pro — launch, clone, reset, and delete — all without Android Studio.

👉 **[Skip to Demo Gallery ➡️](#-demo-gallery)**

---

## 🚀 Features (v2.3.0)

| Feature | Description |
|---------|-------------|
| ▶️ **Launch Emulator** | Silent launch & background detach (`setsid`) |
| 🧬 **Clone Emulator** | Create named copies & auto-launch |
| 🗑 **Delete Clones** | Removes clones safely (auto-stops if running) |
| 🧼 **Clear & Reboot** | Factory reset & auto-boot clean Android |
| 🖥 **AMD GPU Acceleration** | Uses `DRI_PRIME=1` for external GPU (RX 550 / Vega 8) |
| 🧩 **Auto ADB Reconnect** | Automatically connects to `localhost:5554` & `5555` |
| ⏳ **Boot Progress Checker** | Displays Android boot progress until ready |
| 🧠 **Safe Ctrl + C Exit** | Script exits safely while emulator stays alive |
| 🔍 **GPU Renderer Info** | Shows both host OpenGL & emulator GLES renderers |

---

## 🛡 System Requirements

| Requirement | Details |
|-------------|---------|
| **OS** | Linux (Debian 12 / Ubuntu 22+ tested) |
| **Android SDK** | `emulator` available in `$PATH` |
| **Virtualization** | KVM/QEMU enabled |
| **GPU** | AMD Radeon (integrated + discrete) supported |

---

## 📦 Installation

```bash
git clone https://github.com/<your-username>/android-emulator-cli-tool.git
cd android-emulator-cli-tool
chmod +x run_emulator.sh
sudo mv run_emulator.sh /usr/local/bin/run_emulator

# Add alias if not already present
grep -qxF 'alias emu="run_emulator"' ~/.bashrc || echo 'alias emu="run_emulator"' >> ~/.bashrc

# Reload bash configuration
source ~/.bashrc