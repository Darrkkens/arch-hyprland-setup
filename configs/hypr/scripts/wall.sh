#!/bin/bash

CURRENT_WALL="$HOME/.config/hypr/current_wallpaper"
DEFAULT_WALL="$HOME/Pictures/wallpapers/this-wallpaper-is-not-available.png"

if [ -e "$CURRENT_WALL" ]; then
  WALL="$CURRENT_WALL"
else
  WALL="$DEFAULT_WALL"
  mkdir -p "$HOME/.config/hypr"
  ln -sf "$WALL" "$CURRENT_WALL"
fi

"$HOME/.config/hypr/scripts/apply-wallpaper.sh" "$WALL" fade 0.8
