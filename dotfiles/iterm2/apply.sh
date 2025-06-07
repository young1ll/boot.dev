#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# iterm2 색상 테마 복사만 담당하는 apply.sh 예시
# -----------------------------------------------------------------------------

# 유틸리티 로드 (g_log, g_warn, g_error 등)
source "$ROOT_DIR/scripts/utilities/format.sh"
source "$ROOT_DIR/scripts/utilities/gum.sh"

# DOTFILES_DIR이 이미 export 되어 있어야 합니다.
# 이 디렉토리 아래에 iterm2/schemes/*.itermcolors 파일들이 있어야 합니다.
CUSTOM_ITERM2_PREFS="$DOTFILES_DIR/iterm2"

g_log info "▶ iTerm2 신규 테마를 복사합니다."

COLOR_SCHEMES_SRC="$CUSTOM_ITERM2_PREFS/schemes"
COLOR_SCHEMES_DEST="$HOME/Library/Application Support/iTerm2/ColorSchemes"

if [[ -d "$COLOR_SCHEMES_SRC" ]]; then
  mkdir -p "$COLOR_SCHEMES_DEST"
  cp "$COLOR_SCHEMES_SRC"/*.itermcolors "$COLOR_SCHEMES_DEST"/ 2>/dev/null || true
  g_log info "iTerm2 색상 테마를 '$COLOR_SCHEMES_DEST' 로 복사했습니다."
else
  g_log warn "색상 테마 디렉토리를 찾을 수 없습니다: $COLOR_SCHEMES_SRC (SKIP)"
fi

return
