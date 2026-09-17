#!/bin/bash

WALL="$1"
TRANSITION_TYPE="${2:-fade}"
TRANSITION_DURATION="${3:-0.8}"
MODE_FILE="$HOME/.config/hypr/theme_mode"

[ -n "$WALL" ] || exit 1

WALL="$(readlink -f "$WALL")"

[ -n "$WALL" ] && [ -e "$WALL" ] || exit 1

pgrep -x awww-daemon >/dev/null || awww-daemon &
sleep 0.4

awww img "$WALL" \
  --transition-type "$TRANSITION_TYPE" \
  --transition-duration "$TRANSITION_DURATION" \
  --transition-fps 60 \
  --transition-step 90

MODE="dark"
if [ -f "$MODE_FILE" ]; then
  MODE="$(cat "$MODE_FILE")"
fi

case "$MODE" in
  dark|light) ;;
  *) MODE="dark" ;;
esac

matugen image "$WALL" -m "$MODE" --source-color-index 0 --continue-on-error
