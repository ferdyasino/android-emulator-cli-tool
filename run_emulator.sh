#!/bin/bash
# ==============================================
# Android Emulator CLI Tool – Debian + AMD GPU
# Author: Ferdy
# ==============================================

AVD_PATH="$HOME/.android/avd"

# ---- Environment Fix for Debian + AMD GPUs ----
export QT_QPA_PLATFORM=xcb
export ANDROID_EMULATOR_VULKAN=disabled

# ---- Force external GPU (AMD Radeon RX 550 on /dev/dri/card1) ----
export DRI_PRIME=1
export DRI_DEVICE=/dev/dri/card1
echo "🎮 Using external GPU device: $DRI_DEVICE"

# ---- Helper: Wait for emulator boot ----
wait_for_boot() {
  echo "⌛ Waiting for Android OS to boot..."
  local retries=0
  local max_retries=60
  local connected=false

  # Try to find emulator device first
  while [ $retries -lt 20 ]; do
    if adb devices | grep -q "emulator-"; then
      connected=true
      break
    fi
    ((retries++))
    sleep 1
  done

  if ! $connected; then
    echo "⚠️ No emulator connected to ADB; continuing anyway."
    return 0
  fi

  # Wait for Android system boot flag
  retries=0
  while [ $retries -lt $max_retries ]; do
    local boot_status
    boot_status=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
    if [ "$boot_status" = "1" ]; then
      echo "✅ Android fully booted."
      return 0
    fi
    ((retries++))
    sleep 2
  done

  echo "⚠️ Boot check timed out, but emulator is likely ready."
  return 0
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
is_clone_name() {
  [[ "$1" != Pixel* ]]
}

# ---- Check if Emulator is Running ----
is_running() {
  pgrep -f "qemu-system-x86_64.*@$1" >/dev/null
}

# ---- Safe numeric choice validation ----
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
  nohup emulator @"$NAME" -accel on -gpu host -no-snapshot >/dev/null 2>&1 &
  disown

  sleep 8
  adb_connect_emulator
  echo "🔍 Checking ADB devices..."
  adb devices | grep "emulator" || echo "⚠️ No emulator detected yet."

  wait_for_boot
  echo "✔ Emulator $NAME ready!"
}

# ---- Silent Clone Launch ----
silent_launch_clone() {
  local NAME="$1"
  echo "🚀 Launching clone: $NAME (External GPU: RX 550)..."
  nohup emulator @"$NAME" -read-only -accel on -gpu host -no-snapshot >/dev/null 2>&1 &
  disown

  sleep 8
  adb devices >/dev/null 2>&1
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
  for EMU in "${EMULATORS[@]}"; do
    echo "  $i) $EMU"
    ((i++))
  done
  echo ""
  read -p "Select emulator to factory reset (1-${#EMULATORS[@]}): " CHOICE
  if ! validate_choice "$CHOICE" "${#EMULATORS[@]}"; then
    echo "❌ Invalid selection."
    return
  fi
  local NAME="${EMULATORS[$((CHOICE-1))]}"

  echo "🛑 Stopping $NAME..."
  pkill -f "qemu-system-x86_64.*@$NAME" >/dev/null 2>&1

  echo "🧼 Wiping user data..."
  emulator @"$NAME" -wipe-data -no-snapshot -no-boot-anim -accel on -gpu host >/dev/null 2>&1 &
  sleep 10
  echo "♻️ Rebooting..."
  nohup emulator @"$NAME" -accel on -gpu host -no-snapshot >/dev/null 2>&1 &
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
  for EMU in "${EMULATORS[@]}"; do
    echo "  $i) $EMU"
    ((i++))
  done

  echo ""
  read -p "Enter number to clone (1-${#EMULATORS[@]}): " CHOICE
  if ! validate_choice "$CHOICE" "${#EMULATORS[@]}"; then
    echo "❌ Invalid selection."
    return
  fi

  local SOURCE="${EMULATORS[$((CHOICE-1))]}"
  read -p "Enter new clone name: " NEW_NAME
  [ -z "$NEW_NAME" ] && echo "❌ No name entered." && return

  local SRC_AVD="$AVD_PATH/$SOURCE.avd"
  local SRC_INI="$AVD_PATH/$SOURCE.ini"
  local NEW_AVD="$AVD_PATH/$NEW_NAME.avd"
  local NEW_INI="$AVD_PATH/$NEW_NAME.ini"

  if [ -d "$NEW_AVD" ] || [ -f "$NEW_INI" ]; then
    echo "❌ AVD '$NEW_NAME' already exists."
    return
  fi

  echo "📁 Cloning '$SOURCE' → '$NEW_NAME' ..."
  cp -r "$SRC_AVD" "$NEW_AVD"
  cp "$SRC_INI" "$NEW_INI"
  sed -i "s|$SOURCE|$NEW_NAME|g" "$NEW_INI" "$NEW_AVD/config.ini" 2>/dev/null
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
  for EMU in "${EMULATORS[@]}"; do
    if is_clone_name "$EMU"; then
      deletable+=("$EMU")
    fi
  done

  if [ ${#deletable[@]} -eq 0 ]; then
    echo "❌ No clones available."
    return
  fi

  local i=1
  for EMU in "${deletable[@]}"; do
    echo "  $i) $EMU"
    ((i++))
  done

  read -p "Enter number of clone to delete: " CHOICE
  if ! validate_choice "$CHOICE" "${#deletable[@]}"; then
    echo "❌ Invalid selection."
    return
  fi
  local TARGET="${deletable[$((CHOICE-1))]}"

  echo "🛑 Stopping $TARGET..."
  pkill -f "qemu-system-x86_64.*@$TARGET" >/dev/null 2>&1

  echo "🗑 Deleting $TARGET ..."
  rm -rf "$AVD_PATH/$TARGET.avd" "$AVD_PATH/$TARGET.ini"
  echo "✅ Clone deleted."
}

# ---- Launch Emulator ----
launch_menu() {
  list_avds
  echo "==============================="
  echo "   ANDROID EMULATOR LAUNCHER   "
  echo "==============================="
  local i=1
  for EMU in "${EMULATORS[@]}"; do
    echo "  $i) $EMU"
    ((i++))
  done
  echo ""
  read -p "Enter number to launch (1-${#EMULATORS[@]}): " CHOICE
  if ! validate_choice "$CHOICE" "${#EMULATORS[@]}"; then
    echo "❌ Invalid selection."
    return
  fi
  local NAME="${EMULATORS[$((CHOICE-1))]}"
  silent_launch "$NAME"
}

# ---- Main Menu ----
while true; do
  echo ""
  echo "==============================="
  echo "   ANDROID EMULATOR TOOL"
  echo "==============================="
  echo "1) Launch Emulator"
  echo "2) Clone Emulator (create & launch)"
  echo "3) Delete Clone(s)"
  echo "4) Clear Emulator (Factory Reset + Auto Reboot)"
  echo "5) Exit"
  echo ""
  read -p "Choose an option: " OPT

  case "$OPT" in
    1) launch_menu ;;
    2) clone_avd ;;
    3) delete_clone ;;
    4) clear_and_reboot ;;
    5) echo "👋 Exiting..."; exit 0 ;;
    *) echo "❌ Invalid option." ;;
  esac
done