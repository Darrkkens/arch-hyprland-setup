#!/usr/bin/env bash

player="$("$HOME/.config/waybar/scripts/MediaPlayer.sh")"
[[ -z "$player" ]] && exit 0
metadata="$(
	timeout 1s playerctl --player="$player" metadata \
		--format $'{{xesam:url}}\x1f{{mpris:trackid}}\x1f{{mpris:length}}' \
		2>/dev/null || true
)"
IFS=$'\x1f' read -r url track_id length_us <<< "$metadata"

case "$url|$track_id" in
	*open.spotify.com/*|*spotify:*|*/com/spotify/*)
		;;
	*)
		exit 0
		;;
esac

position="$(timeout 1s playerctl --player="$player" position 2>/dev/null || true)"

[[ "$position" =~ ^[0-9]+([.][0-9]+)?$ && "$length_us" =~ ^[0-9]+$ ]] || exit 0

awk -v position="$position" -v length_us="$length_us" '
	function timestamp(seconds) {
		seconds = int(seconds)
		return sprintf("%d:%02d", int(seconds / 60), seconds % 60)
	}
	BEGIN {
		duration = length_us / 1000000
		width = 14
		point = (duration > 0) ? int((position / duration) * width + 0.5) : 0
		if (point < 0) point = 0
		if (point > width) point = width

		bar = ""
		for (i = 0; i <= width; i++) {
			bar = bar (i == point ? "●" : "─")
		}

		printf "%s  %s  %s\n", timestamp(position), bar, timestamp(duration)
	}
'
