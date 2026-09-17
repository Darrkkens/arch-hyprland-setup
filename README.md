# Arch + Hyprland Setup

Configuração pessoal de ambiente Linux.

> [!IMPORTANT]
> 🚀 **O sistema foi migrado para Arch + Noctalia (CachyOS)!**
> Novas funcionalidades estão vindo aí!!!

## Stack atual

* **Distro:** CachyOS (base Arch Linux).
* **Compositor:** Hyprland, com configuração em Lua (`hyprland.lua` + módulos em `config/`), iniciado via UWSM.
* **Shell gráfico:** [Noctalia](https://github.com/noctalia-dev/noctalia-shell): barra, launcher, central de controle, notificações, clipboard, seletor de wallpaper, menu de sessão e screenshots.
* **Tema:** gerado pelo Noctalia a partir do wallpaper (Material 3, `m3-tonal-spot`, modo escuro) e aplicado em Kitty, Alacritty, btop, GTK 3/4, Qt, KDE, Cava e Starship.
* **Terminal:** Kitty (Alacritty como alternativa).
* **Shell:** Zsh + Starship (Fish também configurado).
* **Screenshots:** Satty para anotar capturas do Noctalia.

## Estrutura

```text
configs/
├── alacritty/        # config + tema noctalia
├── cava/             # tema noctalia
├── fish/
├── hypr/
│   ├── hyprland.lua
│   ├── xdph.conf
│   └── config/       # animations, binds, colors, monitors, windowrules...
├── kitty/            # config + tema noctalia
├── noctalia/
│   └── config.toml   # barra, widgets, sessão, tema
├── satty/
├── uwsm/
│   └── env           # variáveis de ambiente da sessão
└── starship.toml

packages/
├── aur.txt           # pacotes AUR
└── pacman.txt        # pacotes oficiais (explícitos)

scripts/
└── update.sh         # sincroniza ~/.config -> repositório

wallpapers/           # cópia de ~/Pictures/Wallpapers
zshrc
legacy/               # setup antigo (Hyprland + Waybar)
```

## Atalhos principais

`SUPER` é a tecla modificadora principal.

| Atalho | Ação |
| --- | --- |
| `SUPER + Space` | Launcher do Noctalia |
| `SUPER + .` | Seletor de emojis |
| `SUPER + X` | Central de controle |
| `SUPER + A` | Notificações |
| `SUPER + Z` | Configurações do Noctalia |
| `SUPER + V` | Histórico do clipboard |
| `SUPER + SHIFT + W` | Seletor de wallpaper |
| `SUPER + Tab` | Alternador de janelas |
| `SUPER + L` | Bloquear tela |
| `SUPER + ALT + C` | Menu de sessão |
| `SUPER + T` / `E` / `B` | Kitty / Dolphin / Firefox |
| `SUPER + C` | Fechar janela |
| `SUPER + F` / `D` | Tela cheia / maximizar |
| `SUPER + ALT + Space` | Alternar janela flutuante |
| `SUPER + P` | Color picker (hyprpicker) |
| `Print` / `SUPER + Print` | Screenshot de região / tela inteira |
| `CTRL + SHIFT + Esc` | btop |

A lista completa está em `configs/hypr/config/binds.lua`.

## Atualizar o repositório

```bash
./scripts/update.sh
```

O script sincroniza (com `rsync --delete`) `hypr`, `noctalia`, `kitty`, `alacritty`, `cava`, `fish`, `satty` e `uwsm`, além de `starship.toml`, `~/.zshrc`, os wallpapers de `~/Pictures/Wallpapers` e as listas de pacotes.

## Restaurar configurações

```bash
mkdir -p ~/.config ~/Pictures/Wallpapers
cp -r configs/{hypr,noctalia,kitty,alacritty,cava,fish,satty,uwsm} ~/.config/
cp configs/starship.toml ~/.config/starship.toml
cp zshrc ~/.zshrc
cp -r wallpapers/. ~/Pictures/Wallpapers/
```

Instalar pacotes:

```bash
sudo pacman -S --needed - < packages/pacman.txt
yay -S --needed - < packages/aur.txt
```

## Observações

* Os monitores estão definidos em `configs/hypr/config/variables.lua` (`eDP-1` e `HDMI-A-1`). Ajuste para o seu hardware.
* Os arquivos de tema `noctalia` (kitty, alacritty, cava) são gerados automaticamente pelo Noctalia a partir do wallpaper.

## Setup legado

A configuração anterior (Arch Linux + Hyprland, Waybar, Rofi, SwayNC, Wlogout) está em [`legacy/`](legacy/), com documentação em [`legacy/README.md`](legacy/README.md).

![Preview do setup legado](legacy/images/setup.jpeg)
