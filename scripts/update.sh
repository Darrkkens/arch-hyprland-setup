#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$ROOT_DIR/configs"
PACKAGE_DIR="$ROOT_DIR/packages"
WALLPAPER_SOURCE="$HOME/Pictures/Wallpapers"

sync_config_dir() {
  local name="$1"
  local source="$HOME/.config/$name"
  local target="$CONFIG_DIR/$name"

  if [[ -d "$source" ]]; then
    mkdir -p "$target"
    rsync -a --delete --exclude '*.bak' "$source/" "$target/"
    echo "config atualizado: $name"
  fi
}

mkdir -p "$CONFIG_DIR" "$PACKAGE_DIR"

for config in hypr noctalia kitty alacritty cava fish satty uwsm; do
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

if [[ -d "$WALLPAPER_SOURCE" ]]; then
  mkdir -p "$ROOT_DIR/wallpapers"
  rsync -a --delete "$WALLPAPER_SOURCE/" "$ROOT_DIR/wallpapers/"
  echo "wallpapers atualizados"
fi

pacman -Qqen | sort -u > "$PACKAGE_DIR/pacman.txt"
echo "pacotes oficiais atualizados"

pacman -Qqem | sort -u > "$PACKAGE_DIR/aur.txt"
echo "pacotes AUR atualizados"

if command -v flatpak >/dev/null 2>&1; then
  flatpak list --app --columns=application | sort -u > "$PACKAGE_DIR/flatpak.txt"
  echo "flatpaks atualizados"
fi
