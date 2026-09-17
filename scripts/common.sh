# Lista compartilhada entre update.sh e install.sh.
# Adicione aqui novas configs para que sejam salvas e restauradas.

# Pastas dentro de ~/.config
CONFIG_DIRS=(
  hypr noctalia kitty alacritty cava fish satty uwsm
  btop gtk-3.0 gtk-4.0 qt5ct qt6ct xsettingsd
)

# Arquivos soltos dentro de ~/.config
CONFIG_FILES=(
  starship.toml kdeglobals dolphinrc mimeapps.list
  user-dirs.dirs user-dirs.locale
)

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
