#!/usr/bin/env bash

set -euo pipefail

notify_missing() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Quick settings" "$1 is not installed"
  fi
}

run_if_available() {
  local command_name="$1"
  shift

  if command -v "$command_name" >/dev/null 2>&1; then
    "$command_name" "$@" &
  else
    notify_missing "$command_name"
  fi
}

options=$(
  printf '%s\n' \
    "  Audio" \
    "󰤨  Network" \
    "  Qt Theme" \
    "  Wallpaper" \
    "󰑓  Reload Waybar" \
    "󰌾  Lock Screen" \
    "⏻  Power Menu"
)

if command -v walker >/dev/null 2>&1; then
  choice="$(printf '%s' "$options" | walker --dmenu --placeholder "Settings" 2>/dev/null || true)"
elif command -v rofi >/dev/null 2>&1; then
  choice="$(printf '%s' "$options" | rofi -dmenu -i -p "Settings" 2>/dev/null || true)"
else
  notify_missing "walker"
  exit 0
fi

case "$choice" in
  "  Audio")
    run_if_available pavucontrol
    ;;
  "󰤨  Network")
    run_if_available nm-connection-editor
    ;;
  "  Qt Theme")
    run_if_available qt6ct
    ;;
  "  Wallpaper")
    "$HOME/.config/hypr/scripts/wallpicker.sh" &
    ;;
  "󰑓  Reload Waybar")
    pkill waybar || true
    waybar &
    ;;
  "󰌾  Lock Screen")
    "$HOME/.config/hypr/scripts/LockScreen.sh" &
    ;;
  "⏻  Power Menu")
    "$HOME/.config/hypr/scripts/Wlogout.sh" &
    ;;
esac
