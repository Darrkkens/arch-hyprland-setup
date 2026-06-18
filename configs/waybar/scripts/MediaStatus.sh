#!/usr/bin/env bash

playerctl --player=playerctld status --follow 2>/dev/null |
	while IFS= read -r status; do
		case "$status" in
			Playing)
				printf '󰏤\n'
				;;
			Paused|Stopped)
				printf '󰐊\n'
				;;
		esac
	done
