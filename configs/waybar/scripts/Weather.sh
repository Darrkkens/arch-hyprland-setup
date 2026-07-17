#!/usr/bin/env bash

set -euo pipefail

LOCATION="${WEATHER_LOCATION:-Joacaba, Santa Catarina, BR}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
LOCATION_ID="$(printf "%s" "$LOCATION" | sha256sum | cut -d' ' -f1)"
CACHE_FILE="$CACHE_DIR/weather-${LOCATION_ID}.json"
CACHE_TTL="${WEATHER_CACHE_TTL:-600}"
encoded_location="$(jq -rn --arg location "$LOCATION" '$location | @uri')"

if [[ "${1:-}" == "open" ]]; then
	xdg-open "https://wttr.in/${encoded_location}" >/dev/null 2>&1 &
	exit 0
fi

weather_icon() {
	local condition="${1,,}"

	case "$condition" in
		*thunder*|*storm*) printf "" ;;
		*snow*|*sleet*|*ice*) printf "" ;;
		*rain*|*drizzle*|*shower*) printf "" ;;
		*fog*|*mist*|*haze*) printf "" ;;
		*cloud*|*overcast*) printf "" ;;
		*sun*|*clear*) printf "󰖙" ;;
		*) printf "" ;;
	esac
}

weather_class() {
	local condition="${1,,}"

	case "$condition" in
		*thunder*|*storm*) printf "severe" ;;
		*snow*|*sleet*|*ice*) printf "snowyIcyDay" ;;
		*rain*|*drizzle*|*shower*) printf "rainyDay" ;;
		*fog*|*mist*|*haze*) printf "cloudyFoggyDay" ;;
		*cloud*|*overcast*) printf "cloudyFoggyDay" ;;
		*sun*|*clear*) printf "sunnyDay" ;;
		*) printf "default" ;;
	esac
}

emit_json() {
	local condition="$1"
	local temp="$2"
	local feels_like="$3"
	local humidity="$4"
	local wind="$5"
	local icon class clean_temp clean_feels_like tooltip

	icon="$(weather_icon "$condition")"
	class="$(weather_class "$condition")"
	clean_temp="${temp#+}"
	clean_feels_like="${feels_like#+}"
	tooltip="${LOCATION}\n${condition}\nSensacao: ${clean_feels_like}\nUmidade: ${humidity}\nVento: ${wind}"

	jq -cn \
		--arg text "$icon $clean_temp" \
		--arg alt "$condition" \
		--arg tooltip "$tooltip" \
		--arg class "$class" \
		'{text: $text, alt: $alt, tooltip: $tooltip, class: $class}'
}

cache_is_fresh() {
	[[ -f "$CACHE_FILE" ]] || return 1
	(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") < CACHE_TTL ))
}

if cache_is_fresh; then
	cat "$CACHE_FILE"
	exit 0
fi

response="$(curl -fsSL --max-time 8 "https://wttr.in/${encoded_location}?format=%C|%t|%f|%h|%w" 2>/dev/null || true)"

if [[ -z "$response" || "$response" != *"|"* ]]; then
	if [[ -f "$CACHE_FILE" ]]; then
		cat "$CACHE_FILE"
	else
		jq -cn '{text: " --°C", alt: "offline", tooltip: "Clima indisponivel", class: "default"}'
	fi
	exit 0
fi

IFS='|' read -r condition temp feels_like humidity wind <<< "$response"

mkdir -p "$CACHE_DIR"
emit_json "$condition" "$temp" "$feels_like" "$humidity" "$wind" | tee "$CACHE_FILE"
