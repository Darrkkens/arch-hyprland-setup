# =========================================================
# LOCALE
# =========================================================
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8


# =========================================================
# HISTÓRICO
# =========================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt inc_append_history


# =========================================================
# AUTOCOMPLETE
# =========================================================
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"


# =========================================================
# BINDS
# =========================================================
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey "^H" backward-kill-word
bindkey "^[[3;5~" kill-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word


# =========================================================
# PATHS
# =========================================================
export PATH="$HOME/.local/bin:$PATH"

# Go
export GOPATH="$HOME/go"
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"


# =========================================================
# NVM
# =========================================================
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/share/nvm/init-nvm.sh" ] && source "/usr/share/nvm/init-nvm.sh"


# =========================================================
# FZF
# =========================================================
source <(fzf --zsh)


# =========================================================
# ZOXIDE
# =========================================================
eval "$(zoxide init zsh)"


# =========================================================
# STARSHIP
# =========================================================
eval "$(starship init zsh)"


# =========================================================
# GITHUB CLI
# =========================================================
eval "$(gh completion -s zsh)"


# =========================================================
# PLUGINS ZSH
# =========================================================
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# =========================================================
# ALIASES GERAIS
# =========================================================
alias c='clear'
alias ll='ls -lah'
alias la='ls -A'la
alias grep='grep --color=auto'

alias cd='z'

alias discord='discord --enable-features=UseOzonePlatform --ozone-platform=wayland'


# =========================================================
# ALIASES DO PROJETO OMNI
# =========================================================
alias omni-run='OMNI_USE_PROJECT_SECRETS=1 go run main.go'


# =========================================================
# ALIASES GIT
# =========================================================
alias gs="git status"
alias gl="git log --oneline --graph --decorate"
alias gaa="git add ."
alias gcm="git commit -m"
alias gpl="git pull origin develop"
alias gps="git push"
alias gbn="git branch"

# =========================================================
# FUNÇÕES GIT
# =========================================================

# Criar branch padrão OMNI
gb() {
  local branch="$1"

  if [ -z "$branch" ]; then
    echo "❌ Informe o nome da branch"
    return 1
  fi

  if [[ ! "$branch" =~ ^OMNI-[0-9]+$ ]]; then
    echo "❌ Nome inválido. Use padrão OMNI-XXXX"
    return 1
  fi

  echo "🔄 Atualizando develop..."
  git fetch origin
  git switch develop || git switch -c develop origin/develop
  git pull origin develop

  echo "🌿 Criando branch $branch..."
  git switch -c "$branch"
}

# Push automático da branch atual
gpush() {
  local branch
  branch="$(git branch --show-current)"

  if [ -z "$branch" ]; then
    echo "❌ Não foi possível identificar a branch atual"
    return 1
  fi

  git push -u origin "$branch"
}

# Criar PR para develop
gpr() {
  local branch
  branch="$(git branch --show-current)"

  if [ -z "$branch" ]; then
    echo "❌ Não foi possível identificar a branch atual"
    return 1
  fi

  gh pr create --base develop --head "$branch" --fill
}

# Merge PR atual
gmerge() {
  gh pr merge --squash --delete-branch
}

# Limpar workspace
gclean() {
  git reset --hard
  git clean -fd
}

# Trocar branch rápido
gco() {
  if [ -z "$1" ]; then
    echo "❌ Informe o nome da branch"
    return 1
  fi

  git switch "$1"
}


# =========================================================
# INICIALIZAÇÃO VISUAL
# =========================================================
fastfetch
