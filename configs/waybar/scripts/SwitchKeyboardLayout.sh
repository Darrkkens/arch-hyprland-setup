#!/usr/bin/env bash

set -euo pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE_FILE="$CACHE_DIR/kb_layout"

get_current_keymap() {
	local devices

	devices="$(hyprctl devices -j 2>/dev/null || true)"
	if [[ -z "$devices" ]]; then
		return 0
	fi

	jq -r '([.keyboards[]? | select(.main == true) | .active_keymap][0] // .keyboards[0].active_keymap // "")' <<< "$devices" 2>/dev/null || true
}

get_label() {
	local current

	current="$(get_current_keymap)"

	case "$current" in
		*"English (US)"*|*"US"*|*"us"*)
			printf "US\n"
			;;
		*"Portuguese"*|*"Brazilian"*|*"br"*|*"BR"*|*"ABNT2"*)
			printf "BR\n"
			;;
		*)
			printf "%s\n" "${current:-??}"
			;;
	esac
}

write_cache() {
	local label="${1:-}"

	if [[ -z "$label" ]]; then
		label="$(get_label)"
	fi

	if mkdir -p "$CACHE_DIR" 2>/dev/null; then
		{ printf "%s\n" "$label" > "$CACHE_FILE"; } 2>/dev/null || true
	fi
}

switch_layout() {
	local current

	current="$(get_current_keymap)"

	if [[ "$current" == *"English (US)"* || "$current" == *"US"* || "$current" == *"us"* ]]; then
		hyprctl keyword input:kb_layout br
		hyprctl keyword input:kb_variant abnt2
		notify-send "Teclado" "Layout: Portugues (ABNT2)"
	else
		hyprctl keyword input:kb_layout us
		hyprctl keyword input:kb_variant ""
		notify-send "Teclado" "Layout: English (US)"
	fi

	write_cache
}

case "${1:-status}" in
	toggle)
		switch_layout
		;;
	status)
		label="$(get_label)"
		write_cache "$label"
		printf "%s\n" "$label"
		;;
	*)
		printf "Usage: %s [status|toggle]\n" "$0" >&2
		exit 2
		;;
esac
