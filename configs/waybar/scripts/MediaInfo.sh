#!/usr/bin/env bash

player="$("$HOME/.config/waybar/scripts/MediaPlayer.sh")"

if [[ -z "$player" ]]; then
	printf '{"text":"","tooltip":"","class":"stopped"}\n'
	exit 0
fi

metadata="$(
	timeout 1s playerctl --player="$player" metadata \
		--format $'{{status}}\x1f{{xesam:artist}}\x1f{{xesam:title}}\x1f{{xesam:url}}\x1f{{mpris:trackid}}' \
		2>/dev/null || true
)"
IFS=$'\x1f' read -r status artist title url track_id <<< "$metadata"

if [[ -z "$status" || "$status" == "Stopped" ]]; then
	printf '{"text":"","tooltip":"","class":"stopped"}\n'
	exit 0
fi

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
