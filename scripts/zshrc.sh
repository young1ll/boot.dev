#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# 최상단에 ROOT_DIR을 정의해야 $ROOT_DIR 변수가 올바르게 설정됩니다.
# -----------------------------------------------------------------------------
# readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# readonly SELECTED_FILE="$ROOT_DIR/.selected_brewfile"
readonly ZSHRC_SNIPPETS_DIR="$ROOT_DIR/dotfiles/zshrc"
readonly TARGET_ZSHRC="$HOME/.zshrc"

export ZSHRC_SNIPPETS_DIR
export TARGET_ZSHRC

# POWERLEVEL9K_SHORTEN_STRATEGY=\"truncate_to_last\""
# POWERLEVEL9K_SHORTEN_DIR_LENGTH=2"
# configure_p10k() {
#   local p10k_rc="$HOME/.p10k.zsh"

#   if [[ -f "$p10k_rc" ]]; then
#     g_log info "▶ $p10k_rc 파일이 이미 존재하므로, 편집을 시작합니다."

#     # (A) 편집 전 파일 내용 디버깅 출력 (선택적)
#     # g_log info "▶ (디버깅) 현재 $p10k_rc 상위 50줄을 출력합니다:"
#     # sed -n '1,50p' "$p10k_rc" | sed 's/^/    /'

#     # (B) 임시 파일 생성
#     local tmpfile
#     tmpfile="$(mktemp "${TMPDIR:-/tmp}/p10k.XXXXX")"

#     # 1) 줄 전체를 덮어쓰는 방식으로 짤끔하게 패턴 매칭 (공백/등호 주변 허용)
#     sed -E 's/^[[:space:]]*POWERLEVEL9K_SHORTEN_STRATEGY[[:space:]]*=[[:space:]]*.*$/POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_last"/' \
#       "$p10k_rc" > "$tmpfile"

#     # 2) 방금 만든 tmpfile을 다시 읽어서 SHORTEN_DIR_LENGTH도 변경
#     sed -E 's/^[[:space:]]*POWERLEVEL9K_SHORTEN_DIR_LENGTH[[:space:]]*=[[:space:]]*.*$/POWERLEVEL9K_SHORTEN_DIR_LENGTH=2/' \
#       "$tmpfile" > "${tmpfile}.2"

#     # (C) 편집 결과를 원본에 반영 (심볼릭 링크 여부에 따라 분기)
#     if [[ -L "$p10k_rc" ]]; then
#       # 링크라면, 실제 원본 경로를 찾아서 덮어쓰되 권한·타임스탬프 보존
#       target="$(readlink "$p10k_rc")"
#       cp -p "${tmpfile}.2" "$target"
#       g_log info "[APPLY] $p10k_rc 는 링크이므로, 원본($target)에 수정 내용을 적용했습니다."
#     else
#       # 일반 파일인 경우 바로 덮어쓰기
#       mv "${tmpfile}.2" "$p10k_rc"
#       g_log info "[APPLY] $p10k_rc 파일에 수정 내용을 적용했습니다."
#     fi

#     # (D) 임시 파일 정리
#     rm -f "$tmpfile"

#     g_log info "[APPLY] $p10k_rc 내부 POWERLEVEL9K_SHORTEN 설정이 성공적으로 적용되었습니다."
#   else
#     g_log warn "⚠️ 아직 $p10k_rc 파일이 없습니다. 'p10k configure'를 먼저 실행해 주세요."
#     g_log warn "   파일이 생성된 뒤, 아래 두 설정을 수동으로 추가하거나 스크립트를 다시 실행해야 합니다:"
#     echo "     POWERLEVEL9K_SHORTEN_STRATEGY=\"truncate_to_last\""
#     echo "     POWERLEVEL9K_SHORTEN_DIR_LENGTH=2"
#   fi
# }

configzsh_defaults() {
  source "$ROOT_DIR/scripts/utilities/format.sh"
  source "$ROOT_DIR/scripts/utilities/gum.sh"

  # 기본 스니펫 목록
  local default_snippets=(
    "common.sh"
    "p10k.sh"
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
    "firefox" "google-chrome"

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
  if gum spin --show-output --title "zsh 설정 중..." -- bash -c "apply_zsh_config_wrapper > \"${TMP_LOG}\" 2>&1"; then
    g_log info "✅ zsh 설정이 성공적으로 완료되었습니다."
  else
    g_log error "❌ zsh 설정 중 오류가 발생했습니다. 로그 파일을 확인하세요: ${F_DIM}${TMP_LOG}${NO_FORMAT}"
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
