#!/usr/bin/env bash
#* ---- 💫 Waybar Timer ---- *//
# Pick a duration via rofi, fire a libnotify notification + sound when elapsed.
# Deps: rofi, systemd (user), libnotify, canberra/pipewire, sound-theme-freedesktop

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_FILE="$STATE_DIR/waybar-timers"
UNIT_PREFIX="waybar-timer"
SOUND_ID="alarm-clock-elapsed"
ICON="󰔛"

now() { date +%s; }

# --- play the finish sound, best effort across backends ---
play_sound() {
	if command -v canberra-gtk-play >/dev/null 2>&1; then
		canberra-gtk-play -i "$SOUND_ID" >/dev/null 2>&1 && return
	fi
	local f="/usr/share/sounds/freedesktop/stereo/${SOUND_ID}.oga"
	[ -f "$f" ] || f="/usr/share/sounds/freedesktop/stereo/complete.oga"
	if [ -f "$f" ]; then
		command -v pw-play >/dev/null 2>&1 && { pw-play "$f" >/dev/null 2>&1 & return; }
		command -v paplay >/dev/null 2>&1 && { paplay "$f" >/dev/null 2>&1 & return; }
	fi
}

# --- turn "90", "25m", "1:30" (h:m), "1:30:00" (h:m:s), "45s" into seconds ---
parse_seconds() {
	local in="${1// /}"
	[ -z "$in" ] && return 1
	if [[ "$in" == *:* ]]; then
		local IFS=:; read -ra p <<<"$in"
		case ${#p[@]} in
			2) echo $(( 10#${p[0]}*3600 + 10#${p[1]}*60 ));;   # H:M
			3) echo $(( 10#${p[0]}*3600 + 10#${p[1]}*60 + 10#${p[2]} ));;
			*) return 1;;
		esac
		return 0
	fi
	case "$in" in
		*s) echo $(( 10#${in%s} ));;
		*h) echo $(( 10#${in%h}*3600 ));;
		*m) echo $(( 10#${in%m}*60 ));;
		*[!0-9]*) return 1;;
		*) echo $(( 10#$in*60 ));;   # bare number = minutes
	esac
}

fmt_hms() {
	local s=$1
	printf '%02d:%02d' $(( s/60 )) $(( s%60 ))
	(( s>=3600 )) && printf '' # keep short; mm:ss is enough for the bar
}

# --- schedule a timer ---
schedule() {
	local secs="$1" label="$2" stamp end
	stamp=$(date +%s%N)
	end=$(( $(now) + secs ))
	systemd-run --user --quiet \
		--unit="${UNIT_PREFIX}-${stamp}" \
		--on-active="${secs}s" \
		--timer-property=AccuracySec=1s \
		"$HOME/.config/waybar/scripts/Timer.sh" fire "$stamp" "$label" >/dev/null 2>&1 || {
			notify-send -u critical "Timer" "Failed to schedule timer"; return 1; }
	printf '%s|%s|%s\n' "$stamp" "$end" "$label" >>"$STATE_FILE"
	notify-send -a "Timer" -i "alarm-symbolic" "Timer set" "$label"
}

# --- fired by systemd when a timer elapses ---
fire() {
	local stamp="$1" label="$2"
	if [ -f "$STATE_FILE" ]; then
		grep -v "^${stamp}|" "$STATE_FILE" >"$STATE_FILE.tmp" 2>/dev/null || true
		mv "$STATE_FILE.tmp" "$STATE_FILE"
	fi
	notify-send -u critical -a "Timer" -i "alarm-symbolic" "⏰ Time's up" "$label"
	play_sound
	# clean up the transient units so they don't linger
	systemctl --user reset-failed "${UNIT_PREFIX}-${stamp}.timer" "${UNIT_PREFIX}-${stamp}.service" >/dev/null 2>&1
}

# --- drop stale lines (units no longer active) and echo remaining active ---
prune() {
	[ -f "$STATE_FILE" ] || return
	local t n line
	n=$(now)
	: >"$STATE_FILE.tmp"
	while IFS='|' read -r stamp end label; do
		[ -z "$stamp" ] && continue
		if [ "$end" -gt "$n" ] && systemctl --user is-active --quiet "${UNIT_PREFIX}-${stamp}.timer"; then
			printf '%s|%s|%s\n' "$stamp" "$end" "$label" >>"$STATE_FILE.tmp"
		fi
	done <"$STATE_FILE"
	mv "$STATE_FILE.tmp" "$STATE_FILE"
}

# --- waybar module output: nearest remaining timer, or idle icon ---
status() {
	prune
	local n best="" bestlabel="" rem
	n=$(now)
	if [ -f "$STATE_FILE" ]; then
		while IFS='|' read -r stamp end label; do
			[ -z "$stamp" ] && continue
			if [ -z "$best" ] || [ "$end" -lt "$best" ]; then best="$end"; bestlabel="$label"; fi
		done <"$STATE_FILE"
	fi
	if [ -n "$best" ]; then
		rem=$(( best - n )); (( rem<0 )) && rem=0
		printf '{"text":"%s %s","tooltip":"%s\\nLeft: new timer  Right: cancel all","class":"active"}\n' \
			"$ICON" "$(fmt_hms "$rem")" "$bestlabel"
	else
		printf '{"text":"%s","tooltip":"Timer\\nLeft: new timer  Right: cancel all","class":"idle"}\n' "$ICON"
	fi
}

# --- live countdown module: shows nearest timer while active, empty when idle ---
display() {
	prune
	local n best="" bestlabel="" rem
	n=$(now)
	if [ -f "$STATE_FILE" ]; then
		while IFS='|' read -r stamp end label; do
			[ -z "$stamp" ] && continue
			if [ -z "$best" ] || [ "$end" -lt "$best" ]; then best="$end"; bestlabel="$label"; fi
		done <"$STATE_FILE"
	fi
	if [ -n "$best" ]; then
		rem=$(( best - n )); (( rem<0 )) && rem=0
		printf '{"text":"%s %s","tooltip":"%s\\nLeft: new timer  Right: cancel all","class":"active"}\n' \
			"$ICON" "$(fmt_hms "$rem")" "$bestlabel"
	else
		printf '{"text":"","class":"idle"}\n'
	fi
}

# --- rofi picker ---
menu() {
	local presets="1 min\n3 min\n5 min\n10 min\n15 min\n20 min\n25 min\n30 min\n45 min\n60 min\n Custom…\n Cancel all"
	local choice
	choice=$(echo -e "$presets" | rofi -dmenu -i -p "Timer" -theme "$HOME/.config/rofi/timer-dark.rasi") || exit 0
	[ -z "$choice" ] && exit 0
	case "$choice" in
		*"Cancel all") cancel_all; exit 0;;
		*"Custom…")
			local custom secs
			custom=$(rofi -dmenu -p "Duration (min | h:m | 90s)" -theme "$HOME/.config/rofi/timer-dark.rasi") || exit 0
			secs=$(parse_seconds "$custom") || { notify-send -u critical "Timer" "Invalid duration: $custom"; exit 1; }
			(( secs<1 )) && { notify-send -u critical "Timer" "Duration must be > 0"; exit 1; }
			schedule "$secs" "$custom";;
		*)
			local mins="${choice%% *}"
			schedule $(( mins*60 )) "$choice";;
	esac
}

cancel_all() {
	local units
	units=$(systemctl --user list-units --all --plain --no-legend "${UNIT_PREFIX}-*.timer" 2>/dev/null | awk '{print $1}')
	[ -n "$units" ] && systemctl --user stop $units >/dev/null 2>&1
	: >"$STATE_FILE"
	notify-send -a "Timer" "Timers cleared"
}

case "$1" in
	fire)    fire "$2" "$3";;
	status)  status;;
	display) display;;
	cancel) cancel_all;;
	menu|"") menu;;
	*) echo "usage: Timer.sh [menu|status|cancel|fire]";;
esac
