#!/usr/bin/env bash

# FORMATS -------------------------------------------------------------------- #
NO_FORMAT=$'\033[0m'
F_BOLD=$'\033[1m'
F_UNDERLINED=$'\033[4m'
F_INVERT=$'\033[7m'
F_DIM=$'\033[2m'

# COLORS --------------------------------------------------------------------- #
C_WHITE=$'\033[38;5;15m'
C_GREY=$'\033[38;5;8m'
C_GREY0=$'\033[38;5;16m'
C_GREY27=$'\033[38;5;238m'
C_GREY35=$'\033[38;5;240m'
C_GREY50=$'\033[38;5;244m'
C_GREY70=$'\033[38;5;249m'




C_GOLD1=$'\033[38;5;220m'
C_LIGHTGOLDENROD2=$'\033[38;5;221m'


# C_INDIANRED1=$'\033[38;5;203m'
C_INDIANRED1=$'\033[38;5;204m'
C_PALEVIOLETRED1=$'\033[38;5;211m'
C_LIGHTCORAL=$'\033[38;5;210m'

C_CORNFLOWERBLUE=$'\033[38;5;69m'
C_DODGERBLUE1=$'\033[38;5;33m'
C_SKYBLUE1=$'\033[38;5;117m'

C_DARKOLIVEGREEN3=$'\033[38;5;149m'

# TrueColor 지원 여부 확인
supports_truecolor() {
  [[ "${COLORTERM:-}" == *truecolor* || "${TERM:-}" == *truecolor* || "${TERM_PROGRAM:-}" == "iTerm.app" ]]
}

# 24bit → 256색 변환 (단순 매핑)
rgb_to_ansi256() {
  local r=$1 g=$2 b=$3

  if ((r == g && g == b)); then
    # 회색 계열 (색상 간단화)
    if ((r < 8)); then echo 16
    elif ((r > 248)); then echo 231
    else echo $((232 + ((r - 8) * 24 / 247)))
    fi
  else
    # 6x6x6 색상 cube
    echo $((16 + (36 * (r * 5 / 255)) + (6 * (g * 5 / 255)) + (b * 5 / 255)))
  fi
}

# 색상 그라데이션 라인 출력
gradient_line() {
  local sr=$1 sg=$2 sb=$3
  local er=$4 eg=$5 eb=$6
  local line="$7"
  local len=${#line}
  (( len <= 1 )) && len=1

  local use_truecolor=false
  if supports_truecolor; then
    use_truecolor=true
  fi

  for ((i=0; i<len; i++)); do
    local t_num=$i
    local t_den=$(( len - 1 ))

    local r=$(( ( sr * (t_den - t_num) + er * t_num ) / t_den ))
    local g=$(( ( sg * (t_den - t_num) + eg * t_num ) / t_den ))
    local b=$(( ( sb * (t_den - t_num) + eb * t_num ) / t_den ))

    local ch="${line:i:1}"

    if $use_truecolor; then
      printf '\033[38;2;%d;%d;%dm%s' "$r" "$g" "$b" "$ch"
    else
      local code
      code=$(rgb_to_ansi256 "$r" "$g" "$b")
      printf '\033[38;5;%dm%s' "$code" "$ch"
    fi
  done

  printf "$NO_FORMAT"
}

# 그라데이션 텍스트 ----------------------------------------------- #
gradient_text() {
    local sr=255 sg=111 sb=97
    local er=136 eg=216 eb=176 #255
    # local line="$1"
    # local sr=$1; local sg=$2; local sb=$3
    # local er=$4; local eg=$5; local eb=$6
    # shift 6

    # 남은 인자는 "여러 줄"로 취급
    local line
    for line in "$@"; do
        gradient_line "$sr" "$sg" "$sb" "$er" "$eg" "$eb" "$line"
        printf '\n'
    done
}
