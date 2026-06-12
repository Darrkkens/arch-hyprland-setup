#!/usr/bin/env bash

set -euo pipefail

MODE_FILE="$HOME/.config/hypr/theme_mode"
CURRENT_WALL="$HOME/.config/hypr/current_wallpaper"

requested_mode="${1:-toggle}"

current_scheme="$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo "'prefer-dark'")"

case "$requested_mode" in
  dark|light)
    mode="$requested_mode"
    ;;
  toggle)
    if [[ "$current_scheme" == *prefer-dark* ]]; then
      mode="light"
    else
      mode="dark"
    fi
    ;;
  *)
    echo "Usage: $0 [toggle|dark|light]" >&2
    exit 2
    ;;
esac

mkdir -p "$(dirname "$MODE_FILE")"
printf '%s\n' "$mode" > "$MODE_FILE"

case "$mode" in
  dark)
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"
    label="Dark"
    ;;
  light)
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
    gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"
    label="Light"
    ;;
esac

if [[ -e "$CURRENT_WALL" ]]; then
  "$HOME/.config/hypr/scripts/apply-wallpaper.sh" "$CURRENT_WALL" fade 0.4
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Theme" "$label mode enabled"
fi
