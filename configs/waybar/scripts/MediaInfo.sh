#!/usr/bin/env bash

player="playerctld"

status="$(playerctl --player="$player" status 2>/dev/null || true)"

if [[ -z "$status" || "$status" == "Stopped" ]]; then
	printf '{"text":"","tooltip":"","class":"stopped"}\n'
	exit 0
fi

artist="$(playerctl --player="$player" metadata xesam:artist 2>/dev/null || true)"
title="$(playerctl --player="$player" metadata xesam:title 2>/dev/null || true)"
url="$(playerctl --player="$player" metadata xesam:url 2>/dev/null || true)"
track_id="$(playerctl --player="$player" metadata mpris:trackid 2>/dev/null || true)"

case "$url|$track_id" in
	*youtube.com/*|*youtu.be/*)
		icon=""
		source="YouTube"
		;;
	*open.spotify.com/*|*spotify:*|*/com/spotify/*)
		icon=""
		source="Spotify"
		;;
	http://*|https://*)
		icon=""
		source="Navegador"
		;;
	*)
		icon=""
		source="Mídia"
		;;
esac

if [[ -n "$artist" && -n "$title" ]]; then
	text="$icon $artist — $title"
	printf -v tooltip '%s\n%s\n%s' "$source" "$artist" "$title"
else
	text="$icon ${title:-$artist}"
	printf -v tooltip '%s\n%s' "$source" "${title:-$artist}"
fi

jq --compact-output --null-input \
	--arg text "$text" \
	--arg tooltip "$tooltip" \
	--arg class "${status,,}" \
	'{text: $text, tooltip: $tooltip, class: $class}'
