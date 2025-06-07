#!/usr/bin/env bash

TARGET_ZSHRC="$1"

if grep -q "# \[ZOXIDE.SH\] APPLIED" "$TARGET_ZSHRC"; then
    exit 0
fi

# 헤더 블록이 없는 경우에만 삽입
if ! grep -q "# \[ZOXIDE.SH\] STARTED" "$TARGET_ZSHRC"; then
    {
        echo
        echo "# [ZOXIDE.SH] STARTED -------------------------------------------------------- #"
    } >> "$TARGET_ZSHRC"
fi

# zoxide 초기화 코드 추가
if command -v zoxide &>/dev/null; then
  # 이미 init 코드가 있으면 건너뜀
  if ! grep -q 'eval "\$\(zoxide init zsh\)"' "$TARGET_ZSHRC"; then
    echo 'eval "$(zoxide init zsh)"' >> "$TARGET_ZSHRC"
  fi

else
  # zoxide 미설치 시 간단한 안내 메시지(로그)만 추가하거나 생략
  echo "# ⚠️ zoxide가 설치되어 있지 않습니다. 설치 후 'brew install zoxide' 등을 실행하세요." >> "$TARGET_ZSHRC"
fi

# 성공 마커가 없으면 삽입
if ! grep -q "# \[ZOXIDE.SH\] APPLIED" "$TARGET_ZSHRC"; then
    {
      echo
      echo "# [ZOXIDE.SH] APPLIED -------------------------------------------------------- #" 
    }>> "$TARGET_ZSHRC"
fi

rm -f "$TARGET_ZSHRC.bak"
exit 0