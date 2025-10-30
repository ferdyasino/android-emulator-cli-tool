#!/bin/bash
# ==============================================
# Android Emulator CLI Tool – Debian + AMD GPU
# Version: 2.6.3
# Author: Ferdy
# ==============================================

AVD_PATH="$HOME/.android/avd"
VERSION="v2.6.3"

# ---- Environment Fix for Debian + AMD GPUs ----
export QT_QPA_PLATFORM=xcb
export ANDROID_EMULATOR_VULKAN=disabled

# ---- Force external GPU (AMD Radeon RX 550 on /dev/dri/card1) ----
export DRI_PRIME=1
export DRI_DEVICE=/dev/dri/card1
echo "🎮 Using external GPU device: $DRI_DEVICE"
echo "🧭 Android Emulator CLI Tool $VERSION by Ferdy"

# ---- Graceful exit on Ctrl+C ----
cleanup() {
  echo ""
  echo "🧹 Cleaning up CLI only (emulator stays running)..."
  adb kill-server >/dev/null 2>&1
  echo "👋 Exiting Android Emulator Tool. Goodbye!"
  exit 0
}
trap cleanup SIGINT

# ---- Global + Local Backend Health Scanner ----
check_backend() {
  echo ""
  echo "🌐 Global + Local Backend Scanner"
  echo "==============================="

  # 🐳 Auto-detect published Docker ports
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    ports=($(docker ps --format "{{.Ports}}" \
      | grep -oP "(?<=:)\d+(?=-)" \
      | sort -u))
    if [ ${#ports[@]} -gt 0 ]; then
      echo "🐳 Detected exposed Docker ports: ${ports[*]}"
    else
      echo "⚠️ No exposed Docker ports detected."
      ports=()
    fi
  else
    echo "⚠️ Docker not available or not running."
    ports=()
  fi

  # ➕ Add common local dev ports if not already in list
  local common_ports=(3000 3001 5173 8080 8081 8022 9090 5000)
  for p in "${common_ports[@]}"; do
    [[ " ${ports[*]} " =~ " $p " ]] || ports+=("$p")
  done

  echo "🧩 Scanning ports: ${ports[*]}"
  local found=0
  local total_checked=0

  for port in "${ports[@]}"; do
    for path in "/health" "/api/health"; do
      local url="http://localhost:${port}${path}"
      local code response
      code=$(curl -s --connect-timeout 2 -o /tmp/scan.txt -w "%{http_code}" "$url" || echo 000)
      response=$(< /tmp/scan.txt)
      ((total_checked++))

      if [ "$code" = "200" ] && grep -Eiq "ok|success|healthy" <<<"$response"; then
        echo "✅ Healthy → $url"
        ((found++))
        break
      elif [ "$code" = "000" ]; then
        continue
      elif [ "$code" = "404" ]; then
        echo "⚠️ $url → 404 (no health endpoint)"
      else
        echo "❌ $url → HTTP $code"
      fi
    done
  done

  echo "==============================="
  if [ "$found" -gt 0 ]; then
    echo "📊 $found healthy endpoint(s) detected across ${#ports[@]} port(s)."
  else
    echo "🚫 No healthy services detected (checked $total_checked URLs)."
  fi

  echo ""
  echo "🐳 Running containers overview:"
  if command -v docker >/dev/null 2>&1; then
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" \
      | grep -E "commhub|sms_voip|admin_portal|drachtio|postgres" \
      || echo "⚠️ No relevant containers running."
  else
    echo "⚠️ Docker command not found."
  fi

  echo ""
  echo "🧭 Proceeding with emulator launch (non-blocking mode)..."
  echo ""
}

# ---- Helper: Wait for emulator boot ----
wait_for_boot() {
  echo "⌛ Waiting for Android OS to boot..."
  local retries=0
  local max_retries=60
  local device
  device=$(adb devices | grep -E "emulator-[0-9]+" | grep -v offline | head -n1 | awk '{print $1}')
  if [ -z "$device" ]; then
    echo "⚠️ No online emulator found; skipping boot check."
    return 0
  fi

  echo "📱 Monitoring boot status on $device..."
  while [ $retries -lt $max_retries ]; do
    local boot_status
    boot_status=$(adb -s "$device" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
    if [ "$boot_status" = "1" ]; then
      echo "✅ Android OS on $device is fully booted."
      return 0
    fi
    if (( retries % 5 == 0 )); then
      echo "⏳ Waiting... (attempt $retries/$max_retries)"
    fi
    ((retries++))
    sleep 2
  done
  echo "⚠️ Boot check timed out after $((max_retries * 2))s; emulator likely ready."
}

# ---- List AVDs ----
list_avds() {
  mapfile -t EMULATORS < <(emulator -list-avds | sort -V)
  if [ ${#EMULATORS[@]} -eq 0 ]; then
    echo "❌ No AVDs found. Please create one in Android Studio first."
    exit 1
  fi
}

# ---- Detect Clone (non-Pixel) ----
is_clone_name() { [[ "$1" != Pixel* ]]; }

# ---- Check if Emulator is Running ----
is_running() { pgrep -f "qemu-system-x86_64.*@$1" >/dev/null; }

# ---- Validate numeric menu choice ----
validate_choice() {
  local CHOICE="$1"
  local MAX="$2"
  [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "$MAX" ]
}

# ---- Clean ADB & connect to emulator dynamically ----
adb_connect_emulator() {
  adb kill-server >/dev/null 2>&1
  adb start-server >/dev/null 2>&1
  sleep 3
  local port
  port=$(ps -ef | grep qemu-system-x86_64 | grep -oP '(?<=-ports )\d+,\d+' | head -n1 | cut -d',' -f1)
  if [ -n "$port" ]; then
    adb connect "localhost:$port" >/dev/null 2>&1
    echo "🔗 Connected to emulator port: $port"
  else
    echo "⚠️ Could not detect emulator port automatically."
  fi
}

# ---- Silent Launch ----
silent_launch() {
  local NAME="$1"
  if is_running "$NAME"; then
    echo "⚠️ $NAME is already running."
    return
  fi

  echo "🚀 Launching: $NAME (External GPU: RX 550)..."
  nohup setsid emulator @"$NAME" -accel on -gpu host -no-snapshot >/dev/null 2>&1 &
  disown

  sleep 8
  adb_connect_emulator
  echo "🔍 Checking active emulator connection..."
  adb devices | grep "emulator-" | grep -v offline || echo "⚠️ No active emulator detected."
  wait_for_boot
  echo "✔ Emulator $NAME ready!"
}

# ---- Silent Clone Launch ----
silent_launch_clone() {
  local NAME="$1"
  echo "🚀 Launching clone: $NAME (External GPU: RX 550)..."
  nohup setsid emulator @"$NAME" -read-only -accel on -gpu host -no-snapshot >/dev/null 2>&1 &
  disown
  sleep 8
  adb_connect_emulator
  wait_for_boot
  echo "✔ Clone $NAME ready!"
}

# ---- Clear & Auto Reboot Emulator ----
clear_and_reboot() {
  list_avds
  echo "==============================="
  echo "   CLEAR & REBOOT EMULATOR     "
  echo "==============================="
  local i=1
  for EMU in "${EMULATORS[@]}"; do echo "  $i) $EMU"; ((i++)); done
  echo ""
  read -p "Select emulator to factory reset (1-${#EMULATORS[@]}): " CHOICE
  if ! validate_choice "$CHOICE" "${#EMULATORS[@]}"; then echo "❌ Invalid selection."; return; fi
  local NAME="${EMULATORS[$((CHOICE-1))]}"
  echo "🛑 Stopping $NAME..."
  pkill -f "qemu-system-x86_64.*@$NAME" >/dev/null 2>&1
  echo "🧼 Wiping user data..."
  setsid emulator @"$NAME" -wipe-data -no-snapshot -no-boot-anim -accel on -gpu host >/dev/null 2>&1 &
  sleep 10
  echo "♻️ Rebooting..."
  nohup setsid emulator @"$NAME" -accel on -gpu host -no-snapshot >/dev/null 2>&1 &
  disown
  adb_connect_emulator
  wait_for_boot
}

# ---- Clone Emulator ----
clone_avd() {
  list_avds
  echo "==============================="
  echo "        CLONE EMULATOR         "
  echo "==============================="
  local i=1
  for EMU in "${EMULATORS[@]}"; do echo "  $i) $EMU"; ((i++)); done
  read -p "Enter number to clone (1-${#EMULATORS[@]}): " CHOICE
  if ! validate_choice "$CHOICE" "${#EMULATORS[@]}"; then echo "❌ Invalid selection."; return; fi
  local SOURCE="${EMULATORS[$((CHOICE-1))]}"
  read -p "Enter new clone name: " NEW_NAME
  [ -z "$NEW_NAME" ] && echo "❌ No name entered." && return
  local SRC_AVD="$AVD_PATH/$SOURCE.avd"
  local SRC_INI="$AVD_PATH/$SOURCE.ini"
  local NEW_AVD="$AVD_PATH/$NEW_NAME.avd"
  local NEW_INI="$AVD_PATH/$NEW_NAME.ini"
  [ -d "$NEW_AVD" ] && echo "❌ Clone already exists." && return
  echo "📁 Cloning '$SOURCE' → '$NEW_NAME' ..."
  cp -r "$SRC_AVD" "$NEW_AVD"
  cp "$SRC_INI" "$NEW_INI"
  sed -i "s|$SOURCE|$NEW_NAME|g" "$NEW_INI" "$NEW_AVD/config.ini"
  echo "✅ Clone created: $NEW_NAME"
  silent_launch_clone "$NEW_NAME"
}

# ---- Delete Clone ----
delete_clone() {
  list_avds
  echo "==============================="
  echo "         DELETE CLONE          "
  echo "==============================="
  local deletable=()
  for EMU in "${EMULATORS[@]}"; do is_clone_name "$EMU" && deletable+=("$EMU"); done
  [ ${#deletable[@]} -eq 0 ] && echo "❌ No clones available." && return
  local i=1
  for EMU in "${deletable[@]}"; do echo "  $i) $EMU"; ((i++)); done
  read -p "Enter number of clone to delete: " CHOICE
  if ! validate_choice "$CHOICE" "${#deletable[@]}"; then echo "❌ Invalid selection."; return; fi
  local TARGET="${deletable[$((CHOICE-1))]}"
  pkill -f "qemu-system-x86_64.*@$TARGET" >/dev/null 2>&1
  rm -rf "$AVD_PATH/$TARGET.avd" "$AVD_PATH/$TARGET.ini"
  echo "✅ Clone deleted: $TARGET"
}

# ---- Check GPU Renderer ----
check_gpu_renderer() {
  echo "==============================="
  echo "   GPU / RENDERER INFORMATION  "
  echo "==============================="
  echo "💻 Host OpenGL:"
  glxinfo | grep "OpenGL renderer"
  echo ""
  echo "📱 Emulator GLES:"
  adb shell dumpsys SurfaceFlinger | grep GLES
  echo "==============================="
}

# ---- Launch Menu ----
launch_menu() {
  list_avds
  echo "==============================="
  echo "   ANDROID EMULATOR LAUNCHER   "
  echo "==============================="
  local i=1
  for EMU in "${EMULATORS[@]}"; do echo "  $i) $EMU"; ((i++)); done
  read -p "Enter number to launch (1-${#EMULATORS[@]}): " CHOICE
  if ! validate_choice "$CHOICE" "${#EMULATORS[@]}"; then echo "❌ Invalid selection."; return; fi
  local NAME="${EMULATORS[$((CHOICE-1))]}"
  silent_launch "$NAME"
}

# ---- Main Menu ----
while true; do
  echo ""
  echo "==============================="
  echo "   ANDROID EMULATOR TOOL $VERSION"
  echo "==============================="
  echo "1) Launch Emulator"
  echo "2) Clone Emulator (create & launch)"
  echo "3) Delete Clone(s)"
  echo "4) Clear Emulator (Factory Reset + Auto Reboot)"
  echo "5) Check GPU Renderer"
  echo "6) Exit"
  echo ""
  read -p "Choose an option: " OPT

  case "$OPT" in
    1) check_backend; launch_menu ;;
    2) check_backend; clone_avd ;;
    3) delete_clone ;;
    4) clear_and_reboot ;;
    5) check_gpu_renderer ;;
    6) cleanup ;;
    *) echo "❌ Invalid option." ;;
  esac
done
