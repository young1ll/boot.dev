#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# fastfetch/apply.sh
#  • fastfetch가 설치되어 있지 않으면 Homebrew로 설치합니다.
#  • JSONC 포맷의 설정 파일(config.jsonc)을 ~/.config/fastfetch으로 복사합니다.
# -----------------------------------------------------------------------------

# 유틸리티 로드 (g_log, g_warn, g_error 등)
source "$ROOT_DIR/scripts/utilities/format.sh"
source "$ROOT_DIR/scripts/utilities/gum.sh"

g_log info "▶ fastfetch 설치 및 JSONC 설정을 시작합니다..."

# -----------------------------------------------------------------------------
# 1) fastfetch 설치 여부 확인
# -----------------------------------------------------------------------------
if command -v fastfetch >/dev/null 2>&1; then
  g_log info "fastfetch가 이미 설치되어 있습니다."
else
  if command -v brew >/dev/null 2>&1; then
    g_log info "Homebrew를 통해 fastfetch를 설치합니다..."
    if brew install fastfetch; then
      g_log info "fastfetch 설치가 완료되었습니다."
    else
      g_log error "fastfetch 설치에 실패했습니다. 설치 로그를 확인하세요."
      exit 1
    fi
  else
    g_log warn "Homebrew를 찾을 수 없습니다. 수동으로 fastfetch를 설치해주세요."
  fi
fi

# -----------------------------------------------------------------------------
# 2) JSONC 설정 파일 복사
#    dotfiles/fastfetch/config.jsonc → ~/.config/fastfetch/config.jsonc
# -----------------------------------------------------------------------------
CUSTOM_CONFIG_DIR="$DOTFILES_DIR/fastfetch"
TARGET_CONFIG_DIR="$HOME/.config/fastfetch"

if [[ -d "$CUSTOM_CONFIG_DIR" ]]; then
  mkdir -p "$TARGET_CONFIG_DIR"

  SRC_JSONC="$CUSTOM_CONFIG_DIR/config.jsonc"
  DST_JSONC="$TARGET_CONFIG_DIR/config.jsonc"

  if [[ -f "$SRC_JSONC" ]]; then
    cp -p "$SRC_JSONC" "$DST_JSONC"
    g_log info "fastfetch JSONC 설정 파일을 '$DST_JSONC'로 복사했습니다."
  else
    g_log warn "JSONC 설정 파일을 찾을 수 없습니다: $SRC_JSONC (SKIP)"
  fi
else
  g_log warn "fastfetch 커스텀 설정 디렉토리를 찾을 수 없습니다: $CUSTOM_CONFIG_DIR"
fi

# -----------------------------------------------------------------------------
# 3) 완료 알림
# -----------------------------------------------------------------------------
g_log info "✅ fastfetch 설치 및 JSONC 설정이 완료되었습니다."
g_log info "   터미널을 재시작하고, 'fastfetch' 명령을 실행하여 JSONC 설정이 반영되는지 확인하세요."

exit 0
