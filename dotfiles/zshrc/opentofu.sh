#!/usr/bin/env bash

TARGET_ZSHRC="$1"

if grep -q "# \[OPENTOFU.SH\] APPLIED" "$TARGET_ZSHRC"; then
  exit 0
fi

# 헤더 블록이 없는 경우에만 삽입
if ! grep -q "# \[OPENTOFU.SH\] STARTED" "$TARGET_ZSHRC"; then
  {
    echo
    echo "# [OPENTOFU.SH] STARTED ------------------------------------------------------ #"
  } >> "$TARGET_ZSHRC"
fi

opentofu_plugin=(opentofu)
if grep -q '^plugins=' "$TARGET_ZSHRC"; then
  # 현재 plugins=(...) 라인을 가져와서 괄호 안의 내용만 추출
  existing_line=$(grep '^plugins=' "$TARGET_ZSHRC")
  existing_content=${existing_line#plugins=(}
  existing_content=${existing_content%)}

  # 공백 기준으로 단어 분리하여 배열로 변환
  read -a existing_array <<< "$existing_content"

  # 필수 플러그인이 배열에 없으면 추가
  for plugin in "${opentofu_plugin[@]}"; do
    if [[ ! " ${existing_array[*]} " =~ " $plugin " ]]; then
      existing_array+=("$plugin")
    fi
  done

  # 새로운 plugins=() 문자열 조합
  new_plugins_line="plugins=(${existing_array[*]})"

  # .zshrc에서 기존 plugins=라인을 대체
  sed -i.bak "s|^plugins=.*|$new_plugins_line|" "$TARGET_ZSHRC"
  echo "# [OPENTOFU.SH] opentofu plugin has added above" >> "$TARGET_ZSHRC"
else
  # plugins=() 라인이 아예 없는 경우
  printf "plugins=(%s)\n" "${opentofu_plugin[*]}" >> "$TARGET_ZSHRC"
fi

# 성공 마커가 없으면 삽입
if ! grep -q "# \[OPENTOFU.SH\] APPLIED" "$TARGET_ZSHRC"; then
  {
    echo
    echo "# [OPENTOFU.SH] APPLIED ------------------------------------------------------ #"
  } >> "$TARGET_ZSHRC"
fi

rm -f "$TARGET_ZSHRC.bak"
exit 0