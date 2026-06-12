#!/usr/bin/env bash

set -euo pipefail

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
EXIT_IP_CACHE="$CACHE_DIR/vpn-exit-ip"
EXIT_IP_TTL="${VPN_EXIT_IP_TTL:-300}"

json() {
	local text="$1"
	local alt="$2"
	local tooltip="$3"
	local class="$4"

	jq -cn \
		--arg text "$text" \
		--arg alt "$alt" \
		--arg tooltip "$tooltip" \
		--arg class "$class" \
		'{text: $text, alt: $alt, tooltip: $tooltip, class: $class}'
}

cache_is_fresh() {
	[[ -f "$EXIT_IP_CACHE" ]] || return 1
	(( $(date +%s) - $(stat -c %Y "$EXIT_IP_CACHE") < EXIT_IP_TTL ))
}

exit_ip() {
	mkdir -p "$CACHE_DIR"

	if cache_is_fresh; then
		cat "$EXIT_IP_CACHE"
		return
	fi

	curl -fsSL --max-time 4 https://ifconfig.me/ip 2>/dev/null | tee "$EXIT_IP_CACHE" || true
}

ipv4_for_interface() {
	local iface="$1"

	ip -4 -brief addr show "$iface" 2>/dev/null | awk '{print $3}' | cut -d/ -f1 | head -n1
}

vpn_interface() {
	ip -o link show up | awk -F': ' '
		$2 ~ /^(tailscale|tailscale0|warp|CloudflareWARP|wg|wg[0-9]+|tun|tun[0-9]+|tap|tap[0-9]+|zt|proton|nord)/ {
			print $2
			exit
		}
	'
}

nmcli_active_vpn() {
	command -v nmcli >/dev/null 2>&1 || return 1

	nmcli -t -f NAME,TYPE,DEVICE connection show --active 2>/dev/null |
		awk -F: '$2 == "vpn" { print $1 "|" $3; exit }'
}

nmcli_saved_vpns() {
	command -v nmcli >/dev/null 2>&1 || return 0

	nmcli -t -f NAME,TYPE connection show 2>/dev/null |
		awk -F: '$2 == "vpn" { names = names sep $1; sep = ", " } END { print names }'
}

networkmanager_status() {
	local active name device ip_addr saved

	active="$(nmcli_active_vpn)"
	[[ -n "$active" ]] || return 1

	name="${active%%|*}"
	device="${active#*|}"
	ip_addr="$(ipv4_for_interface "$device")"

	json "󰖂 NM" "connected" "NetworkManager VPN conectado\nConexao: ${name}\nInterface: ${device:-n/a}\nIP: ${ip_addr:-n/a}\nSaida: $(exit_ip)" "connected"
}

networkmanager_disconnected_tooltip() {
	local saved

	saved="$(nmcli_saved_vpns)"
	if [[ -n "$saved" ]]; then
		printf "VPN desconectada\\nNetworkManager: %s" "$saved"
	else
		printf "VPN desconectada\\nNenhuma VPN salva no NetworkManager"
	fi
}

tailscale_status() {
	command -v tailscale >/dev/null 2>&1 || return 1

	local status ip
	status="$(tailscale status --json 2>/dev/null || true)"
	[[ -n "$status" ]] || return 1

	ip="$(jq -r '.Self.TailscaleIPs[0] // empty' <<< "$status" 2>/dev/null || true)"
	[[ -n "$ip" ]] || return 1

	json "󰖂 TS" "connected" "Tailscale conectado\nIP: ${ip}\nSaida: $(exit_ip)" "connected"
}

warp_status() {
	command -v warp-cli >/dev/null 2>&1 || return 1

	local status
	status="$(warp-cli status 2>/dev/null || true)"

	if grep -qi "Connected" <<< "$status"; then
		json "󰖂 WARP" "connected" "Cloudflare WARP conectado\nSaida: $(exit_ip)" "connected"
		return 0
	fi

	return 1
}

interface_status() {
	local iface ip_addr
	iface="$(vpn_interface)"
	[[ -n "$iface" ]] || return 1

	ip_addr="$(ipv4_for_interface "$iface")"
	json "󰖂 VPN" "connected" "VPN conectada\nInterface: ${iface}\nIP: ${ip_addr:-n/a}\nSaida: $(exit_ip)" "connected"
}

networkmanager_status && exit 0
tailscale_status && exit 0
warp_status && exit 0
interface_status && exit 0

json "󰦝 VPN" "disconnected" "$(networkmanager_disconnected_tooltip)" "disconnected"
