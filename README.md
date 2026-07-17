# Arch + Hyprland Setup

Configuração pessoal de ambiente Linux baseada em Arch Linux + Hyprland, com foco em produtividade, aparência consistente e sincronização simples dos dotfiles.

![Preview do setup](images/setup.jpeg)

## O que está incluído

* Hyprland com atalhos, temas, wallpaper atual e scripts auxiliares.
* Waybar com módulos personalizados, grupos, estilos e scripts para mídia, clima, VPN, timer, teclado, rede e GitHub.
* Kitty com tema de cores e configuração principal.
* Rofi com temas para seleção de wallpaper, preview em tela cheia, clipboard e timer.
* SwayNC com configuração e estilo de notificações.
* Wlogout com layout, estilo e ícones.
* Starship e `.zshrc`.
* Coleção de wallpapers.
* Listas de pacotes Pacman, AUR e Flatpak.

## Estrutura

```text
configs/
├── hypr/
│   └── scripts/
├── kitty/
├── rofi/
├── swaync/
├── waybar/
│   ├── configs/
│   ├── scripts/
│   └── style/
├── wlogout/
└── starship.toml

packages/
├── aur.txt
├── flatpak.txt
└── pacman.txt

scripts/
└── update.sh

wallpapers/
images/
zshrc
packages.txt
aur-packages.txt
```

## Pacotes

As listas principais ficam em:

* `packages/pacman.txt` - pacotes oficiais instalados via Pacman.
* `packages/aur.txt` - pacotes instalados via AUR.
* `packages/flatpak.txt` - aplicativos instalados via Flatpak.

Os arquivos `packages.txt` e `aur-packages.txt` também são mantidos por compatibilidade com scripts antigos.

Estado atual das listas:

* 136 pacotes em `packages/pacman.txt`.
* 30 pacotes em `packages/aur.txt`.
* 1 Flatpak em `packages/flatpak.txt`: `com.spotify.Client`.

## Atualizar o repositório

Para sincronizar os dotfiles atuais da máquina para este repositório:

```bash
./scripts/update.sh
```

O script atualiza:

* `configs/hypr`
* `configs/waybar`
* `configs/wlogout`
* `configs/kitty`
* `configs/swaync`
* `configs/rofi`
* `configs/wofi`, se existir
* `configs/starship.toml`
* `zshrc`
* listas de pacotes em `packages/`
* arquivos legados `packages.txt` e `aur-packages.txt`

O script usa `rsync --delete` para manter os diretórios espelhados com `~/.config`, então arquivos removidos da configuração local também podem ser removidos daqui ao atualizar.

## Restaurar configurações

Para aplicar manualmente as configurações em uma instalação nova:

```bash
mkdir -p ~/.config
cp -r configs/hypr ~/.config/
cp -r configs/waybar ~/.config/
cp -r configs/kitty ~/.config/
cp -r configs/rofi ~/.config/
cp -r configs/swaync ~/.config/
cp -r configs/wlogout ~/.config/
cp configs/starship.toml ~/.config/starship.toml
cp zshrc ~/.zshrc
```

Depois, reinicie a sessão ou recarregue os componentes necessários.

## Instalar pacotes

Pacotes oficiais:

```bash
sudo pacman -S --needed - < packages/pacman.txt
```

Pacotes AUR, usando `yay`:

```bash
yay -S --needed - < packages/aur.txt
```

Flatpaks:

```bash
xargs -r flatpak install -y flathub < packages/flatpak.txt
```

## Scripts úteis

Hyprland:

* `Brightness.sh` - controle de brilho.
* `DarkLight.sh` - alternância de tema claro/escuro.
* `Hyprlock.sh` e `LockScreen.sh` - bloqueio de tela.
* `Kool_Quick_Settings.sh` - painel rápido.
* `SwitchKeyboardLayout.sh` - troca de layout do teclado.
* `Wlogout.sh` - menu de energia/sessão.
* `apply-wallpaper.sh`, `wall.sh` e `wallpicker.sh` - aplicação e seleção de wallpapers.
* `clipmenu.sh` - menu de clipboard.
* `screenshot.sh` - captura de tela.
* `volume.sh` - controle de volume.
* `waybarcava.sh` - integração visual com áudio.

Waybar:

* `Clipboard.sh`
* `FocusMedia.sh`
* `GitHubQA.sh`
* `MediaControl.sh`
* `MediaCover.sh`
* `MediaInfo.sh`
* `MediaPlayer.sh`
* `MediaProgress.sh`
* `MediaStatus.sh`
* `NetworkMenu.sh`
* `OpenMedia.sh`
* `SwitchKeyboardLayout.sh`
* `Timer.sh`
* `VpnStatus.sh`
* `Weather.sh`

## Mudanças recentes

* Adicionado suporte ao SwayNC em `configs/swaync/`.
* Adicionados temas Rofi para clipboard e timer.
* Adicionados scripts de clipboard e screenshot para Hyprland.
* Adicionados scripts novos da Waybar para GitHub QA, controle/player de mídia e timer.
* Atualizados módulos, grupos, estilos e cores da Waybar.
* Atualizadas cores do Hyprland, Kitty e Rofi.
* Atualizadas listas de pacotes Pacman e AUR.
* Adicionado novo wallpaper em `wallpapers/1387268.jpg`.

## Requisitos

* Arch Linux.
* Hyprland e ambiente Wayland.
* `git`.
* `yay` para instalar pacotes AUR.
* `flatpak`, se quiser restaurar apps Flatpak.
* `rsync` para usar `scripts/update.sh`.

## Observações

Esta configuração é pessoal e pode depender de nomes de monitores, caminhos locais, temas instalados e preferências específicas do ambiente. Revise os arquivos em `configs/hypr/` e `configs/waybar/` antes de aplicar em outra máquina.
