# Azure CLI completion
if command -v az >/dev/null 2>&1; then
  if [[ -f "/usr/local/share/zsh/site-functions/_az" ]]; then
    fpath=( "/usr/local/share/zsh/site-functions" $fpath )
  elif [[ -f "/opt/homebrew/share/zsh/site-functions/_az" ]]; then
    fpath=( "/opt/homebrew/share/zsh/site-functions" $fpath )
  fi
  autoload -Uz compinit && compinit
fi

# 기본 alias
alias azg="az group list"
alias azvm="az vm list"
alias azaks="az aks list"
