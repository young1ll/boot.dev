#!/usr/bin/env bash

TARGET_ZSHRC="$1"

if grep -q "# \[EKSCTL.SH\] APPLIED" "$TARGET_ZSHRC"; then
  exit 0
fi

# 헤더 블록이 없는 경우에만 삽입
if ! grep -q "# \[EKSCTL.SH\] STARTED" "$TARGET_ZSHRC"; then
  {
    echo
    echo "# [EKSCTL.SH] STARTED -------------------------------------------------------- #"
  } >> "$TARGET_ZSHRC"
fi

# zsh completion 추가
if ! grep -q "eksctl completion zsh" "$TARGET_ZSHRC"; then
  echo 'eval "$(eksctl completion zsh)"' >> "$TARGET_ZSHRC"
fi

# 성공 마커가 없으면 삽입
if ! grep -q "# \[EKSCTL.SH\] APPLIED" "$TARGET_ZSHRC"; then
  {
    echo
    echo "# [EKSCTL.SH] APPLIED -------------------------------------------------------- #"
  } >> "$TARGET_ZSHRC"
fi

rm -f "$TARGET_ZSHRC.bak"
exit 0