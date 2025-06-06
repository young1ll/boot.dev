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
    echo ""
    echo "# [P10K.SH] STARTED ---------------------------------------------------------- #"
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
    echo "" >> "$P10K_FILE"
    echo "# [P10K.SH] directory shorten strategy" >> "$P10K_FILE"
    echo "POWERLEVEL9K_SHORTEN_STRATEGY=\"truncate_to_last\"" >> "$P10K_FILE"
  fi

  # (b) POWERLEVEL9K_SHORTEN_DIR_LENGTH 설정
  if grep -q '^POWERLEVEL9K_SHORTEN_DIR_LENGTH=' "$P10K_FILE"; then
    sed -i.bak "s|^POWERLEVEL9K_SHORTEN_DIR_LENGTH=.*|POWERLEVEL9K_SHORTEN_DIR_LENGTH=2|" "$P10K_FILE"
    echo "# [.p10k.sh] directory shorten length applied" >> "$TARGET_ZSHRC"
  else
    echo "POWERLEVEL9K_SHORTEN_DIR_LENGTH=2" >> "$P10K_FILE"
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
