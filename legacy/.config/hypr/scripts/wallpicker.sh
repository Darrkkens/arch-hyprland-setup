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

pgrep -x awww-daemon >/dev/null || awww-daemon &
sleep 0.4

awww img "$fullpath" \
  --transition-type wipe \
  --transition-duration 1.2 \
  --transition-fps 60 \
  --transition-step 90

source_color=$(
python3 - <<'PY' "$fullpath"
from PIL import Image
import sys

img = Image.open(sys.argv[1]).convert("RGB")
img = img.resize((150, 150))
colors = img.getcolors(150 * 150)

if not colors:
    print("#888888")
    raise SystemExit

dominant = max(colors, key=lambda x: x[0])[1]
print("#{0:02x}{1:02x}{2:02x}".format(*dominant))
PY
)

[ -z "$source_color" ] && exit 1

matugen color hex "$source_color" -m dark --type kitty
