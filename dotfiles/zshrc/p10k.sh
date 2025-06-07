#!/usr/bin/env bash
# plugins.sh: .zshrc에 Oh-My-Zsh 플러그인과 테마 설정을 직접 삽입

TARGET_ZSHRC="$1"
P10K_FILE="$HOME/.p10k.zsh"

if grep -q "# \[P10K.SH\] APPLIED" "$TARGET_ZSHRC"; then
  exit 0
fi

# 헤더 블록이 없는 경우에만 삽입
if ! grep -q "# \[P10K.SH\] STARTED" "$TARGET_ZSHRC"; then
  {
    echo
    echo "# [P10K.SH] STARTED ---------------------------------------------------------- #"
  } >> "$TARGET_ZSHRC"
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "⚙️ oh-my-zsh가 설치되어 있지 않습니다. 설치를 시작합니다..."
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" \
    && echo "✅ oh-my-zsh 설치 완료" \
    || { echo "❌ oh-my-zsh 설치에 실패했습니다."; exit 1; }
fi

# # ZSH 환경변수가 없으면 기본 경로 설정
# if grep -q "^export ZSH=" "$TARGET_ZSHRC"; then
#   # sed를 작은따옴표 패턴으로 감싸거나 \$HOME 형태로 이스케이프
#   sed -i.bak 's|^export ZSH=.*|export ZSH="$HOME/.oh-my-zsh"|' "$TARGET_ZSHRC"
# else
#   echo 'export ZSH="$HOME/.oh-my-zsh"' >> "$TARGET_ZSHRC"
# fi

# # oh-my-zsh 로드 라인
# if ! grep -q 'source[[:space:]]\$ZSH/oh-my-zsh\.sh' "$TARGET_ZSHRC"; then
#   {
#     echo 'source $ZSH/oh-my-zsh.sh'
#     echo
#   } >> "$TARGET_ZSHRC"
# fi

if [[ ! -f "$HOME/.p10k.zsh" ]]; then
  echo "⚠️  .p10k.zsh 파일이 없어 Powerlevel10k 설정을 시작합니다."
  echo "   완료 후 자동으로 설정을 이어갑니다."
  read -r -p "▶ 지금 'p10k configure'를 대화형 zsh로 실행할까요? (Y/n): " ans
  if [[ ! "$ans" =~ ^[Nn]$ ]]; then
    # -i: interactive, -c: command
    zsh -ic "p10k configure"
  fi

  # 다시 확인
  if [[ ! -f "$HOME/.p10k.zsh" ]]; then
    echo "❌ 설정이 완료되지 않았습니다. 수동으로 zsh에서 'p10k configure' 실행 후 재시도하세요."
    exit 1
  fi
fi

# POWERLEVEL10K 로드
if ! grep -q 'source[[:space:]]\$(brew --prefix)/share/powerlevel10k/powerlevel10k\.zsh-theme' "$TARGET_ZSHRC"; then
  {
    echo 'source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme'
    echo
  } >> "$TARGET_ZSHRC"
fi

# ZSH_THEME 설정 (없으면 추가, 있으면 덮어쓰기)
if grep -q '^ZSH_THEME=' "$TARGET_ZSHRC"; then
  sed -i.bak "s|^ZSH_THEME=.*|ZSH_THEME=\"powerlevel10k/powerlevel10k\"|" "$TARGET_ZSHRC"
  echo "# [P10K.SH] theme has applied above" >> "$TARGET_ZSHRC"
else
  echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$TARGET_ZSHRC"
fi

# prompt_context: 사용자 이름만 표시
if grep -q '^prompt_context()' "$TARGET_ZSHRC"; then
  sed -i.bak "s|^prompt_context().*|" "$TARGET_ZSHRC"
else
  cat > "$TARGET_ZSHRC" <<'EOF'
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"
  fi
}
EOF
fi

if [[ -f "$P10K_FILE" ]]; then
  # (a) POWERLEVEL9K_SHORTEN_STRATEGY 설정
  if grep -q '^POWERLEVEL9K_SHORTEN_STRATEGY=' "$P10K_FILE"; then
    sed -i.bak "s|^POWERLEVEL9K_SHORTEN_STRATEGY=.*|POWERLEVEL9K_SHORTEN_STRATEGY=\"truncate_to_last\"|" "$P10K_FILE"
    echo "# [.p10k.sh] directory shorten strategy applied" >> "$TARGET_ZSHRC"
  else
    {
      echo
      echo "# [P10K.SH] directory shorten strategy"
      echo "POWERLEVEL9K_SHORTEN_STRATEGY=\"truncate_to_last\""
    } >> "$P10K_FILE"
    echo "# [.p10k.sh] directory shorten strategy applied" >> "$TARGET_ZSHRC"
  fi

  # (b) POWERLEVEL9K_SHORTEN_DIR_LENGTH 설정
  if grep -q '^POWERLEVEL9K_SHORTEN_DIR_LENGTH=' "$P10K_FILE"; then
    sed -i.bak "s|^POWERLEVEL9K_SHORTEN_DIR_LENGTH=.*|POWERLEVEL9K_SHORTEN_DIR_LENGTH=2|" "$P10K_FILE"
    echo "# [.p10k.sh] directory shorten length applied" >> "$TARGET_ZSHRC"
  else
    {
      echo ""
      echo "# [P10K.SH] directory shorten length"
      echo "POWERLEVEL9K_SHORTEN_DIR_LENGTH=2"
    } >> "$P10K_FILE"
    echo "# [.p10k.sh] directory shorten length applied" >> "$TARGET_ZSHRC"
  fi

  # 성공 마커가 없으면 삽입
  if ! grep -q "# \[P10K.SH\] APPLIED" "$TARGET_ZSHRC"; then
    {
      echo
      echo "# [P10K.SH] APPLIED ---------------------------------------------------------- #"
    } >> "$TARGET_ZSHRC"
  fi

  # (d) sed 백업 파일 삭제
  rm -f "$P10K_FILE.bak"
else
  echo "⚠️ $P10K_FILE 파일을 찾을 수 없습니다. Powerlevel10k 설정을 적용하려면 먼저 'p10k configure' 등을 실행하여 .p10k.zsh를 생성하세요."
fi

rm -f "$TARGET_ZSHRC.bak"
exit 0
