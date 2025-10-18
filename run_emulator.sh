#!/bin/bash

AVD_PATH="$HOME/.android/avd"

# ---- Environment Fix for Debian + AMD GPUs ----
export QT_QPA_PLATFORM=xcb
export ANDROID_EMULATOR_VULKAN=disabled

# ---- List AVDs ----
list_avds() {
  mapfile -t EMULATORS < <(emulator -list-avds | sort -V)
}

# ---- Detect Clone (non-Pixel) ----
is_clone_name() {
  [[ "$1" != Pixel* ]]
}

# ---- Check if Emulator is Running ----
is_running() {
  pgrep -f "qemu-system-x86_64.*@$1" >/dev/null
}

# ---- Silent Launch ----
silent_launch() {
  local NAME="$1"
  if is_running "$NAME"; then
    echo "⚠️ $NAME is already running."
    exit 0
  fi
  echo "🚀 Launching: $NAME in background..."
  nohup emulator @"$NAME" -accel on -gpu host -no-snapshot >/dev/null 2>&1 &
  disown
  echo "✔ Emulator started. Returning to terminal..."
  exit 0
}

# ---- Silent Clone Launch ----
silent_launch_clone() {
  local NAME="$1"
  echo "🚀 Launching clone: $NAME in background..."
  nohup emulator @"$NAME" -read-only -accel on -gpu host -no-snapshot >/dev/null 2>&1 &
  disown
  echo "✔ Clone started. Returning to terminal..."
  exit 0
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
    i=$((i+1))
  done

  echo ""
  echo "Select emulator to factory reset:"
  read -r CHOICE
  local INDEX=$((CHOICE-1))
  local NAME="${EMULATORS[$INDEX]}"

  if [ -z "$NAME" ]; then
    echo "❌ Invalid selection."
    return
  fi

  echo "🛑 Stopping running instance of $NAME (if any)..."
  pkill -f "qemu-system-x86_64.*@$NAME" >/dev/null 2>&1

  echo "🧼 Wiping user data from $NAME..."
  emulator @"$NAME" -wipe-data -no-snapshot -no-boot-anim -accel on -gpu host >/dev/null 2>&1 &

  sleep 5

  echo "♻️ Rebooting fresh $NAME..."
  nohup emulator @"$NAME" -accel on -gpu host -no-snapshot >/dev/null 2>&1 &
  disown

  echo "✔ Fresh emulator launched. Returning to terminal..."
  exit 0
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
    i=$((i+1))
  done

  echo ""
  echo "Enter number of emulator to clone:"
  read -r CHOICE
  local INDEX=$((CHOICE-1))
  local SOURCE="${EMULATORS[$INDEX]}"

  if [ -z "$SOURCE" ]; then
    echo "❌ Invalid choice."
    return
  fi

  echo "Enter NEW clone name (no spaces):"
  read -r NEW_NAME
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
  sed -i "s|$SOURCE|$NEW_NAME|g" "$NEW_INI" 2>/dev/null
  sed -i "s|$SOURCE|$NEW_NAME|g" "$NEW_AVD/config.ini" 2>/dev/null
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
    echo "❌ No clones to delete."
    return
  fi

  local i=1
  for EMU in "${deletable[@]}"; do
    echo "  $i) $EMU"
    i=$((i+1))
  done

  echo ""
  echo "Enter number of clone to delete:"
  read -r CHOICE
  local INDEX=$((CHOICE-1))
  local TARGET="${deletable[$INDEX]}"

  if [ -z "$TARGET" ]; then
    echo "❌ Invalid choice."
    return
  fi

  echo "🛑 Stopping running clone: $TARGET"
  pkill -f "qemu-system-x86_64.*@$TARGET" >/dev/null 2>&1

  echo "🗑 Deleting clone: $TARGET ..."
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
    i=$((i+1))
  done
  echo ""
  echo "Enter number to launch:"
  read -r CHOICE
  local INDEX=$((CHOICE-1))
  local NAME="${EMULATORS[$INDEX]}"
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
  echo "Choose an option:"
  read -r OPT

  case "$OPT" in
    1) launch_menu ;;
    2) clone_avd ;;
    3) delete_clone ;;
    4) clear_and_reboot ;;
    5) echo "👋 Exiting..."; exit 0 ;;
    *) echo "❌ Invalid option." ;;
  esac
done
