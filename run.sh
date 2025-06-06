#!/usr/bin/env bash
set -euo pipefail

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SELECTED_FILE="$ROOT_DIR/.selected_brewfile"
readonly DOTFILES_DIR="$ROOT_DIR/dotfiles"
readonly BREWFILES_DIR="$ROOT_DIR/brewfiles"
readonly SCRIPTS_DIR="$ROOT_DIR/scripts"

export ROOT_DIR
export SELECTED_FILE
export DOTFILES_DIR
export BREWFILES_DIR
export SCRIPTS_DIR

import_module() {
  local file_path="$1"
  if [[ -f "$file_path" ]]; then
    # source 시점에서 이미 export된 환경변수를 하위 스크립트가 쓸 수 있음
    source "$file_path"
  else
    printf "\033[1;31m[ERROR]\033[0m Module not found: %s\n" "$file_path" >&2
    exit 1
  fi
}

import_module "$SCRIPTS_DIR/utilities/banner.sh"
import_module "$SCRIPTS_DIR/utilities/format.sh"
import_module "$SCRIPTS_DIR/utilities/gum.sh"

import_module "$SCRIPTS_DIR/init.sh"
import_module "$SCRIPTS_DIR/brew.sh"
import_module "$SCRIPTS_DIR/zshrc.sh"
import_module "$SCRIPTS_DIR/link.sh"
import_module "$SCRIPTS_DIR/sdk-man.sh"
import_module "$SCRIPTS_DIR/clean-up.sh"
import_module "$SCRIPTS_DIR/reset.sh"

main() {
  print_banner_onboarding # 온보딩 배너
  init_environment # 환경 설정 및 초기화

  # --------------------------------------------------------------------------- #
  local selections
  selections=$(gum choose --header="" \
    "1. Boot.dev 실행" \
    "2. 머신 재설정")

  # 선택된 항목이 없으면 종료
  if [[ -z "$selections" ]]; then
    echo "[WARN] 선택된 작업이 없습니다. 스크립트를 종료합니다."
    exit 0
  fi

  if [[ "$selections" == *"재설정"*  ]]; then
    run_reset # 머신 재설정
  fi
  # --------------------------------------------------------------------------- #

  run_brew
  run_zshrc
  run_link
  run_sdkman

  clean_up
  print_banner_offboarding
}

main "$@"