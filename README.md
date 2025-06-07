<div align="center">
    <h1>Boot.dev</h1>
    <p>쉽고 빠른 dotfiles 초기 설정 헬퍼</p>
    <p>Effortless MacOS Bootstrapping, from zero to ready.</p>
</div>

- 머신의 dotfiles 초기화 설정을 지원합니다.
- `chezmoi`, `mackup`, `yadm` 같은 dotfiles manager를 사용해본 적이 없거나, 미숙한 경우 `Boot.dev`가 도움이 될 수 있습니다.
- `Boot.dev`는 콘솔용 텍스트 에디터로 `neovim`(`nvim`)을 사용합니다.
- `Boot.dev`는 머신의 초기 설정에만 사용해주세요. 초기 설정 이후의 dotfiles 관리는 함께 설치된  `chezmoi`를 사용을 권장합니다.
- `Boot.dev`는 주로 `zsh` 설정에 집중합니다(`run_zsh`). 초기화 완료 이후, 개별 패키지에 대한 커스터마이징을 별도로 진행하는 것을 권장합니다.
- `Boot.dev`는 실제로 `dotfiles`의 심볼링 링크를 구성하는 대신 brew에서 초기화된 초기 설정에 `Boot.dev`의 사전 구성을 복사 또는 편집하는 방식으로 초기 설정을 구성합니다(`run_link`). 설정으로 마치고 `Boot.dev`를 **제거해도 좋습니다.**

## References

- [chezmoi Quick start](https://www.chezmoi.io/quick-start/#start-using-chezmoi-on-your-current-machine)
- [chezmoi, 세상 편리하게 dotfile 관리하기](https://haril.dev/blog/2023/03/26/chezmoi-awesome-dotfile-manager)

## Getting Started

### MacOS

```bash
$ git clone https://github.com/young1ll/boot.dev.git
$ cd boot.dev
$ ./run.sh
```
