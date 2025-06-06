#!/usr/bin/env bash
set -euo pipefail

# SDKMAN 설치 확인 및 설치 --------------------------------------------------- #
run_sdkman () {
  if ! command -v sdk &>/dev/null; then
    if g_confirm "☕ SDKMAN을 설치하시겠습니까?"; then
      gum spin --show-output --title "SDKMAN 설치 중..."
      curl -s "https://get.sdkman.io" | bash
      g_log info "✅ SDKMAN 설치 완료"
    else
      g_log error "❌ SDKMAN 설치 취소"
      exit 1
    fi
  else
    g_log info "✅ SDKMAN 이미 설치됨"
  fi

  # SDKMAN 초기화: 설치가 완료되면 sdkman-init.sh 를 소스
  export SDKMAN_DIR="$HOME/.sdkman"
  source "$SDKMAN_DIR/bin/sdkman-init.sh" # shellcheck source=/dev/null

  # .zshrc 편집
  ZSHRC_FILE="$HOME/.zshrc"

  if [[ ! -f "$ZSHRC_FILE" ]]; then
    g_log error "'$ZSHRC_FILE' 파일을 찾을 수 없습니다." >&2
    exit 1
  fi

  # plugins 블록에 추가할 항목 목록
  required_plugins=(sdk spring)

  if grep -q '^plugins=' "$ZSHRC_FILE"; then
    # 이미 plugins 라인이 있다면, 괄호 내부 내용을 파싱
    existing_line=$(grep '^plugins=' "$ZSHRC_FILE")
    existing_content=${existing_line#plugins=(}
    existing_content=${existing_content%)}

    # 공백 기준으로 단어 배열화
    read -a existing_array <<< "$existing_content"

    # 각 플러그인이 배열에 없으면 추가
    for plugin in "${required_plugins[@]}"; do
      if [[ ! " ${existing_array[*]} " =~ " $plugin " ]]; then
        existing_array+=("$plugin")
        g_log info "'$plugin' 플러그인이 없어 추가합니다."
      else
        g_log info "'$plugin' 플러그인이 이미 존재합니다. 건너뜁니다."
      fi
    done

    # 새로운 plugins=() 문자열 조합
    new_plugins_line="plugins=(${existing_array[*]})"

    # .zshrc에서 기존 plugins=라인을 대체 → 백업 파일 즉시 삭제
    sed -i.bak "s|^plugins=.*|$new_plugins_line|" "$ZSHRC_FILE" && rm -f "$ZSHRC_FILE.bak"
    g_log info "plugins 블록을 업데이트했습니다:"
    echo "       $new_plugins_line"
  else
    # plugins=(…) 블록이 전혀 없는 경우, 지정된 모든 플러그인을 새로 추가
    printf "\nplugins=(%s)\n" "${required_plugins[*]}" >> "$ZSHRC_FILE"
    g_log info "plugins 블록이 없어, 'plugins=(${required_plugins[*]})' 라인을 추가했습니다."
  fi

  g_log info ".zshrc 수정이 완료되었습니다."
}