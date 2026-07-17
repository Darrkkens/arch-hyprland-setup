#!/usr/bin/env bash

player="$("$HOME/.config/waybar/scripts/MediaPlayer.sh")"
status="$(timeout 1s playerctl --player="$player" status 2>/dev/null || true)"

case "$status" in
	Playing)
		printf '󰏤\n'
		;;
	Paused|Stopped)
		printf '󰐊\n'
		;;
esac
