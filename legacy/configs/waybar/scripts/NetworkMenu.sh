#!/usr/bin/env bash

set -euo pipefail

terminal="${TERMINAL:-kitty}"

notify() {
	notify-send "NetworkManager" "$1"
}

open_nmtui() {
	if command -v "$terminal" >/dev/null 2>&1; then
		"$terminal" -e nmtui >/dev/null 2>&1 &
	elif command -v alacritty >/dev/null 2>&1; then
		alacritty -e nmtui >/dev/null 2>&1 &
	else
		notify "Nenhum terminal encontrado para abrir nmtui."
	fi
}

open_editor() {
	if command -v nm-connection-editor >/dev/null 2>&1; then
		nm-connection-editor >/dev/null 2>&1 &
	else
		open_nmtui
	fi
}

vpn_rows() {
	nmcli -t -f NAME,TYPE connection show 2>/dev/null |
		awk -F: '$2 == "vpn" { print "Conectar VPN: " $1 }'

	nmcli -t -f NAME,TYPE connection show --active 2>/dev/null |
		awk -F: '$2 == "vpn" { print "Desconectar VPN: " $1 }'
}

choice="$(
	{
		printf "Wi-Fi / rede (nmtui)\n"
		printf "Editar conexoes\n"
		printf "Recarregar Wi-Fi\n"
		vpn_rows
	} | rofi -dmenu -i -p "Conexoes"
)"

[[ -n "${choice:-}" ]] || exit 0

case "$choice" in
	"Wi-Fi / rede (nmtui)")
		open_nmtui
		;;
	"Editar conexoes")
		open_editor
		;;
	"Recarregar Wi-Fi")
		nmcli device wifi rescan >/dev/null 2>&1 && notify "Busca por redes Wi-Fi atualizada."
		;;
	"Conectar VPN: "*)
		name="${choice#Conectar VPN: }"
		if nmcli connection up id "$name" >/dev/null 2>&1; then
			notify "VPN conectada: $name"
		else
			notify "Falha ao conectar VPN: $name"
		fi
		;;
	"Desconectar VPN: "*)
		name="${choice#Desconectar VPN: }"
		if nmcli connection down id "$name" >/dev/null 2>&1; then
			notify "VPN desconectada: $name"
		else
			notify "Falha ao desconectar VPN: $name"
		fi
		;;
esac
