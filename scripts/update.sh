#!/bin/bash


[ -d ~/.config/hypr ] && rsync -av --delete ~/.config/hypr/ .config/hypr/
[ -d ~/.config/waybar ] && rsync -av --delete ~/.config/waybar/ .config/waybar/
[ -d ~/.config/wlogout ] && rsync -av --delete ~/.config/wlogout/ .config/wlogout/
[ -d ~/.config/kitty ] && rsync -av --delete ~/.config/kitty/ .config/kitty/
[ -d ~/.config/swaync ] && rsync -av --delete ~/.config/swaync/ .config/swaync/
[ -d ~/.config/rofi ] && rsync -av --delete ~/.config/rofi/ .config/rofi/
[ -d ~/.config/wofi ] && rsync -av --delete ~/.config/wofi/ .config/wofi/

[ -f ~/.config/starship.toml ] && cp ~/.config/starship.toml .config/starship.toml
[ -f ~/.zshrc ] && cp ~/.zshrc zshrc

pacman -Qqe > packages/pacman.txt
command -v yay >/dev/null 2>&1 && yay -Qqm > packages/aur.txt
command -v flatpak >/dev/null 2>&1 && flatpak list --app --columns=application > packages/flatpak.txt

