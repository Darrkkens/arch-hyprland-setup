#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$ROOT_DIR/configs"
PACKAGE_DIR="$ROOT_DIR/packages"
SYSTEM_DIR="$ROOT_DIR/system"

# shellcheck source=common.sh
source "$ROOT_DIR/scripts/common.sh"

sync_config_dir() {
  local name="$1"
  local source="$HOME/.config/$name"
  local target="$CONFIG_DIR/$name"

  # Com install.sh --link a pasta já é o próprio repositório.
  if [[ -L "$source" ]]; then
    return
  fi

  if [[ -d "$source" ]]; then
    mkdir -p "$target"
    rsync -a --delete --exclude '*.bak' "$source/" "$target/"
    echo "config atualizado: $name"
  fi
}

mkdir -p "$CONFIG_DIR" "$PACKAGE_DIR" "$SYSTEM_DIR"

for config in "${CONFIG_DIRS[@]}"; do
  sync_config_dir "$config"
done

for file in "${CONFIG_FILES[@]}"; do
  if [[ -f "$HOME/.config/$file" && ! -L "$HOME/.config/$file" ]]; then
    cp "$HOME/.config/$file" "$CONFIG_DIR/$file"
    echo "config atualizado: $file"
  fi
done

if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
  cp "$HOME/.zshrc" "$ROOT_DIR/zshrc"
  echo "config atualizado: zshrc"
fi

if [[ -d "$WALLPAPER_DIR" ]]; then
  mkdir -p "$ROOT_DIR/wallpapers"
  rsync -a --delete "$WALLPAPER_DIR/" "$ROOT_DIR/wallpapers/"
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

list_enabled_units() {
  systemctl "$@" list-unit-files --state=enabled --no-legend --no-pager \
    | awk '{print $1}' | grep -v '@\.' | sort -u
}

list_enabled_units > "$SYSTEM_DIR/services.txt"
list_enabled_units --user > "$SYSTEM_DIR/user-services.txt"
echo "serviços do systemd atualizados"
