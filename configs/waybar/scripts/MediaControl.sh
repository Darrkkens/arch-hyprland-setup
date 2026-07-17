#!/usr/bin/env bash

player="$("$HOME/.config/waybar/scripts/MediaPlayer.sh")"

[[ -z "$player" || $# -eq 0 ]] && exit 0

timeout 2s playerctl --player="$player" "$@"
