#!/usr/bin/env bash
set -euo pipefail

# source "$ROOT_DIR/scripts/utilities/format.sh"
# source "$ROOT_DIR/scripts/utilities/gum.sh"

# -----------------------------------------------------------------------------
# btop 용 dotfile 적용 스크립트
# -----------------------------------------------------------------------------
# 이 스크립트는 다음을 수행합니다:
#  1) ~/.config/btop 디렉토리를 생성
#  2) dotfiles/btop/btop.conf 내용(아래에 정의)을 ~/.config/btop/btop.conf 로 작성
#  3) dotfiles/btop/themes 디렉토리가 있으면, 그 안의 테마 파일들을
#     ~/.config/btop/themes/ 아래로 복사
# -----------------------------------------------------------------------------

# 1) btop 설정 디렉토리 생성
mkdir -p "$HOME/.config/btop/themes"
g_log info "✔ btop 설정 디렉토리를 생성했습니다: ~/.config/btop/themes"

# 2) btop.conf 내용 작성
cat > "$HOME/.config/btop/btop.conf" <<'EOF'
#? btop v. 1.4.3 설정 파일

#* btop++/bpytop/bashtop 형식의 ".theme" 파일 이름, 내장 테마는 "Default" 또는 "TTY"
#* 테마 파일은 바이너리 ../share/btop/themes 또는 "$HOME/.config/btop/themes" 에 위치해야 함
color_theme = "btop-theme.theme"

#* 테마 백그라운드를 표시할지 여부, 터미널 투명도를 사용할 경우 False로 설정
theme_background = True

#* 24비트 TrueColor 사용 여부, False면 256색(6x6x6 16진수 팔레트)으로 대체
truecolor = True

#* TTY 모드를 강제로 사용할지 여부, True로 설정하면 16색 모드와 TTY 테마가 강제 적용됨
force_tty = False

#* 박스 레이아웃 프리셋 정의, 0번 프리셋은 모든 박스를 기본값으로 표시, 최대 9개 프리셋
#* 형식: "box_name:P:G,box_name:P:G"  P=(0 또는 1) 대체 위치, G=그래프 심볼
#* 여러 프리셋은 공백으로 구분
#* 예시: "cpu:0:default,mem:0:tty,proc:1:default cpu:0:braille,proc:0:tty"
presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty"

#* 목록 내에서 방향키 대신 "h,j,k,l,g,G" 키 사용 여부(Shift+키로 충돌 해제)
vim_keys = True

#* 박스 모서리를 둥글게 표시할지 여부 (TTY 모드에서는 무시됨)
rounded_corners = True

#* 그래프 생성에 사용할 기본 심볼, "braille", "block" 또는 "tty"
graph_symbol = "braille"

#* CPU 박스 그래프에 사용할 심볼, "default", "braille", "block" 또는 "tty"
graph_symbol_cpu = "default"

#* 메모리 박스 그래프에 사용할 심볼, "default", "braille", "block" 또는 "tty"
graph_symbol_mem = "default"

#* 네트워크 박스 그래프에 사용할 심볼, "default", "braille", "block" 또는 "tty"
graph_symbol_net = "default"

#* 프로세스 박스 그래프에 사용할 심볼, "default", "braille", "block" 또는 "tty"
graph_symbol_proc = "default"

#* 표시할 박스 수동 설정. 사용 가능한 값: "cpu mem net proc" 및 "gpu0"~"gpu5"
shown_boxes = "cpu mem net proc"

#* 업데이트 주기(밀리초), 2000ms 이상 권장
update_ms = 2000

#* 프로세스 정렬 기준, "pid", "program", "arguments", "threads", "user", "memory", 
#* "cpu lazy", "cpu direct" 중 선택
proc_sorting = "cpu lazy"

#* 정렬 순서 반전 여부 (True/False)
proc_reversed = False

#* 트리 형태로 프로세스를 표시할지 여부
proc_tree = False

#* CPU 그래프 색상을 프로세스 목록에 적용할지 여부
proc_colors = True

#* 프로세스 목록에서 색상 그라데이션 사용 여부
proc_gradient = True

#* 프로세스 CPU 사용량을 해당 코어 기준으로 할지 전체 CPU 대비할지 여부
proc_per_core = False

#* 프로세스 메모리를 백분율 대신 바이트로 표시할지 여부
proc_mem_bytes = True

#* 프로세스 목록에 CPU 그래프 표시 여부
proc_cpu_graphs = True

#* 프로세스 정보 박스에 /proc/[pid]/smaps 사용 여부(정확하지만 느림)
proc_info_smaps = False

#* 프로세스 박스를 화면 왼쪽에 표시할지 여부
proc_left = False

#* (Linux) Linux 커널에 관련된 프로세스 필터링 여부 (htop과 유사)
proc_filter_kernel = False

#* 트리 뷰에서 자식 프로세스 자원을 부모에 누적할지 여부
proc_aggregate = False

#* CPU 그래프 상단에 표시할 통계, 기본값 "total"
cpu_graph_upper = "Auto"

#* CPU 그래프 하단에 표시할 통계, 기본값 "total"
cpu_graph_lower = "Auto"

#* 하단 CPU 그래프가 반전되어야 하는지 여부
cpu_invert_lower = True

#* 하단 CPU 그래프 완전 비활성화 여부
cpu_single_graph = False

#* CPU 박스를 화면 하단에 표시할지 여부
cpu_bottom = False

#* CPU 박스에 시스템 업타임 표시 여부
show_uptime = True

#* CPU 온도 표시 여부
check_temp = True

#* CPU 온도 센서 선택, "Auto" 또는 센서 이름
cpu_sensor = "Auto"

#* coretemp 사용 여부 (True/False)
show_coretemp = True

#* CPU 온도 매핑 수동 설정, "x:y" 형식, 공백으로 여러 개 구분
cpu_core_map = ""

#* 온도 단위, "celsius", "fahrenheit", "kelvin", "rankine" 중 선택
temp_scale = "celsius"

#* 단위 10진수 사용 여부, 기본값 False(이진수)
base_10_sizes = False

#* CPU 주파수 표시 여부
show_cpu_freq = True

#* 상단에 시계 표시 여부, strftime 형식 사용, 빈 문자열이면 비활성화
clock_format = "/user"

#* 메뉴 표시 중 백그라운드 업데이트 여부, 깜박임이 심하면 False 설정
background_update = True

#* 사용자 지정 CPU 모델 이름, 빈 문자열이면 비활성화
custom_cpu_name = ""

#* 디스크 표시 필터, 마운트포인트 경로 나열, 공백으로 구분
disks_filter = ""

#* 메모리 박스에서 그래프 대신 막대기로 표시 여부
mem_graphs = True

#* 메모리 박스를 네트워크 박스 아래에 표시 여부
mem_below_net = False

#* ZFS ARC 메모리 카운트 여부 (True/False)
zfs_arc_cached = True

#* 스왑 메모리 표시 여부
show_swap = True

#* 스왑을 디스크로 표시할지 여부
swap_disk = True

#* 디스크 정보 분할 표시 여부
show_disks = True

#* 물리 디스크만 표시할지 여부 (False면 네트워크/RAM 디스크 포함)
only_physical = True

#* /etc/fstab 사용 여부, True면 only_physical 비활성화
use_fstab = True

#* ZFS 풀만 표시할지 여부 (True/False)
zfs_hide_datasets = False

#* 특권 사용자에게 디스크 여유 공간 표시 여부 (True/False)
disk_free_priv = False

#* I/O 활동 % 표시 여부 (True/False)
show_io_stat = True

#* I/O 모드 활성화 여부, 활성화 시 디스크 읽기/쓰기 그래프 표시
io_mode = False

#* I/O 모드 결합 그래프 표시 여부
io_graph_combined = False

#* I/O 그래프 최대 속도 설정(MiB/s), "mountpoint:speed" 형식, 공백으로 구분
io_graph_speeds = ""

#* 네트워크 그래프 값 고정(Mebibits), net_auto=False 인 경우에만 사용
net_download = 100
net_upload = 100

#* 네트워크 그래프 자동 스케일 여부, False면 수동 값 사용
net_auto = True

#* 다운로드/업로드 스케일 동기화 여부
net_sync = True

#* 시작할 네트워크 인터페이스 지정
net_iface = ""

#* 비트 전송률 단위 설정, "Auto", "True"(10진수), "False"(이진수)
base_10_bitrate = "Auto"

#* 배터리 통계 표시 여부 (True/False)
show_battery = True

#* 사용할 배터리 선택 (예: "Auto" 또는 센서 이름)
selected_battery = "Auto"

#* 배터리 전력 통계 표시 여부 (True/False)
show_battery_watts = True

#* 로그 레벨 설정, "~/.config/btop/btop.log"에 적용: "ERROR" "WARNING" "INFO" "DEBUG"
log_level = "WARNING"
EOF

g_log info "[COMPLETED] ~/.config/btop/btop.conf 파일을 생성했습니다."

# 3) dotfiles/btop/themes 디렉토리에서 테마 복사
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_THEMES_DIR="$SCRIPT_DIR/themes"
TARGET_THEMES_DIR="$HOME/.config/btop/themes"

if [[ -d "$SOURCE_THEMES_DIR" ]]; then
  cp -v "$SOURCE_THEMES_DIR"/*.theme "$TARGET_THEMES_DIR"/ 2>/dev/null || true
  g_log info "✔ 테마 파일을 ~/.config/btop/themes/ 에 복사했습니다."
else
  g_log warn "[NOT FOUND] botop 테마 디렉토리가 없습니다: ${F_DIM}$SOURCE_THEMES_DIR (복사 생략)${NO_FORMAT}"
fi

g_log info "[COMPLETED] btop 설정 적용 완료!"
