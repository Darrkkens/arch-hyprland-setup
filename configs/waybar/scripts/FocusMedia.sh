#!/usr/bin/env bash

player="playerctld"
url="$(playerctl --player="$player" metadata xesam:url 2>/dev/null || true)"
title="$(playerctl --player="$player" metadata xesam:title 2>/dev/null || true)"

[[ -z "$url" && -z "$title" ]] && exit 0

clients="$(hyprctl clients -j 2>/dev/null)" || exit 1

case "$url" in
	*open.spotify.com/*|spotify:*)
		address="$(
			jq -r '
				[.[] | select(
					((.class // "") | ascii_downcase | contains("spotify")) or
					((.initialClass // "") | ascii_downcase | contains("spotify"))
				)] | first | .address // empty
			' <<< "$clients"
		)"
		;;
	*)
		address="$(
			jq -r --arg title "$title" '
				[
					.[] | select(
						($title != "") and
						((.title // "") | ascii_downcase | contains($title | ascii_downcase))
					)
				] | first | .address // empty
			' <<< "$clients"
		)"

		if [[ -z "$address" ]]; then
			address="$(
				jq -r '
					[
						.[] | select(
							((.class // "") | ascii_downcase) as $class |
							($class | contains("firefox")) or
							($class | contains("chrom")) or
							($class | contains("chrome")) or
							($class | contains("zen"))
						)
					] | first | .address // empty
				' <<< "$clients"
			)"
		fi
		;;
esac

[[ -n "$address" ]] && hyprctl dispatch focuswindow "address:$address"
