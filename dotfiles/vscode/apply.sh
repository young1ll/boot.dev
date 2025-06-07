#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# dotfiles/vscode/apply.sh
#  - 준비된 settings.json 파일을 사용자의 VSCode 설정 경로로 복사/백업합니다.
# -----------------------------------------------------------------------------

# (A) 유틸리티 로드 (g_log, g_warn 등)
source "${ROOT_DIR:-$HOME/dotfiles}/scripts/utilities/format.sh"
source "${ROOT_DIR:-$HOME/dotfiles}/scripts/utilities/gum.sh"

# (B) 원본(settings.json) 및 대상 경로 설정
SRC_SETTINGS="${ROOT_DIR:-$HOME/dotfiles}/dotfiles/vscode/settings.json"

# OS별 VSCode 사용자 설정 디렉터리 분기
if [[ "$OSTYPE" == darwin* ]]; then
  # macOS
  DEST_DIR="$HOME/Library/Application Support/Code/User"
else
  # 리눅스 계열
  DEST_DIR="$HOME/.config/Code/User"
fi

DEST_SETTINGS="$DEST_DIR/settings.json"

# (C) settings.json 원본 존재 여부 검사
if [[ ! -f "$SRC_SETTINGS" ]]; then
  g_log error "원본 settings.json을 찾을 수 없습니다: $SRC_SETTINGS"
  exit 1
fi

# (D) 대상 디렉터리 생성
if [[ ! -d "$DEST_DIR" ]]; then
  g_log info "VSCode 설정 디렉터리가 없으므로 생성합니다: $DEST_DIR"
  mkdir -p "$DEST_DIR"
fi

# (E) 기존 settings.json 백업
if [[ -f "$DEST_SETTINGS" ]]; then
  TIMESTAMP="$(date +%Y%m%d%H%M%S)"
  BACKUP_FILE="$DEST_SETTINGS.$TIMESTAMP.bak"
  cp "$DEST_SETTINGS" "$BACKUP_FILE"
  g_log info "기존 VSCode settings.json 백업 완료: $BACKUP_FILE"
fi

# (F) 새로운 settings.json 복사
cp "$SRC_SETTINGS" "$DEST_SETTINGS"
g_log info "새로운 settings.json을 적용했습니다: $DEST_SETTINGS"

return
