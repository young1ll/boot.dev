#!/usr/bin/env bash
set -euo pipefail

run_reset() {
  echo "────────────────────────────────────────────────────────────────────"
  echo "⚠️  이 스크립트는 macOS 환경을 초기 개발 상태로 되돌립니다."
  echo "   - Homebrew 패키지 및 Cask 삭제"
  echo "   - Homebrew 자체 삭제"
  echo "   - Homebrew 캐시, 로그, 설정 디렉터리 삭제"
  echo "   - ~/.zshrc, ~/.zprofile 등 쉘 설정 파일 백업 후 기본 상태로 복원"
  echo "   - 추가로 원한다면 기타 dotfiles나 개발 설정을 수동으로 정리하십시오."
  echo "────────────────────────────────────────────────────────────────────"
  read -r -p "계속 실행하시겠습니까? (y/N): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "❌ 취소되었습니다."
    exit 1
  fi

  # -----------------------------------------------------------------------------
  # 2) Homebrew 패키지 및 Cask 제거
  # -----------------------------------------------------------------------------
  if command -v brew &>/dev/null; then
    echo "[STEP 2] Homebrew로 설치된 모든 패키지 및 Cask를 삭제합니다..."

    # 2-1) 설치된 모든 포뮬러(Formula) 목록을 가져와서 순차 삭제
    echo "  • 설치된 Formula 목록을 가져오는 중..."
    formulae=$(brew list --formula || true)
    if [[ -n "$formulae" ]]; then
      echo "  • 아래 Formula를 삭제합니다:"
      echo "$formulae" | sed 's/^/    - /'
      brew uninstall --force $formulae || true
    else
      echo "  • 설치된 Formula가 없습니다."
    fi

    # 2-2) 설치된 모든 Cask 목록을 가져와서 순차 삭제
    echo "  • 설치된 Cask 목록을 가져오는 중..."
    casks=$(brew list --cask || true)
    if [[ -n "$casks" ]]; then
      echo "  • 아래 Cask를 삭제합니다:"
      echo "$casks" | sed 's/^/    - /'
      brew uninstall --cask --force $casks || true
    else
      echo "  • 설치된 Cask가 없습니다."
    fi

    # 2-3) 남은 의존성/캐시 정리
    echo "  • 남은 의존성 및 캐시를 정리합니다..."
    brew cleanup --prune=all || true
    echo "✅ Homebrew 패키지 및 Cask 제거 완료"
  else
    echo "[STEP 2] Homebrew가 설치되어 있지 않습니다. 건너뜁니다."
  fi

  # -----------------------------------------------------------------------------
  # 3) Homebrew 자체 삭제 및 잔여 디렉터리 제거
  # -----------------------------------------------------------------------------
  echo "[STEP 3] Homebrew 자체를 삭제하고 잔여 디렉터리를 정리합니다..."

  # Apple Silicon vs Intel 경로 자동 감지
  if [[ -d "/opt/homebrew" ]]; then
    BREW_PREFIX="/opt/homebrew"
  elif [[ -d "/usr/local/Homebrew" ]]; then
    BREW_PREFIX="/usr/local/Homebrew"
  else
    # 사용자가 기본 brew uninstall 스크립트를 쓰도록 안내
    BREW_PREFIX=""
  fi

  if [[ -n "$BREW_PREFIX" ]]; then
    echo "  • $BREW_PREFIX 경로에서 Homebrew를 삭제합니다..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" </dev/null || true
    # uninstall.sh 스크립트는 정상적으로 경로를 감지해 제거하므로 추가 작업은 보통 필요 없습니다.
  else
    echo "  • Homebrew 설치 경로를 찾을 수 없습니다."
    echo "    (Intel: /usr/local/Homebrew, Apple Silicon: /opt/homebrew)"
    echo "    수동으로 제거하려면 해당 경로를 삭제하십시오."
  fi

  # 3-1) 남은 캐시 및 로그 디렉터리 강제 삭제
  echo "  • 남은 캐시 및 로그, 설정 디렉터리를 삭제합니다..."
  rm -rf /Library/Caches/Homebrew        || true
  rm -rf ~/Library/Caches/Homebrew       || true
  rm -rf ~/Library/Logs/Homebrew         || true
  rm -rf ~/.brewconfig                   || true
  rm -rf ~/.brew                 || true
  rm -rf "$HOME/.cache/Homebrew"         || true
  echo "✅ Homebrew 및 관련 디렉터리 삭제 완료"

  # -----------------------------------------------------------------------------
  # 4) 쉘 설정 파일 백업 및 기본 상태로 되돌리기
  # -----------------------------------------------------------------------------
  echo "[STEP 4] ~/.zshrc, ~/.zprofile, ~/.zshenv 등을 백업하고 초기 상태로 되돌립니다..."

  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  BACKUP_DIR="$HOME/reset_backup_$TIMESTAMP"
  mkdir -p "$BACKUP_DIR"

  # 4-1) 백업 대상 파일 목록
  dotfiles=(\
    "$HOME/.zshrc" \
    "$HOME/.zprofile" \
    "$HOME/.zshenv" \
    "$HOME/.bash_profile" \
    "$HOME/.bashrc" \
  )

  for file in "${dotfiles[@]}"; do
    if [[ -f "$file" ]]; then
      echo "  • 백업: $file → $BACKUP_DIR/"
      mv "$file" "$BACKUP_DIR/" || true
    fi
  done

  # 4-2) 기본 상태로 사용할 최소한의 빈 .zshrc 생성
  echo "  • 기본 .zshrc 파일을 생성합니다."
  cat << 'EOF' > "$HOME/.zshrc"
# ~/.zshrc - 초기화된 기본 상태
export ZSH="$HOME/.oh-my-zsh"    # 혹은 기본 테마 사용 시 이 줄을 지울 수 있습니다.
ZSH_THEME="robbyrussell"         # 난 원하는 경우 변경

# 기본 플러그인 예시 (필요 시 수정)
plugins=(git)

# 사용자 필요 시 PATH 또는 기타 설정을 추가
# export PATH="/usr/local/bin:$PATH"

source $ZSH/oh-my-zsh.sh
EOF

  echo "✅ 쉘 설정 파일 초기화 완료. 원본 파일은 $BACKUP_DIR 에 백업되었습니다."

  # -----------------------------------------------------------------------------
  # 5) 추가적으로 원한다면 개발 디렉터리 정리
  # -----------------------------------------------------------------------------
  echo "[STEP 5] 홈 디렉토리 내 모든 dotfiles르 백업하고 제거합니다..."
  mkdir -p "$BACKUP_DIR"/all_dotfiles

  # 숨김 파일만 골라서, 백업 후 삭제
  shopt -s dotglob
  for f in "$HOME"/.*; do
    base=$(basename "$f")
    if [[ "$base" == "." || "$base" == ".." ]]; then 
      continue
    fi

    if [[ "$f" == "BACKUP_DIR"* ]]; then
      continue
    fi

    echo " - 백업 및 삭제: $f -> $BACKUP_DIR/all_dotfiles/"
    mv "$f" "$BACKUP_DIR/all_dotfiles/" || true
  done

  shopt -u dotglob
  echo "~ 경로의 모든 dotfiles 백업 및 제거 완료"

  echo "[STEP 6] ~/Projects, ~/workspace 등 개발 디렉터리를 정리하려면 수동으로 수행하십시오."
  echo "   예: rm -rf ~/Projects/*"

  # -----------------------------------------------------------------------------
  # 6) 리부팅 안내
  # -----------------------------------------------------------------------------
  echo "────────────────────────────────────────────────────────────────────"
  echo "✅ Mac 초기화(개발 환경 리셋)가 완료되었습니다."
  echo "  • 백업된 dotfiles: $BACKUP_DIR"
  echo "  • 남은 개발 디렉터리 등은 수동으로 정리하십시오."
  echo "  • 시스템 변경 사항을 완전히 적용하려면 Mac을 재시동하는 것을 권장합니다."
  echo "    (예: sudo shutdown -r now)"
  echo "────────────────────────────────────────────────────────────────────"

  exit 1
}
