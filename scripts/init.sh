#!/usr/bin/env bash
set -euo pipefail

info()  { printf '%s %b[INFO]%b %b%b[BOOTWIZARD]%b %s\n' "$(date '+%d %b %y %H:%M %Z')" "$C_DARKOLIVEGREEN3" "$NO_FORMAT" "$F_DIM" "$C_GREY70" "$NO_FORMAT" "$1"; }
warn()  { printf '%s %b[WARN]%b %b%b[BOOTWIZARD]%b %s\n' "$(date '+%d %b %y %H:%M %Z')" "$C_LIGHTGOLDENROD2" "$NO_FORMAT" "$F_DIM" "$C_GREY70" "$NO_FORMAT" "$1"; }
error() { printf '%s %b[ERROR]%b %b%b[BOOTWIZARD]%b %s\n' "$(date '+%d %b %y %H:%M %Z')" "$C_RED" "$NO_FORMAT" "$F_DIM" "$C_GREY70" "$NO_FORMAT" "$1"; }

install_xcodecli() {
  echo
  info "[Xcode Command Line Tools]"; sleep 0.5

  # macOS일 때만 동작
  if [[ "$(uname)" == "Darwin" ]]; then
    # xcode-select -p가 성공하면 이미 설치된 상태
    if xcode-select -p >/dev/null 2>&1; then
      info "- Xcode Command Line Tools가 이미 설치되어 있습니다."
    else
      info "🔄 Xcode Command Line Tools를 설치합니다..."
      # 설치 명령 실행 (대화형 팝업이 뜹니다)
      xcode-select --install 2>&1

      # 설치가 완료될 때까지 대기
      until xcode-select -p >/dev/null 2>&1; do
        sleep 5
      done

      info "- Xcode Command Line Tools 설치가 완료되었습니다."
    fi
  fi
}

install_homebrew() {
  echo
  info "[Homebrew]"; sleep 0.5

  if ! command -v brew >/dev/null 2>&1; then
    info "🔄 Homebrew가 설치되어 있지 않습니다. 설치를 시작합니다."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # 설치 후 셸 환경에 brew 경로를 추가 (macOS 기본 경로 기준)
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile" 2>/dev/null || true
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x "/usr/local/bin/brew" ]]; then
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile" 2>/dev/null || true
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    info "- Homebrew 설치가 완료되었습니다."
  else
    info "- Homebrew 설치가 확인되었습니다: ${F_BOLD}$(brew --version | head -n1)${NO_FORMAT}"
  fi
}

install_zsh() {
  echo
  info "[zsh]"; sleep 0.5

  if ! command -v zsh >/dev/null 2>&1; then
    info "🔄 zsh가 설치되어 있지 않습니다. Homebrew를 통해 설치합니다..."
    brew install zsh
    info "- zsh 설치가 완료되었습니다: $(zsh --version)"
  else
    info "- zsh 설치 확인됨: $(zsh --version)"
  fi

  local current_shell_basename
  current_shell_basename="$(basename "$SHELL")"
  if [[ "$current_shell_basename" == "zsh" ]]; then
    info "- ${F_BOLD}현재 로그인 셸이 이미 zsh입니다: $SHELL${NO_FORMAT}"
    return
  fi

  local new_zsh_path
  new_zsh_path="$(which zsh)"

  if ! grep -Fxq "$new_zsh_path" /etc/shells; then
    info "🔄 $new_zsh_path 가 /etc/shells에 등록되어 있지 않습니다. 등록을 시도합니다..."
    if sudo sh -c "printf '%s\n' '$new_zsh_path' >> /etc/shells"; then
      info "- /etc/shells에 '$new_zsh_path' 등록 완료"
    else
      warn "- /etc/shells 쓰기 실패. 수동으로 셸 변경이 필요합니다."
      return
    fi
  else
    info "- $new_zsh_path 가 이미 /etc/shells에 등록되어 있습니다."
  fi

  info "🔄 로그인 셸을 '$new_zsh_path'(zsh)로 변경합니다..."
  if chsh -s "$new_zsh_path"; then
    info "- 로그인 셸이 zsh($new_zsh_path)로 변경되었습니다. (재로그인 필요)"
  else
    warn "- chsh 명령에 실패했습니다. 관리자 권한으로 직접 시도해주세요."
    warn "- 예시: sudo chsh -s $new_zsh_path \"\$(whoami)\""
  fi
}

install_git() {
  echo
  info "[git]"; sleep 0.5

  if ! command -v git >/dev/null 2>&1; then
    info "🔄 git이 설치되어 있지 않습니다. Homebrew를 통해 설치합니다..."
    brew install git
    info "- git 설치가 완료되었습니다."
  else
    info "- git 설치 확인됨: $(git --version)"
  fi
}


install_gum() {
  echo
  info "[gum]"; sleep 0.5

  if ! command -v gum >/dev/null 2>&1; then
    info "🔄 gum이 설치되어 있지 않습니다. Homebrew를 통해 설치합니다."
    brew install gum
    info "- gum 설치 완료"
  else
    info "- gum 설치 확인: $(gum --version)"
  fi
}

init_environment() {
  sleep 1

  # 1) macOS 여부 확인
  if [[ "$(uname)" != "Darwin" ]]; then
    warn "이 스크립트는 macOS 전용으로 작성되었습니다. 일부 기능이 작동하지 않을 수 있습니다."
  else
    info "${F_BOLD}OS: macOS(Darwin) 확인${NO_FORMAT}"
  fi

  # 2) dotfiles, brewfiles 경로 존재 여부 확인
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    warn "Dotfiles 경로를 찾을 수 없습니다: ${F_DIM}$DOTFILES_DIR${NO_FORMAT}"
  else
    info "Dotfiles 경로 확인: ${F_DIM}$DOTFILES_DIR${NO_FORMAT}"
  fi

  if [[ ! -d "$BREWFILES_DIR" ]]; then
    warn "Brewfiles 경로를 찾을 수 없습니다: ${F_DIM}$BREWFILES_DIR${NO_FORMAT}"
  else
    info "Brewfiles 경로 확인: ${F_DIM}$BREWFILES_DIR${NO_FORMAT}"
  fi
  sleep 0.5

  # 3) (선택) 로그·백업용 경로 생성
  local backup_dir="$ROOT_DIR/backups"
  if [[ ! -d "$backup_dir" ]]; then
    mkdir -p "$backup_dir"
    info "백업 경로 생성: ${F_DIM}$backup_dir${NO_FORMAT}"
  else
    info "백업 경로 확인: ${F_DIM}$backup_dir${NO_FORMAT}"
  fi
  sleep 0.5

  install_xcodecli
  install_homebrew
  install_zsh
  install_gum

  echo
  info "🎉 초기화 및 의존성 설치가 모두 완료되었습니다."
  echo
  echo -e "${C_GREY0}======================================================================================================"
  echo -e "======================================================================================================${NO_FORMAT}"
  echo
}