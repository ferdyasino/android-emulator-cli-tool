# 🧾 Changelog

## [v2.3.0] - 2025-10-25
### Added
- Emulator isolation using `setsid` (safe Ctrl+C)
- Improved boot detection with visual progress
- GPU renderer info check (`glxinfo` + `adb shell dumpsys SurfaceFlinger`)
- Auto ADB reconnect for multiple devices

### Fixed
- Menu continues on invalid input
- Prevents emulator exit when script terminates

---

## [v2.0.0] - 2025-10-24
### Added
- Clone, delete, clear, and launch emulators via CLI
- Debian + AMD GPU compatibility
