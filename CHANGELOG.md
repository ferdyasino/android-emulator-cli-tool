# 🧾 Changelog

## [v2.6.3] - 2025-10-31
### Added
- **Global + Local Backend Scanner**
  - Auto-detects exposed Docker ports (`docker ps`)  
  - Scans both Docker and common local ports (3000–9090)  
  - Checks `/health` and `/api/health` endpoints for `ok`, `healthy`, or `success` responses  
  - Displays clear summaries with container status and live endpoints
- Always proceeds to emulator boot (non-blocking mode)
- Cleaner console visuals with emoji-based output

### Improved
- Faster backend scanning with shorter (2s) timeout per endpoint  
- Unified backend connectivity logic across local and containerized services  
- Smarter fallback when Docker is unavailable  
- Updated tool version display to **v2.6.3**

### Fixed
- Removed redundant backend prompts when no services are running  
- Streamlined Docker detection and error handling for smoother logs

---

## [v2.6.2] - 2025-10-25
### Added
- Localhost-first backend health check (fallback to `10.0.2.2` for emulator bridge)
- Automatic Docker container health summary (shows `healthy`, `unhealthy`, etc.)
- Improved backend retry detection and cleaner log output
- Debian-ready configuration for AMD GPU (RX 550) with `DRI_PRIME` isolation

### Fixed
- Backend health prompt no longer blocks when API is already online
- Simplified status handling and suppressed duplicate warnings
- Streamlined connection logic between Docker backend and Android emulator

---

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
