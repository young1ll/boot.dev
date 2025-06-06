# gcloud completion
if command -v gcloud >/dev/null 2>&1; then
  if [[ -f "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc" ]]; then
    source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
  elif [[ -f "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc" ]]; then
    source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
  fi
fi

# 기본 alias
alias gccl="gcloud components list"
alias gcda="gcloud auth login"
alias gcproj="gcloud config set project"
