#!/usr/bin/env bash
set -euo pipefail

# 유틸리티 로드 (g_log, g_warn, g_error 등)
source "$ROOT_DIR/scripts/utilities/format.sh"
source "$ROOT_DIR/scripts/utilities/gum.sh"

g_log info "▶ fzf 설치 및 설정을 시작합니다..."