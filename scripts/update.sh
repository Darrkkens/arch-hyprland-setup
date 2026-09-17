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

for config in hypr noctalia kitty alacritty cava fish satty uwsm btop gtk-3.0 gtk-4.0 qt5ct qt6ct xsettingsd; do
  sync_config_dir "$config"
done

for file in starship.toml kdeglobals dolphinrc mimeapps.list user-dirs.dirs user-dirs.locale; do
  if [[ -f "$HOME/.config/$file" ]]; then
    cp "$HOME/.config/$file" "$CONFIG_DIR/$file"
    echo "config atualizado: $file"
  fi
done

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
