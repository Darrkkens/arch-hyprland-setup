#!/usr/bin/env bash
# Clipboard picker (cliphist + rofi)
#   Enter      -> copy selected entry
#   Shift+Del  -> delete selected entry, reopen menu
#   Shift+Ret  -> wipe entire clipboard history
theme="$HOME/.config/rofi/clipboard-dark.rasi"

while true; do
    sel=$(cliphist list | rofi -dmenu -theme "$theme" -p clipboard \
        -mesg "Enter: copy   Shift+Del: delete item   Shift+Enter: wipe all" \
        -kb-delete-entry "" \
        -kb-accept-custom "" \
        -kb-accept-alt "" \
        -kb-custom-1 "Shift+Delete" \
        -kb-custom-2 "Shift+Return")
    code=$?

    # empty selection or Escape -> quit
    [ -z "$sel" ] && exit 0

    case $code in
        0)  # Enter -> copy
            printf '%s' "$sel" | cliphist decode | wl-copy
            exit 0
            ;;
        10) # Shift+Del -> delete this entry, loop reopens menu
            printf '%s' "$sel" | cliphist delete
            ;;
        11) # Shift+Enter -> wipe all
            cliphist wipe
            exit 0
            ;;
        *)  exit 0 ;;
    esac
done
