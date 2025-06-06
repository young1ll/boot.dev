# description:  데이터 분석/AI 개발 전용 패키지: asdf 기반

# Default -------------------------------------------------------------------- #
brew "mas"
cask "xcodes"
brew "cowsay" # Moo!
brew "chezmoi" # dotfiles manager

brew "asdf" # 다중 언어 관리자 | https://asdf-vm.com/ko-kr/guide/getting-started.html
brew "gpg" # GNU Privacy Guard
brew "gawk" # GNU awk (텍스트 처리) | asdf 의존성

brew python
brew pyenv

brew "zsh" # setup.sh에서 설치
brew "zsh-autosuggestions" # Zsh에  자동 완성 기능 추가
brew "zsh-completions" # Zsh에  완성 기능 추가
brew "zsh-syntax-highlighting" # Zsh  구문 강조 기능 추가
brew "chroma" # Zsh  Colorize

# Data Science --------------------------------------------------------------- #
# brew "jupyterlab" # Jupyter Notebook/Lab 환경:contentReference[oaicite:22]{index=22} -> asdf python에서 관리

# Utils ---------------------------------------------------------------------- #
brew "tree" # 디렉터리 구조를 트리 형태로 표시

brew "bat" # cat 대체 https://github.com/sharkdp/bat
brew "zoxide" # cd 대체 https://github.com/ajeetdsouza/zoxide
brew "eza" # ls 대체 https://github.com/eza-community/eza
brew "fzf" # go 기반 | 퍼지(fuzzy) 검색 도구
# brew "fd" # rust 기반 | find 대체 https://github.com/sharkdp/fd

brew "jq" # JSON 처리 도구
brew "hdf5" # 대용량 데이터 포맷
brew 'pandoc' # Document format converter

brew "mkcert" # local SSL certificate
brew "openssl" # SSL certificate

cask dash # API Doc Browser + 코드 스니펫 관리자 (15유로)

# Monitoring ----------------------------------------------------------------- #
brew "btop" # cpp 기반 프로세스 모니터링 https://github.com/aristocratos/btop
brew "gotop" # go 기반 디스크 I/O 모니터링
brew "glances" # python 기반 종합 시스템 모니터링 | 원격 모니터링
cask "sloth" # 프로세스/파일 잠금 모니터링 (GUI) | https://sveinbjorn.org/sloth

brew "ncdu" # 디스크 사용량 분석
brew "fastfetch" # 시스템 정보 디스플레이
brew "httrack" # 웹사이트 복사

# Git & Github --------------------------------------------------------------- #
brew "git" # 분산 버전 관리 시스템:contentReference[oaicite:8]{index=8}
brew "act" # Github Actions 로컬 실행기 | https://github.com/nektos/act

brew "gh" # Github CLI Tool
brew "commitizen" # 커밋 헬퍼 | https://github.com/commitizen-tools/commitizen

# IDE ------------------------------------------------------------------------ #
cask "visual-studio-code", args: { appdir: "~/Applications" }
cask "rstudio" # RStudio (R 환경)
brew "neovim"

# Terminal ------------------------------------------------------------------- #
cask "iterm2" # CPU 기반 터미널
cask "kitty" # GPU 기반 터미널(OpenGL)
brew "tmux" # 터미널 멀티플렉서