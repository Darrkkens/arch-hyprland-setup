#!/usr/bin/env bash

url="$(playerctl --player=playerctld metadata xesam:url 2>/dev/null || true)"

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
