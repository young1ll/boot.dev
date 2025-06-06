#!/usr/bin/env bash

TARGET_ZSHRC="$1"

if grep -q "# \[BAT.SH\] APPLIED" "$TARGET_ZSHRC"; then
  exit 0
fi

# 헤더 블록이 없는 경우에만 삽입
if ! grep -q "# \[BAT.SH\] STARTED" "$TARGET_ZSHRC"; then
  {
    echo ""
    echo "# [BAT.SH] STARTED ----------------------------------------------------------- #"
  } >> "$TARGET_ZSHRC"
fi

# cat을 bat으로 변경
if grep -q "^alias cat=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^alias cat=.*|alias cat='bat --paging=never'|" "$TARGET_ZSHRC"
else
  echo "alias cat='bat --paging=never'" >> "$TARGET_ZSHRC"
fi

if grep -q "^alias gdiff=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^alias gdiff=.*|alias gdiff='git diff --name-only --relative --diff-filter=d | xargs bat --diff'|" "$TARGET_ZSHRC"
else
  echo "alias gdiff='git diff --name-only --relative --diff-filter=d | xargs bat --diff'" >> "$TARGET_ZSHRC"
fi

if grep -q "^alias gdiff=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^alias gdiff=.*|alias gdiff='git diff --name-only --relative --diff-filter=d | xargs bat --diff'|" "$TARGET_ZSHRC"
else
  echo "alias gdiff='git diff --name-only --relative --diff-filter=d | xargs bat --diff'" >> "$TARGET_ZSHRC"
fi

if grep -q "^batman()" "$TARGET_ZSHRC"; then
  # 이미 batman 함수가 있으면 정의를 교체
  sed -i.bak "s|^batman().*|batman() { man -t \"\$@\" | col -bx | bat -l man --paging=always; }|" "$TARGET_ZSHRC"
else
  # 없으면 파일 끝에 함수 정의를 추가
  cat << 'EOF' >> "$TARGET_ZSHRC"
batman() {
  man -t "$@" | col -bx | bat -l man --paging=always
}
EOF
fi

# 성공 마커가 없으면 삽입
if ! grep -q "# \[BAT.SH\] APPLIED" "$TARGET_ZSHRC"; then
  {
    echo
    echo "# [BAT.SH] APPLIED ----------------------------------------------------------- #"
  } >> "$TARGET_ZSHRC"
fi

rm -f "$TARGET_ZSHRC.bak"

exit 0