#!/bin/bash

WALLDIR="$HOME/Pictures/wallpapers"

selected=$(
  find "$WALLDIR" -maxdepth 1 -type f \( \
    -iname "*.png" -o \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.webp" \) | sort | while read -r img; do
      name="$(basename "$img")"
      printf "%s\0icon\x1fthumbnail://%s\n" "$name" "$img"
    done | rofi -dmenu -i -show-icons \
      -theme ~/.config/rofi/wallpaper-preview.rasi \
      -p "Wallpaper"
)

[ -z "$selected" ] && exit 0

fullpath="$WALLDIR/$selected"

mkdir -p ~/.config/hypr
ln -sf "$fullpath" ~/.config/hypr/current_wallpaper

"$HOME/.config/hypr/scripts/apply-wallpaper.sh" "$fullpath" wipe 1.2
