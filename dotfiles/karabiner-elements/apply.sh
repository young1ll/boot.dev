#!/usr/bin/env bash
set -euo pipefail

# 유틸리티 로드 (g_log, g_warn, g_error 등)
source "$ROOT_DIR/scripts/utilities/format.sh"
source "$ROOT_DIR/scripts/utilities/gum.sh"

KARABINER_DIR="$DOTFILES_DIR/karabiner-elements"
TARGET_DIR="$HOME/.config/karabiner"

g_log info "▶ Karabiner 설정 복사를 시작합니다."

# 1) karabiner.json 존재 여부 확인
if [[ ! -f "$KARABINER_DIR/karabiner.json" ]]; then
  g_log error "'$KARABINER_DIR/karabiner.json' 파일을 찾을 수 없습니다." >&2
  exit 1
fi

# 2) 기존 ~/.config/karabiner 경로 처리
if [[ -L "$TARGET_DIR" ]]; then
  # 심볼릭 링크인 경우 삭제
  rm "$TARGET_DIR"
  g_log info "기존 심볼릭 링크 삭제: $TARGET_DIR"
elif [[ -d "$TARGET_DIR" ]]; then
  # 실제 디렉터리라면 백업 후 삭제
  backup_dir="${TARGET_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
  mv "$TARGET_DIR" "$backup_dir"
  g_log info "기존 디렉터리를 백업: $TARGET_DIR → $backup_dir"
fi

# 3) 새 디렉터리 생성
mkdir -p "$TARGET_DIR"
g_log info "새 디렉터리 생성: $TARGET_DIR"

# 4) KARABINER_DIR 내용 전체를 복사 (숨김 파일 포함)
cp -a "$KARABINER_DIR/." "$TARGET_DIR/"
g_log info "Karabiner 설정을 복사했습니다: $KARABINER_DIR → $TARGET_DIR"

# 5) 완료 메시지
g_log info "Karabiner 설정 복사가 완료되었습니다.
        • Karabiner-Elements가 '$TARGET_DIR/karabiner.json'을 사용합니다.
        • 필요 시 Karabiner-Elements를 다시 로드하세요."

exit 0
