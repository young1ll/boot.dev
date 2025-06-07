#!/usr/bin/env bash
TARGET_ZSHRC="$1"

# (1) .zshrc 파일이 없으면 생성
if [[ ! -f "$TARGET_ZSHRC" ]]; then
  touch "$TARGET_ZSHRC"
fi

if grep -q "# \[COMMON.SH\] APPLIED" "$TARGET_ZSHRC"; then
  exit 0
fi

# 헤더 블록이 없는 경우에만 삽입
if ! grep -q "# \[COMMON.SH\] STARTED" "$TARGET_ZSHRC"; then
  {
    echo 
    echo "# [COMMON.SH] STARTED -------------------------------------------------------- #"
  } >> "$TARGET_ZSHRC"
fi

# zsh-autosuggestions 로드 라인
if ! grep -q 'source[[:space:]]\$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions\.zsh' "$TARGET_ZSHRC"; then
  {
    echo 'source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh'
    echo
  } >> "$TARGET_ZSHRC"
fi

# zsh-syntax-highlighting 로드 라인
if ! grep -q 'source[[:space:]]\$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting\.zsh' "$TARGET_ZSHRC"; then
  {
    echo 'source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'
    echo
  } >> "$TARGET_ZSHRC"
fi

# 기본 플러그인 추가
required_plugins=(zsh-autosuggestions zsh-syntax-highlighting colorize zsh-interactive-cd colored-man-pages web-search)
# octozen
if grep -q '^plugins=' "$TARGET_ZSHRC"; then
  # 현재 plugins=(...) 라인을 가져와서 괄호 안의 내용만 추출
  existing_line=$(grep '^plugins=' "$TARGET_ZSHRC")
  existing_content=${existing_line#plugins=(}
  existing_content=${existing_content%)}

  # 공백 기준으로 단어 분리하여 배열로 변환
  read -a existing_array <<< "$existing_content"

  # 필수 플러그인이 배열에 없으면 추가
  for plugin in "${required_plugins[@]}"; do
    if [[ ! " ${existing_array[*]} " =~ " $plugin " ]]; then
      existing_array+=("$plugin")
    fi
  done

  # 새로운 plugins=() 문자열 조합
  new_plugins_line="plugins=(${existing_array[*]})"

  # .zshrc에서 기존 plugins=라인을 대체
  sed -i.bak "s|^plugins=.*|$new_plugins_line|" "$TARGET_ZSHRC"
else
  # plugins=() 라인이 아예 없는 경우
  printf "plugins=(%s)\n" "${required_plugins[*]}" >> "$TARGET_ZSHRC"
fi

# alias ll 설정 (이미 있으면 업데이트, 없으면 추가)
if grep -q "^alias ll=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^alias ll=.*|alias ll='ls -lahF'|" "$TARGET_ZSHRC"
else
  echo "alias ll='ls -lahF'" >> "$TARGET_ZSHRC"
fi

# export CLICOLOR 설정
if grep -q "^export CLICOLOR=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^export CLICOLOR=.*|export CLICOLOR=1|" "$TARGET_ZSHRC"
else
  echo "export CLICOLOR=1" >> "$TARGET_ZSHRC"
fi

# export LSCOLORS 설정
if grep -q "^export LSCOLORS=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^export LSCOLORS=.*|export LSCOLORS=GxFxCxDxBxegedabagaced|" "$TARGET_ZSHRC"
else
  echo "export LSCOLORS=GxFxCxDxBxegedabagaced" >> "$TARGET_ZSHRC"
fi

# export PS1 설정
if grep -q "^export PS1=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^export PS1=.*|export PS1='%F{cyan}%n@%m%f:%F{yellow}%~%f %# '|" "$TARGET_ZSHRC"
else
  echo "export PS1='%F{cyan}%n@%m%f:%F{yellow}%~%f %# '" >> "$TARGET_ZSHRC"
fi

# 성공 마커가 없으면 삽입
if ! grep -q "# \[COMMON.SH\] APPLIED" "$TARGET_ZSHRC"; then
  {
    echo
    echo "# [COMMON.SH] APPLIED -------------------------------------------------------- #"
  } >> "$TARGET_ZSHRC"
fi

rm -f "$TARGET_ZSHRC.bak"
exit 0