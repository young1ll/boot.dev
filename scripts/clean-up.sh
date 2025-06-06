#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# 로거 함수: 타임스탬프 + 레벨 + [BOOTWIZARD] 태그를 붙여 출력합니다.
# -----------------------------------------------------------------------------

std_info() {
  source "$ROOT_DIR/scripts/utilities/format.sh"
  echo -e "$(date '+%d %b %y %H:%M %Z') ${C_DARKOLIVEGREEN3}[INFO]${NO_FORMAT} ${F_DIM}${C_GREY70}[BOOTWIZARD]${NO_FORMAT} $1"
}
std_warn() {
  source "$ROOT_DIR/scripts/utilities/format.sh"
  echo -e "$(date '+%d %b %y %H:%M %Z') ${C_DARKOLIVEGREEN3}[WARN]${NO_FORMAT} ${F_DIM}${C_GREY70}[BOOTWIZARD]${NO_FORMAT} $1"
}
std_error() {
  source "$ROOT_DIR/scripts/utilities/format.sh"
  echo -e "$(date '+%d %b %y %H:%M %Z') ${C_DARKOLIVEGREEN3}[ERROR]${NO_FORMAT} ${F_DIM}${C_GREY70}[BOOTWIZARD]${NO_FORMAT} $1"
}

# 서브셸에서도 std_* 함수를 인식하도록 export 합니다.
export -f std_info std_warn std_error

# -----------------------------------------------------------------------------
# remove_init: 초기화 도구(gum 등)를 제거합니다.
# -----------------------------------------------------------------------------
remove_init() {
  # 예시: Homebrew로 설치된 gum 패키지 제거
  if command -v brew &>/dev/null && brew list gum &>/dev/null; then
    std_info "Homebrew 패키지 'gum'을 제거합니다."
    brew uninstall gum
    std_info "Homebrew 패키지 'gum' 제거가 완료되었습니다."
  else
    std_warn "Homebrew의 'gum' 패키지가 설치되어 있지 않습니다."
  fi

  echo
}
export -f remove_init

# -----------------------------------------------------------------------------
# clean_up: 임시 로그 디렉토리, 선택된 Brewfile, TMP_LOG 파일 등을 모두 삭제합니다.
# -----------------------------------------------------------------------------
clean_up() {
  # 부모 셸에서 정의된 변수를 서브셸에서도 사용하기 위해 export 합니다.
  # export SELECTED_FILE="$ROOT_DIR/.selected_brewfile"
  export TMP_LOG_DIR="${HOME}/.cache/my-script-logs"

  gum spin --show-output --title "🧹 clean up..." -- bash -c "
    # 1) 초기화 도구 제거
    std_info \"초기화 도구를 제거합니다...\"
    remove_init

    # 2) Homebrew 캐시 정리
    if command -v brew &>/dev/null; then
      std_info \"Homebrew 캐시를 정리합니다...\"
      brew cleanup --prune=all
      std_info \"Homebrew 캐시 정리가 완료되었습니다.\"
    else
      std_warn \"brew 명령을 찾을 수 없습니다. 캐시 정리를 건너뜁니다.\"
    fi

    # 3) 임시 로그 디렉토리 삭제
    if [[ -d \"\$TMP_LOG_DIR\" ]]; then
      std_info \"임시 로그 디렉토리를 삭제합니다: ${F_DIM}\$TMP_LOG_DIR${NO_FORMAT}\"
      rm -rf \"\$TMP_LOG_DIR\"
      std_info \"임시 로그 디렉토리를 삭제했습니다.\"
    else
      std_warn \"로그 디렉토리가 존재하지 않습니다: ${F_DIM}\$TMP_LOG_DIR${NO_FORMAT}\"
    fi

    # 4) .selected_brewfile 삭제
    if [[ -f \"\$SELECTED_FILE\" ]]; then
      std_info \"선택된 Brewfile 경로 파일을 삭제합니다: ${F_DIM}\$SELECTED_FILE${NO_FORMAT}\"
      rm -f \"\$SELECTED_FILE\"
      std_info \"선택된 Brewfile 경로 파일을 삭제했습니다.\"
    else
      std_warn \"삭제할 Brewfile 경로 파일이 없습니다: ${F_DIM}\$SELECTED_FILE${NO_FORMAT}\"
    fi

    # # 5) TMP_LOG 파일(화면에 남은 모든 임시 로그) 삭제
    # if [[ -n \"\$TMPDIR\" ]]; then
    #   std_info \"TMPDIR (\$TMPDIR) 아래에서 brewfiles_log*와 configzsh_log* 파일을 삭제합니다.\"
    #   rm -f \"\$TMPDIR\"brewfiles_log* \"\$TMPDIR\"configzsh_log*
    #   std_info \"TMPDIR 내 임시 로그 파일을 삭제했습니다.\"
    # fi

    # # /tmp 경로 아래에도 남아 있을 수 있으므로 한 번 더 정리
    # std_info \"/tmp 경로 아래에서 brewfiles_log*와 configzsh_log* 파일을 삭제합니다.\"
    # rm -f /tmp/brewfiles_log* /tmp/configzsh_log*
    # std_info \"/tmp 경로 아래 임시 로그 파일 삭제가 완료되었습니다.\"

    # 6) 최종 완료 메시지
    echo
    std_info \"✨ 모든 정리 작업이 완료되었습니다.\"
  "

  return 0
}
export -f clean_up
