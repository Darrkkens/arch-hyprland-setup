#!/usr/bin/env bash

player="$("$HOME/.config/waybar/scripts/MediaPlayer.sh")"
url="$(timeout 1s playerctl --player="$player" metadata xesam:url 2>/dev/null || true)"

[[ -z "$url" ]] && exit 0

case "$url" in
	https://open.spotify.com/track/*)
		track_id="${url#https://open.spotify.com/track/}"
		track_id="${track_id%%\?*}"
		xdg-open "spotify:track:$track_id"
		;;
	*)
		xdg-open "$url"
		;;
esac
