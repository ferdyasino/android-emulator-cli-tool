# 🛠 Android Emulator CLI Tool  
![Linux](https://img.shields.io/badge/Linux-Supported-blue)
![Bash](https://img.shields.io/badge/Shell-Bash-brightgreen)
![Android](https://img.shields.io/badge/Android-Emulator-orange)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/Version-v2.6.3-purple)

A powerful **terminal-based Android Emulator Manager** for Linux developers.  
Manage AVDs like a pro — launch, clone, reset, or delete — all without Android Studio.

👉 **[Skip to Demo Gallery ➡️](#-demo-gallery)**

---

## 🚀 Features (v2.6.3)

| Feature | Description |
|---------|-------------|
| ▶️ **Launch Emulator** | Silent launch & background detach (`setsid`) |
| 🧬 **Clone Emulator** | Create named copies & auto-launch instantly |
| 🗑 **Delete Clones** | Safely remove clones (auto-stops if running) |
| 🧼 **Clear & Reboot** | Factory reset & auto-reboot Android |
| 🎮 **AMD GPU Acceleration** | Uses `DRI_PRIME=1` for external GPUs (RX 550 / Vega 8) |
| 🧩 **Auto ADB Reconnect** | Connects dynamically to active emulator ports |
| ⏳ **Boot Progress Checker** | Waits until Android system boot completes |
| 🧠 **Safe Ctrl+C Exit** | Gracefully exits CLI while emulator keeps running |
| 🔍 **GPU Renderer Info** | Displays both host OpenGL and emulator GLES renderers |
| 🌐 **Global + Local Backend Scanner (New)** | Auto-detects Docker and local backend ports, checks `/health` endpoints, and logs online services |
| 🧾 **Auto GitHub Release Workflow** | Publishes tagged versions with changelog + script attachment |

---

## 🛡 System Requirements

| Requirement | Details |
|-------------|----------|
| **OS** | Linux (Debian 12 / Ubuntu 22+ tested) |
| **Android SDK** | `emulator` available in `$PATH` |
| **Virtualization** | KVM/QEMU enabled |
| **GPU** | AMD Radeon (integrated or discrete) supported |
| **Optional** | Docker (for backend auto-scan) |

---

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/<your-username>/android-emulator-cli-tool.git
cd android-emulator-cli-tool

# Make executable
chmod +x run_emulator.sh

# Optionally install globally
sudo mv run_emulator.sh /usr/local/bin/run_emulator

# Add alias (optional)
grep -qxF 'alias emu="run_emulator"' ~/.bashrc || echo 'alias emu="run_emulator"' >> ~/.bashrc

# Reload bash configuration
source ~/.bashrc
```

---

## 🧩 Usage

Run directly or via alias:
```bash
./run_emulator.sh
# or
emu
```

### 🧭 Main Menu
```
1) Launch Emulator
2) Clone Emulator (create & launch)
3) Delete Clone(s)
4) Clear Emulator (Factory Reset + Auto Reboot)
5) Check GPU Renderer
6) Exit
```

---

## 🧱 Global Backend Scanner

Automatically checks for:
- 🐳 **Docker-exposed services** (`docker ps` → detects ports like 8081, 3001, etc.)
- 💻 **Common local dev ports** (`3000–9090`)
- 📡 **Endpoints:** `/health` and `/api/health`
- 🧠 Detects `ok`, `healthy`, or `success` responses  
- 🚀 **Non-blocking:** emulator still boots even if no backends are live  

**Example output:**
```
🌐 Global + Local Backend Scanner
🐳 Detected exposed Docker ports: 8081 3001
🧩 Scanning ports: 8081 3001 5173 8080 8022 9090 5000
✅ Healthy → http://localhost:8081/health
⚠️ http://localhost:3001/health → 404 (no health endpoint)
🧭 Proceeding with emulator launch (non-blocking mode)...
```

---

## 🧾 Changelog Highlights

### **v2.6.3 – Global + Local Backend Scanner**
- Auto-detects Docker ports & local services  
- Checks `/health` & `/api/health` endpoints  
- Unified backend logic and faster scanning  
- Auto GitHub release workflow added  
➡️ [Full Changelog →](./CHANGELOG.md)

---

## 📸 Demo Gallery

| Action | GIF |
|--------|-----|
| 🧼 Clear & Reboot | ![clear&reboot](./clear%26reboot.gif) |
| 🧬 Clone Emulator | ![clone](./clone.gif) |
| 🗑 Delete Clone | ![delete](./delete.gif) |
| ▶️ Launch Emulator | ![launch](./launch.gif) |

---

## 🪪 License

**MIT License**  
Copyright © 2025 Ferdinand Asino

---

## 🧑‍💻 Author

**Ferdy Asino**  
Debian • AMD GPU • Android Developer Tools  
📧 [ferdyasino@gmail.com](mailto:ferdyasino@gmail.com)

---

## 🌟 Show Support

If this tool saves you time, consider giving it a ⭐ on GitHub —  
it helps the project stay active and evolve 🚀