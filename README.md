# Arch + Hyprland Setup

Configuração pessoal de ambiente Linux baseada em Arch Linux + Hyprland, com foco em performance, produtividade e organização.

## Pacotes

Instala automaticamente os pacotes definidos em:

* packages.txt → pacotes oficiais
* aur-packages.txt → AUR (opcional)

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
packages.txt
aur-packages.txt
install.sh
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

![Preview do setup](images/setup.jpeg)

