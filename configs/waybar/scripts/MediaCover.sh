#!/usr/bin/env bash

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
cover_file="$cache_dir/media-cover"
url_file="$cache_dir/media-cover.url"

mkdir -p "$cache_dir"

cover_url="$(playerctl --player=playerctld metadata mpris:artUrl 2>/dev/null || true)"

if [[ -z "$cover_url" ]]; then
	rm -f "$cover_file" "$url_file"
	exit 0
fi

current_url="$(cat "$url_file" 2>/dev/null || true)"

if [[ "$cover_url" != "$current_url" || ! -s "$cover_file" ]]; then
	temp_file="${cover_file}.tmp"

	if curl --fail --silent --show-error --location "$cover_url" --output "$temp_file"; then
		mv "$temp_file" "$cover_file"
		printf '%s' "$cover_url" > "$url_file"
	else
		rm -f "$temp_file"
	fi
fi

[[ -s "$cover_file" ]] && printf '%s\nCapa do álbum\n' "$cover_file"
