export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8


# binds
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey "^H" backward-kill-word
bindkey "^[[3;5~" kill-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

# Plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

#Fzf
source <(fzf --zsh)

# Starship
eval "$(starship init zsh)"

alias discord='discord --enable-features=UseOzonePlatform --ozone-platform=wayland'

fastfetch

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/share/nvm/init-nvm.sh" ] && \. "/usr/share/nvm/init-nvm.sh"

export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
export PATH=/usr/local/go/bin:$PATH

eval "$(zoxide init zsh)"
eval "$(gh completion -s zsh)"

# -------------------------
# BASE GIT
# -------------------------
alias gs="git status"
alias gl="git log --oneline --graph --decorate"
alias gaa="git add ."
alias gcm="git commit -m"
alias gpl="git pull origin develop"
alias gps="git push"
alias gbn="git branch"

# -------------------------
# ATUALIZAR DEVELOP
# -------------------------
alias gdev='git fetch origin && git switch develop || git switch -c develop origin/develop && git pull origin develop'

# -------------------------
# CRIAR BRANCH PADRÃO OMNI
# -------------------------
gb() {
  branch=$1

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

# -------------------------
# COMMIT COM COPILOT
# -------------------------
gcm-ai() {
  echo "📦 Adicionando arquivos..."
  git add .

  echo "🤖 Gerando commit..."
  msg=$(gh copilot suggest "generate a conventional commit message based on staged changes")

  if [ -z "$msg" ]; then
    echo "❌ Copilot falhou"
    return 1
  fi

  echo "📝 $msg"

  read "confirm?Confirmar commit? (y/n): "

  if [[ "$confirm" != "y" ]]; then
    echo "Cancelado"
    return
  fi

  git commit -m "$msg"
}

# -------------------------
# PUSH AUTOMÁTICO
# -------------------------
gpush() {
  branch=$(git branch --show-current)
  git push -u origin "$branch"
}

# -------------------------
# CRIAR PR
# -------------------------
gpr() {
  branch=$(git branch --show-current)
  gh pr create --base develop --head "$branch" --fill
}

# -------------------------
# MERGE PR
# -------------------------
gmerge() {
  gh pr merge --squash --delete-branch
}

# -------------------------
# FLOW COMPLETO (1 COMANDO)
# -------------------------
gflow() {
  branch=$(git branch --show-current)

  echo "[INFO] Add..."
  git add .

  echo "[INFO] Gerando commit..."
  msg=$(
    copilot -p "Return only one conventional commit message. No explanation. No markdown. No commands. Only the commit title. Based on staged git changes." 2>/dev/null \
    | grep -E '^(feat|fix|chore|refactor|style|docs|test|perf|build|ci)(\(.+\))?: .+' \
    | tail -n 1
  )

  if [ -z "$msg" ]; then
    echo "[WARN] Copilot falhou, digite manual:"
    read "msg?Commit: "
  else
    echo "[COMMIT] $msg"
    read "confirm?Usar essa mensagem? (y/n): "
    if [[ "$confirm" != "y" ]]; then
      read "msg?Commit: "
    fi
  fi

  git commit -m "$msg"
  git push -u origin "$branch"
  gh pr create --base develop --head "$branch" --title "$msg" --body "$msg"

  echo "[OK] Finalizado"
}

# -------------------------
# LIMPAR WORKSPACE
# -------------------------
gclean() {
  git reset --hard
  git clean -fd
}

# -------------------------
# TROCAR BRANCH RÁPIDO
# -------------------------
gco() {
  git switch "$1"
}
