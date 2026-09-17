#!/usr/bin/env bash

set -euo pipefail

missing_command() {
	notify-send "Clipboard" "Instale o cliphist para usar o historico do clipboard."
}

require_cliphist() {
	if ! command -v cliphist >/dev/null 2>&1; then
		missing_command
		exit 0
	fi
}

case "${1:-open}" in
	open)
		require_cliphist
		cliphist list | rofi -dmenu -i -p "Clipboard" | cliphist decode | wl-copy
		;;
	clear)
		require_cliphist
		cliphist wipe
		notify-send "Clipboard" "Historico limpo."
		;;
	status)
		if command -v cliphist >/dev/null 2>&1; then
			printf "󰅌\n"
		else
			printf "󰅌\n"
		fi
		;;
	*)
		printf "Usage: %s [open|clear|status]\n" "$0" >&2
		exit 2
		;;
esac
