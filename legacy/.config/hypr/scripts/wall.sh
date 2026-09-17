#!/bin/bash

WALL="$HOME/Pictures/wallpapers/anime_skull.png"

pgrep -x awww-daemon >/dev/null || awww-daemon &
sleep 0.4

awww img "$WALL" \
  --transition-type fade \
  --transition-duration 0.8 \
  --transition-fps 60 \
  --transition-step 90

source_color=$(
  matugen image "$WALL" --json hex | python -c '
import sys, json
data = json.load(sys.stdin)
print(data["colors"]["dark"]["source_color"])
'
)

[ -z "$source_color" ] && exit 1

matugen color hex "$source_color" -m dark