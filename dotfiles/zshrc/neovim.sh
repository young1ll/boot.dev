#!/usr/bin/env bash

TARGET_ZSHRC="$1"

if grep -q "# \[NEOVIM.SH\] APPLIED" "$TARGET_ZSHRC"; then
  exit 0
fi

# 헤더 블록이 없는 경우에만 삽입
if ! grep -q "# \[NEOVIM.SH\] STARTED" "$TARGET_ZSHRC"; then
  {
    echo
    echo "# [NEOVIM.SH] STARTED -------------------------------------------------------- #"
  } >> "$TARGET_ZSHRC"
fi

# alias vim 설정
if grep -q "^alias vim=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^alias vim=.*|alias vim='nvim'|" "$TARGET_ZSHRC"
else
  echo "alias vim='nvim'" >> "$TARGET_ZSHRC"
fi

if grep -q "^alias vi=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^alias vi=.*|alias vi='nvim'|" "$TARGET_ZSHRC"
else
  echo "alias vi='nvim'" >> "$TARGET_ZSHRC"
fi

if grep -q "^alias vimdiff=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^alias vimdiff=.*|alias vimdiff='nvim -d'|" "$TARGET_ZSHRC"
else
  echo "alias vimdiff='nvim -d'" >> "$TARGET_ZSHRC"
fi

if grep -q "^export EDITOR=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^export EDITOR=.*|export EDITOR=/usr/local/bin/nvim|" "$TARGET_ZSHRC"
else
  echo "export EDITOR=/usr/local/bin/nvim" >> "$TARGET_ZSHRC"
fi

# LazyVim 설정 추가 ---------------------------------------------------------- #
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# 성공 마커가 없으면 삽입
if ! grep -q "# \[NEOVIM.SH\] APPLIED" "$TARGET_ZSHRC"; then
  {
    echo
    echo "# [NEOVIM.SH] APPLIED -------------------------------------------------------- #"
  } >> "$TARGET_ZSHRC"
fi

rm -f "$TARGET_ZSHRC.bak"
exit 0