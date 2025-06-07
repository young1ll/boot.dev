#!/usr/bin/env bash
# fzf.sh: fzf 관련 설정을 .zshrc에 삽입 (예: fzf key binding 등)

TARGET_ZSHRC="$1"

if grep -q "# \[FZF.SH\] APPLIED" "$TARGET_ZSHRC"; then
  exit 0
fi

# 헤더 블록이 없는 경우에만 삽입
if ! grep -q "# \[FZF.SH\] STARTED" "$TARGET_ZSHRC"; then
  {
    echo
    echo "# [FZF.SH] STARTED ----------------------------------------------------------- #"
  } >> "$TARGET_ZSHRC"
fi

if grep -q "^export FZF_BASE=" "$TARGET_ZSHRC"; then
  sed -i.bak "s|^export FZF_BASE=.*|export FZF_BASE=\$(brew --prefix)/opt/fzf"| "$TARGET_ZSHRC"
else
  echo "export FZF_BASE=\$(brew --prefix)/opt/fzf" >> "$TARGET_ZSHRC"
fi

# FZF_DEFAULT_OPTS 설정 (없으면 추가, 있으면 덮어쓰기)
if grep -q '^export FZF_DEFAULT_OPTS=' "$TARGET_ZSHRC"; then
  sed -i.bak "s|^export FZF_DEFAULT_OPTS=.*|export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'|" "$TARGET_ZSHRC"
else
  echo "export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'" >> "$TARGET_ZSHRC"
fi

# FZF_CTRL_T_COMMAND 설정
if grep -q '^export FZF_CTRL_T_COMMAND=' "$TARGET_ZSHRC"; then
  :
else
  echo "export FZF_CTRL_T_COMMAND='find . -type f'" >> "$TARGET_ZSHRC"
fi

fzf_plugin=(fzf)
if grep -q '^plugins=' "$TARGET_ZSHRC"; then
  # 현재 plugins=(...) 라인을 가져와서 괄호 안의 내용만 추출
  existing_line=$(grep '^plugins=' "$TARGET_ZSHRC")
  existing_content=${existing_line#plugins=(}
  existing_content=${existing_content%)}

  # 공백 기준으로 단어 분리하여 배열로 변환
  read -a existing_array <<< "$existing_content"

  # 필수 플러그인이 배열에 없으면 추가
  for plugin in "${fzf_plugin[@]}"; do
    if [[ ! " ${existing_array[*]} " =~ " $plugin " ]]; then
      existing_array+=("$plugin")
    fi
  done

  # 새로운 plugins=() 문자열 조합
  new_plugins_line="plugins=(${existing_array[*]})"

  # .zshrc에서 기존 plugins=라인을 대체
  sed -i.bak "s|^plugins=.*|$new_plugins_line|" "$TARGET_ZSHRC"
  echo "# [FZF.SH] fzf plugin has added above" >> "$TARGET_ZSHRC"
else
  # plugins=() 라인이 아예 없는 경우
  printf "plugins=(%s)\n" "${fzf_plugin[*]}" >> "$TARGET_ZSHRC"
fi

 # 성공 마커가 없으면 삽입
if ! grep -q "# \[FZF.SH\] APPLIED" "$TARGET_ZSHRC"; then
  {
    echo
    echo "# [FZF.SH] APPLIED ----------------------------------------------------------- #"
  } >> "$TARGET_ZSHRC"
fi

rm -f "$TARGET_ZSHRC.bak"
exit 0
