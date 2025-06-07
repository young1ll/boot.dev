#!/usr/bin/env bash
set -euo pipefail

readonly ZSHRC_SNIPPETS_DIR="$ROOT_DIR/dotfiles/zshrc"
readonly TARGET_ZSHRC="$HOME/.zshrc"

export ZSHRC_SNIPPETS_DIR
export TARGET_ZSHRC

configzsh_defaults() {
  source "$ROOT_DIR/scripts/utilities/format.sh"
  source "$ROOT_DIR/scripts/utilities/gum.sh"

  # 기본 스니펫 목록
  local default_snippets=(
    "p10k.sh"
    "common.sh"
    # 필요 시 추가
  )

  for snippet in "${default_snippets[@]}"; do
    local snippet_path="$ZSHRC_SNIPPETS_DIR/$snippet"

    if [[ ! -f "$snippet_path" ]]; then
      g_log warn "[NOT FOUND] 기본 스니펫 파일이 없습니다: $snippet"
      continue
    fi

    # 이미 적용되었는지 체크 (common.sh 예시)
    local marker="# [${snippet%%.sh^^}.SH] APPLIED"
    # 위 마커를 그대로 grep 패턴으로 사용하기 위해 약간 가공:
    marker="# \[${snippet%%.sh}\\.SH\] APPLIED"

    if grep -q "$marker" "$TARGET_ZSHRC"; then
      g_log info "[IGNORE] ${snippet} 이미 적용됨."
      continue
    fi

    # 스니펫 실행 → .zshrc 직접 수정
    bash "$snippet_path" "$TARGET_ZSHRC"
    if (( $? == 0 )); then
      g_log info "[APPLY] ${snippet} 실행 완료"
    else
      g_log error "[ERROR] ${snippet} 실행 실패"
    fi
  done

  return 0
}
export -f configzsh_defaults

configzsh_tools() {
  source "$ROOT_DIR/scripts/utilities/format.sh"
  source "$ROOT_DIR/scripts/utilities/gum.sh"

  local ignore_tools=(
    "mas" "curl" "wget" "cowsay" "tree" "xcodes"
    # "qlcolorcode" "qlmarkdown" "qlstephen" "quicklook-csv" "quicklook-json"

    "btop" "htop" "ncdu" "fastfetch" "bmon" "glances" "gotop" "vnstat" 
    "coreutils" "findutils" "gnu-*" "gawk" "grep" "zlib"
    "zsh" "zsh-*"

    "openssl" "mkcert"

    "tig" "git-flow"

    "dnsmasq" "nginx" "jq" "rapidapi" "nload" "mtr" "nikto" "iftop" "tcpdump"
    # "httpie"
    "colima" "hadolint"
    # "docker" "docker-*"

    "visual-studio-code" "iterm2" "vim"
    # "tmux"
    "firefox" "google-chrome" "google-drive" "synology-drive" "karabiner-elements"

    "vercel-cli" "aws-sam-cli" "session-manager-plugin"
    # "azure-cli"
    "krew" "stern"
    # "k9s" "heroku" "helm"

    "structurizr-cli" "tableplus"
    # "awscli" "eksctl"
    "slack" "whatsapp"
  )

  for tool in "${unique_tools[@]}"; do
    # ignore 패턴 매칭 시 건너뜀
    for pat in "${ignore_tools[@]}"; do
      if [[ "$tool" == $pat ]]; then
        g_log info "${F_DIM}[IGNORE] $tool (패턴: $pat) — 스니펫 실행 생략${NO_FORMAT}"
        continue 2
      fi
    done

    local snippet_path="$ZSHRC_SNIPPETS_DIR/$tool.sh"
    if [[ ! -f "$snippet_path" ]]; then
      g_log warn "${F_DIM}[NOT FOUND] 스니펫 파일 없음: $snippet_path${NO_FORMAT}"
      continue
    fi

    # 이미 실행된 스니펫인지 체크
    uppercase_tool=$(printf "%s" "$tool" | tr '[:lower:]' '[:upper:]')
    local marker="# [${uppercase_tool}.SH] APPLIED"
    if grep -q "$marker" "$TARGET_ZSHRC"; then
      g_log info "[SKIP] ${tool}.sh 이미 적용됨."
      continue
    fi

    # 스니펫 실행 → .zshrc 직접 수정
    bash "$snippet_path" "$TARGET_ZSHRC"
    if (( $? == 0 )); then
      g_log info "[APPLY] ${tool}.sh 실행 완료"
    else
      g_log error "[ERROR] ${tool}.sh 실행 실패"
    fi
  done

  return 0
}
export -f configzsh_tools

apply_zsh_config_wrapper() {
  # (1) 부모 셸에서 serialize 했던 문자열을 배열로 복원
  IFS=$'\n' read -r -d '' -a unique_tools <<< "${UNIQUE_TOOLS_STR}"$'\0'

  # (2) configzsh_defaults / configzsh_tools 호출
  configzsh_defaults
  local status_defaults=$?
  configzsh_tools
  local status_tools=$?

  # (3) 두 함수 중 한 군데라도 실패하면 “1”을, 아니면 “0”을 반환
  if (( status_defaults != 0 || status_tools != 0 )); then
    return 1
  else
    return 0
  fi
}
export -f apply_zsh_config_wrapper

run_zshrc() {
  if ! g_confirm "이어서 앞서 설치한 Brewfile의 zsh 설정을 진행할까요?"; then
      g_log error "zsh 설정이 중단되었습니다."
      return 1
  fi

  # 1) .selected_brewfile 확인
  if [[ ! -f "$SELECTED_FILE" ]]; then
    g_log error "선택된 Brewfile 경로를 찾을 수 없습니다: ${F_DIM}$SELECTED_FILE${NO_FORMAT}"
    exit 1
  fi

  # 2) Brewfile에서 tool 이름만 추출
  declare -a tools_list=()
  while IFS= read -r brewfile_path; do
    [[ -z "$brewfile_path" || "${brewfile_path:0:1}" == "#" ]] && continue

    if [[ ! -f "$brewfile_path" ]]; then
      g_log warn "Brewfile 경로가 존재하지 않습니다: $brewfile_path"
      continue
    fi

    while IFS= read -r line; do
      trimmed="${line#"${line%%[![:space:]]*}"}"
      if [[ "$trimmed" =~ ^(brew|cask)[[:space:]]\"([^\"]+)\" ]]; then
        tools_list+=("${BASH_REMATCH[2]}")
      fi
    done < "$brewfile_path"
  done < "$SELECTED_FILE"

  # 고유 도구 이름 배열 생성
  unique_tools=()
  while IFS= read -r tool; do
    unique_tools+=("$tool")
  done < <(printf "%s\n" "${tools_list[@]}" | sort -u)

  # 3) ~/.zshrc 파일 준비
  if [[ ! -f "$TARGET_ZSHRC" ]]; then
    g_log info "[APPLY] ~/.zshrc 파일이 없으므로 새로 생성합니다: ${F_DIM}$TARGET_ZSHRC${NO_FORMAT}"
    touch "$TARGET_ZSHRC"
  fi

  local start_ts end_ts elapsed
  start_ts=$(date +%s)

  # 4) TMP_LOG 생성
  local TMP_LOG
  TMP_LOG=$(mktemp -t configzsh_log)

  export UNIQUE_TOOLS_STR="$(printf "%s\n" "${unique_tools[@]}")"
  
  if ! configzsh_defaults; then
    g_log error "❌ 기본 스니펫 적용 중 오류가 발생했습니다."
    return 1
  fi

  if ! configzsh_tools; then
    g_log error "❌ 도구 스니펫 적용 중 오류가 발생했습니다."
    return 1
  fi

  sed -E 's/\x1B\[[0-9;?]*[A-Za-z]//g' "${TMP_LOG}" > "${TMP_LOG}.clean"
  mv "${TMP_LOG}.clean" "${TMP_LOG}"

  end_ts=$(date +%s)
  elapsed=$(( end_ts - start_ts ))

  local -i num_default_snippets=2
  local num_tool_snippets="${#unique_tools[@]}"
  local total_snippets=$(( num_default_snippets + num_tool_snippets ))

  local applied_count ignored_count skipped_count notfound_count
  applied_count=$(awk '/\[APPLY\][[:space:]]/ { count++ } END { print (count ? count : 0) }' "${TMP_LOG}")
  ignored_count=$(awk '/\[IGNORE\][[:space:]]/ { count++ } END { print (count ? count : 0) }' "${TMP_LOG}")
  skipped_count=$(awk '/\[SKIP\][[:space:]]/ { count++ } END { print (count ? count : 0) }' "${TMP_LOG}")
  notfound_count=$(awk '/\[NOT[[:space:]]FOUND\][[:space:]]/ { count++ } END { print (count ? count : 0) }' "${TMP_LOG}")

  # 8) 최종 요약 출력
  gum style \
    --foreground 210 --border-foreground 210 --border double \
    --align left --width 100 --margin "1 0" --padding "1 2" \
    "================================================================================================" \
    " 🤖 ${F_BOLD}ZSH 설정 요약${NO_FORMAT}    " \
    "================================================================================================" \
    "" \
    " TOTAL:        $total_snippets" \
    " APPLIED:      $applied_count"$'\t'"IGNORED:      $ignored_count"$'\t'"SKIPPED:      ${skipped_count}"$'\t'"NOT FOUNDED:  ${notfound_count}" \
    "" \
    " LOG FILE:   ${F_DIM}${TMP_LOG}${NO_FORMAT}" \
    " DURATION:   ${elapsed}초"

  return 0
}
