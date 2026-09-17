#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$ROOT_DIR/configs"
PACKAGE_DIR="$ROOT_DIR/packages"

sync_config_dir() {
  local name="$1"
  local source="$HOME/.config/$name"
  local target="$CONFIG_DIR/$name"

  if [[ -d "$source" ]]; then
    mkdir -p "$target"
    rsync -a --delete "$source/" "$target/"
    echo "config atualizado: $name"
  fi
}

mkdir -p "$CONFIG_DIR" "$PACKAGE_DIR"

for config in hypr waybar wlogout kitty swaync rofi wofi; do
  sync_config_dir "$config"
done

if [[ -f "$HOME/.config/starship.toml" ]]; then
  cp "$HOME/.config/starship.toml" "$CONFIG_DIR/starship.toml"
  echo "config atualizado: starship.toml"
fi

if [[ -f "$HOME/.zshrc" ]]; then
  cp "$HOME/.zshrc" "$ROOT_DIR/zshrc"
  echo "config atualizado: zshrc"
fi

pacman -Qqe | sort -u > "$PACKAGE_DIR/pacman.txt"
cp "$PACKAGE_DIR/pacman.txt" "$ROOT_DIR/packages.txt"
echo "pacotes oficiais atualizados"

if command -v yay >/dev/null 2>&1; then
  yay -Qqm | sort -u > "$PACKAGE_DIR/aur.txt"
  cp "$PACKAGE_DIR/aur.txt" "$ROOT_DIR/aur-packages.txt"
  echo "pacotes AUR atualizados"
fi

if command -v flatpak >/dev/null 2>&1; then
  flatpak list --app --columns=application | sort -u > "$PACKAGE_DIR/flatpak.txt"
  echo "flatpaks atualizados"
fi
