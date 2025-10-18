# 🛠 Android Emulator CLI Tool
![Linux](https://img.shields.io/badge/Linux-Supported-blue)
![Bash](https://img.shields.io/badge/Shell-Bash-brightgreen)
![Android](https://img.shields.io/badge/Android-Emulator-orange)
![License](https://img.shields.io/badge/License-MIT-green)

A powerful **terminal-based Android Emulator Manager** for Linux developers.  
Manage emulators like a pro — launch, clone, reset, and delete — all without Android Studio.

---

## 🚀 Features

| Feature | Description |
|---------|-------------|
| ▶️ **Launch Emulator** | Silent launch & return to terminal |
| 🧬 **Clone Emulator** | Create a new named instance & auto-launch |
| 🗑 **Delete Clones** | Removes clone safely (auto-kills if running) |
| 🧼 **Clear & Reboot** | Factory reset any emulator & auto-reboot fresh |
| 🖥 **AMD/Linux Support** | Built-in Vulkan fix for Debian/Ubuntu |
| ⚠️ **Running Check** | Warns if emulator already running |

---

## 🛡 System Requirements

| Requirement | Details |
|-------------|---------|
| OS | Linux (Debian/Ubuntu/Arch tested) |
| Android SDK | Must be installed (`emulator` in PATH) |
| Git & gh | For GitHub integration (optional) |
| CPU | Virtualization Enabled (KVM/QEMU) |

---

## 📦 Installation

```bash
# Clone or copy the script into a folder
mkdir android-emulator-cli-tool
cd android-emulator-cli-tool

# Create the script file
nano run_emulator.sh   # paste the script here

# Make it executable
chmod +x run_emulator.sh
```

### 🔁 Optional: Create a command alias (`emu`)
```bash
echo 'alias emu="~/android-emulator-cli-tool/run_emulator.sh"' >> ~/.bashrc
source ~/.bashrc
```

---

## 📋 Usage

```bash
emu
```

### 🧾 Menu Options

| Option | Action |
|--------|--------|
| 1️⃣ Launch Emulator | Opens selected AVD silently |
| 2️⃣ Clone Emulator | Name it → auto-launch |
| 3️⃣ Delete Clone(s) | Removes only non-Pixel AVDs |
| 4️⃣ Clear & Reboot | Factory reset + fresh boot |
| 5️⃣ Exit | Leave tool |

---

## 🎞 Screenshots / Demo

Add your screenshots or GIFs to the `examples/` folder.

```bash
examples/
├── screenshot.png
└── demo.gif
```

_Add a GIF example here for better documentation._

---

## 🔮 Future Enhancements

- [ ] ADB Integration (install APK on boot)
- [ ] Logcat Viewer (real-time debugging)
- [ ] Batch Emulator Testing
- [ ] Interactive APK deployment

---

## 🤝 Support & Feedback

Found a bug or want a feature?

👉 Open an issue on GitHub  
👉 Or contribute via Pull Request

---

## 🪪 License

This project is licensed under the **MIT License**.

---

## 👨‍💻 Created by Ferdy

Simplifying Android development — one terminal at a time.
