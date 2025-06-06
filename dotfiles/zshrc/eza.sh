#!/usr/bin/env bash

TARGET_ZSHRC="$1"

if grep -q "# \[EZA.SH\] APPLIED" "$TARGET_ZSHRC"; then
    exit 0
fi

# 헤더 블록이 없는 경우에만 삽입
if ! grep -q "# \[EZA.SH\] STARTED" "$TARGET_ZSHRC"; then
    {
        echo ""
        echo "# [EZA.SH] STARTED ----------------------------------------------------------- #"
        echo "# Reference: https://www.gnu.org/software/coreutils/manual/coreutils.html"
        echo ""
    } >> "$TARGET_ZSHRC"
fi

# alias els 설정 (이미 있으면 업데이트, 없으면 추가)
if grep -q "^alias els=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^alias els=.*|alias els='eza --color=auto'|" "$TARGET_ZSHRC"
else
  echo "alias els='eza --header --color=auto'" >> "$TARGET_ZSHRC"
fi

# alias ell 설정 (이미 있으면 업데이트, 없으면 추가)
if grep -q "^alias ell=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^alias ell=.*|alias ell='eza -l -h --git --group-directories-first|" "$TARGET_ZSHRC"
else
  echo "alias ell='eza --header -l --git --group-directories-first'" >> "$TARGET_ZSHRC"
fi

# alias elsd 설정 (이미 있으면 업데이트, 없으면 추가)
if grep -q "^alias elsd=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^alias elsd=.*|alias elsd='eza -l -h --group-directories-first --only-dirs|" "$TARGET_ZSHRC"
else
  echo "alias elsd='eza --header -l --group-directories-first --only-dirs'" >> "$TARGET_ZSHRC"
fi

# 성공 마커가 없으면 삽입
if ! grep -q "# \[EZA.SH\] APPLIED" "$TARGET_ZSHRC"; then
    {
        echo
        echo "# [EZA.SH] APPLIED ----------------------------------------------------------- #" 
    }>> "$TARGET_ZSHRC"
fi

rm -f "$TARGET_ZSHRC.bak"
exit 0