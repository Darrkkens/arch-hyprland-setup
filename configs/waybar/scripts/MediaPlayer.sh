#!/usr/bin/env bash

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
cache_file="$cache_dir/media-player"
lock_file="$cache_dir/media-player.lock"
cache_ttl=2

mkdir -p "$cache_dir"

read_cache() {
	local now modified

	[[ -s "$cache_file" ]] || return 1

	now="$(date +%s)"
	modified="$(stat -c %Y "$cache_file" 2>/dev/null || printf '0')"
	((now - modified < cache_ttl)) || return 1

	cat "$cache_file"
}

if read_cache; then
	exit 0
fi

exec 9>"$lock_file"
flock -x 9

if read_cache; then
	exit 0
fi

is_ignored() {
	case "$1" in
		*web.whatsapp.com/*|*web.whatsapp.com)
			return 0
			;;
	esac

	return 1
}

active_metadata="$(
	timeout 1s playerctl --player=playerctld metadata \
		--format $'{{xesam:url}}\x1f{{xesam:title}}' 2>/dev/null || true
)"
IFS=$'\x1f' read -r active_url active_title <<< "$active_metadata"

playing=""
paused=""

while IFS= read -r player; do
	[[ -z "$player" || "$player" == "playerctld" ]] && continue

	metadata="$(
		timeout 1s playerctl --player="$player" metadata \
			--format $'{{status}}\x1f{{xesam:url}}\x1f{{xesam:title}}' 2>/dev/null || true
	)"
	IFS=$'\x1f' read -r status url title <<< "$metadata"

	is_ignored "$url" && continue

	if ! is_ignored "$active_url" &&
		[[ -n "$active_url" && "$url" == "$active_url" ]] &&
		[[ -z "$active_title" || "$title" == "$active_title" ]]; then
		printf '%s\n' "$player" | tee "$cache_file"
		exit 0
	fi

	case "$status" in
		Playing)
			[[ -z "$playing" ]] && playing="$player"
			;;
		Paused)
			[[ -z "$paused" ]] && paused="$player"
			;;
	esac
done < <(timeout 1s playerctl --list-all 2>/dev/null)

if [[ -n "$playing" ]]; then
	printf '%s\n' "$playing" | tee "$cache_file"
elif [[ -n "$paused" ]]; then
	printf '%s\n' "$paused" | tee "$cache_file"
else
	rm -f "$cache_file"
fi
