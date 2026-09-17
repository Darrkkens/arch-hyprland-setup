#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$ROOT_DIR/configs"
PACKAGE_DIR="$ROOT_DIR/packages"
SYSTEM_DIR="$ROOT_DIR/system"
BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d-%H%M%S)"

# shellcheck source=common.sh
source "$ROOT_DIR/scripts/common.sh"

MODE="copy"
DRY_RUN=0
DO_PACKAGES=1
DO_CONFIGS=1
DO_SERVICES=1

usage() {
  cat <<EOF
Uso: ./scripts/install.sh [opções]

Instala pacotes, restaura as configurações e ativa os serviços do systemd.
Arquivos existentes são movidos para ~/.config-backup/<data>/ antes de serem substituídos.

Opções:
  --link            cria links simbólicos para o repositório em vez de copiar
  --dry-run         mostra o que seria feito, sem alterar nada
  --skip-packages   não instala pacotes
  --skip-configs    não restaura configurações nem wallpapers
  --skip-services   não ativa serviços do systemd
  -h, --help        mostra esta ajuda
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --link) MODE="link" ;;
    --dry-run) DRY_RUN=1 ;;
    --skip-packages) DO_PACKAGES=0 ;;
    --skip-configs) DO_CONFIGS=0 ;;
    --skip-services) DO_SERVICES=0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "opção desconhecida: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[aviso]\033[0m %s\n' "$*" >&2; }

run() {
  if (( DRY_RUN )); then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

# Lê uma lista ignorando linhas vazias e comentários.
read_list() {
  [[ -f "$1" ]] && grep -Ev '^\s*(#|$)' "$1" || true
}

if [[ $EUID -eq 0 ]]; then
  echo "Não rode como root. O script usa sudo quando precisa." >&2
  exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "pacman não encontrado. Este script é para Arch/CachyOS." >&2
  exit 1
fi

install_packages() {
  log "Pacotes oficiais"
  mapfile -t wanted < <(read_list "$PACKAGE_DIR/pacman.txt")
  mapfile -t available < <(comm -12 <(printf '%s\n' "${wanted[@]}" | sort -u) <(pacman -Slq | sort -u))
  mapfile -t missing < <(comm -23 <(printf '%s\n' "${wanted[@]}" | sort -u) <(printf '%s\n' "${available[@]}" | sort -u))

  if (( ${#missing[@]} )); then
    warn "fora dos repositórios, ignorados: ${missing[*]}"
  fi
  if (( ${#available[@]} )); then
    run sudo pacman -S --needed "${available[@]}"
  fi

  log "Pacotes AUR"
  mapfile -t aur < <(read_list "$PACKAGE_DIR/aur.txt")
  if (( ${#aur[@]} )); then
    local helper=""
    for candidate in paru yay; do
      if command -v "$candidate" >/dev/null 2>&1; then
        helper="$candidate"
        break
      fi
    done

    if [[ -z "$helper" ]]; then
      warn "nenhum AUR helper (paru/yay) encontrado. Pacotes AUR não instalados."
    else
      # Sem --noconfirm de propósito: revise os PKGBUILDs antes de instalar.
      run "$helper" -S --needed "${aur[@]}"
    fi
  fi

  mapfile -t flatpaks < <(read_list "$PACKAGE_DIR/flatpak.txt")
  if (( ${#flatpaks[@]} )); then
    log "Flatpaks"
    if command -v flatpak >/dev/null 2>&1; then
      run flatpak install -y flathub "${flatpaks[@]}"
    else
      warn "flatpak não instalado. Flatpaks ignorados."
    fi
  fi
}

# Move o destino para o backup, a não ser que já seja o link certo.
backup_target() {
  local source="$1" target="$2"

  if [[ -L "$target" && "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]; then
    return 1
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    local dest="$BACKUP_DIR/${target#"$HOME"/}"
    run mkdir -p "$(dirname "$dest")"
    run mv "$target" "$dest"
    echo "backup: $target -> $dest"
  fi
}

install_item() {
  local source="$1" target="$2"

  if [[ ! -e "$source" ]]; then
    warn "não existe no repositório: $source"
    return
  fi

  if [[ "$MODE" == "copy" && ! -L "$target" ]] && diff -rq --no-dereference "$source" "$target" >/dev/null 2>&1; then
    echo "sem mudanças: $target"
    return
  fi

  backup_target "$source" "$target" || { echo "já linkado: $target"; return; }
  run mkdir -p "$(dirname "$target")"

  if [[ "$MODE" == "link" ]]; then
    run ln -s "$source" "$target"
    echo "link: $target"
  else
    run cp -a "$source" "$target"
    echo "copiado: $target"
  fi
}

install_configs() {
  log "Configurações ($MODE)"
  for name in "${CONFIG_DIRS[@]}" "${CONFIG_FILES[@]}"; do
    install_item "$CONFIG_DIR/$name" "$HOME/.config/$name"
  done
  install_item "$ROOT_DIR/zshrc" "$HOME/.zshrc"

  log "Wallpapers"
  run mkdir -p "$WALLPAPER_DIR"
  run rsync -a "$ROOT_DIR/wallpapers/" "$WALLPAPER_DIR/"
}

enable_units() {
  local scope="$1" file="$2"
  local systemctl_cmd=(sudo systemctl)
  [[ "$scope" == "user" ]] && systemctl_cmd=(systemctl --user)

  while read -r unit; do
    if ! systemctl ${scope:+--$scope} cat "$unit" >/dev/null 2>&1; then
      warn "unidade não encontrada, ignorada: $unit"
      continue
    fi
    if systemctl ${scope:+--$scope} is-enabled --quiet "$unit" 2>/dev/null; then
      continue
    fi
    run "${systemctl_cmd[@]}" enable "$unit"
  done < <(read_list "$file")
}

install_services() {
  log "Serviços do sistema"
  enable_units "" "$SYSTEM_DIR/services.txt"
  log "Serviços do usuário"
  enable_units "user" "$SYSTEM_DIR/user-services.txt"
}

(( DO_PACKAGES )) && install_packages
(( DO_CONFIGS )) && install_configs
(( DO_SERVICES )) && install_services

log "Pronto."
if [[ -d "$BACKUP_DIR" ]]; then
  echo "Backup dos arquivos antigos em: $BACKUP_DIR"
fi
echo "Reinicie a sessão do Hyprland para aplicar tudo."
