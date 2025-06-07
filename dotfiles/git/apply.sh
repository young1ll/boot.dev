#!/usr/bin/env bash
set -euo pipefail

# 유틸리티 로드
source "$ROOT_DIR/scripts/utilities/format.sh"
source "$ROOT_DIR/scripts/utilities/gum.sh"

ENV_FILE="$ROOT_DIR/.env"

# 2) .env 로드 (없으면 경고 후 진행) ----------------------------------------- #
if [[ -f "$ENV_FILE" ]]; then
  # export 모드: .env에서 정의된 변수를 곧바로 export
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
  g_log info ".env 로드 완료: $ENV_FILE"
else
  g_log warn ".env 파일을 찾을 수 없습니다: $ENV_FILE" >&2
fi

g_log info ".env의 GITCONFIG_* 환경변수 기반으로 git 전역 설정을 적용합니다..."
# GITCONFIG_<SECTION>_<KEY> → <section>.<key> 형태로 매핑

while IFS= read -r var; do
   # 좌변(name)과 우변(value) 분리
  var_name="${var%%=*}"    # ex. GITCONFIG_CO
  var_value="${var#*=}"    # ex. checkout

  # "GITCONFIG_" 접두사 제거 → "CO"
  stripped="${var_name#GITCONFIG_}"

  # 모두 소문자로 바꾸고, 언더스코어(_)를 점(.)으로 변환
  # "USER_NAME" → "user_name" → "user.name"
  alias_key=$(echo "$stripped" | tr '[:upper:]' '[:lower:]' | tr '_' '.')

  # git config --global alias.co checkout
  git config --global "$alias_key" "$var_value"
  g_log info "git config --global $alias_key '$var_value'"
done < <(grep -E '^\s*GITCONFIG_[A-Z0-9_]+\s*=' "$ENV_FILE" || true)

g_log info "Git 전역 설정이 모두 적용되었습니다."

return