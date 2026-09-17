#!/usr/bin/env bash
# Screenshot + anotação (grim + slurp + satty)
#   region  -> seleciona area, abre editor (seta/circulo/blur/texto)
#   full    -> tela inteira no editor
#   copy    -> seleciona area e copia direto (sem editor)
# Editor satty: A seta, R retangulo, E elipse, B blur, P pixelate,
#               T texto, D brush, N numero | Ctrl+C copia | Ctrl+S salva | Esc sai
set -euo pipefail

MODE="${1:-region}"
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

notify() { command -v notify-send >/dev/null 2>&1 && notify-send -a "Screenshot" "$@"; }

need_satty() {
	if ! command -v satty >/dev/null 2>&1; then
		notify "satty nao instalado" "sudo pacman -S satty"
		# fallback: copia sem editar
		grim -g "$(slurp)" - | wl-copy
		notify "Screenshot copiado" "(sem editor - instale satty)"
		exit 0
	fi
}

edit() {
	# stdin(-) -> satty -> salva em FILE + copia
	satty --filename - \
		--output-filename "$FILE" \
		--early-exit \
		--copy-command wl-copy \
		--initial-tool arrow \
		--actions-on-enter save-to-clipboard
	[[ -f "$FILE" ]] && notify "Salvo" "$FILE"
}

case "$MODE" in
	region)
		need_satty
		grim -g "$(slurp)" - | edit
		;;
	full)
		need_satty
		grim - | edit
		;;
	copy)
		grim -g "$(slurp)" - | wl-copy
		notify "Copiado" "Area na area de transferencia"
		;;
	*)
		printf "Uso: %s [region|full|copy]\n" "$0" >&2
		exit 2
		;;
esac
