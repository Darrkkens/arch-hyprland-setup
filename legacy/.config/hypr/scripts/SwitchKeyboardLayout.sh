#!/bin/bash

CURRENT=$(hyprctl devices -j | jq -r '.keyboards[0].active_keymap')

if [[ "$CURRENT" == *"English (US)"* ]]; then
  hyprctl keyword input:kb_layout br
  hyprctl keyword input:kb_variant abnt2
  notify-send "Teclado" "Layout: Português (ABNT2)"
else
  hyprctl keyword input:kb_layout us
  hyprctl keyword input:kb_variant ""
  notify-send "Teclado" "Layout: English (US)"
fi