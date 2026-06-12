# Arch + Hyprland Setup

Configuração pessoal de ambiente Linux baseada em Arch Linux + Hyprland, com foco em performance, produtividade e organização.

## Pacotes

Os pacotes ficam definidos em:

* `packages/pacman.txt` -> pacotes oficiais
* `packages/aur.txt` -> pacotes AUR
* `packages/flatpak.txt` -> aplicativos Flatpak

Os arquivos `packages.txt` e `aur-packages.txt` tambem sao mantidos por compatibilidade com scripts antigos.

Para atualizar as listas com os pacotes instalados no sistema atual:

```bash
./scripts/update.sh
```

Esse script tambem sincroniza as configuracoes atuais de `~/.config` para `configs/`.

---

## Configurações incluídas

* Hyprland
* Waybar
* Kitty
* Zsh + plugins
* Temas e ajustes visuais
* Bindings personalizados

---

## Estrutura

```
configs/
├── hypr/
├── waybar/
├── kitty/
├── wlogout/
└── zsh/

scripts/
packages/
packages.txt
aur-packages.txt
```

---

## Scripts úteis

* Setup de teclado
* Configuração de monitor
* Conexão Wi-Fi
* Ajustes iniciais do sistema

---

## Observações

* Recomendado usar Arch Linux limpo
* Pode ser necessário instalar manualmente:

  * yay (AUR helper)
  * git
* Wayland obrigatório

---

## Arch Linux Hyprland Setup

![Preview do setup](images/setup.jpeg)
