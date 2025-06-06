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


# BOOTWIZARD 그라데이션 라인 ------------------------------------------------- #
gradient_line() {
    local sr=$1; local sg=$2; local sb=$3
    local er=$4; local eg=$5; local eb=$6
    local line="$7"

    local len=${#line}
    (( len <= 1 )) && len=1  # 만약 한 글자이거나 빈 문자열이면 분모가 0이 되는 걸 방지

    for ((i=0; i<len; i++)); do
        # t = i / (len - 1)
        local t_num=$i
        local t_den=$(( len - 1 ))

        # 보간 계산: R = sr*(1-t) + er*t 식으로
        # 즉, sr*(t_den - t_num)/t_den + er*(t_num)/t_den
        local r=$(( ( sr * (t_den - t_num) + er * t_num ) / t_den ))
        local g=$(( ( sg * (t_den - t_num) + eg * t_num ) / t_den ))
        local b=$(( ( sb * (t_den - t_num) + eb * t_num ) / t_den ))

        # ANSI TrueColor 포맷: \033[38;2;R;G;Bm
        printf '\033[38;2;%d;%d;%dm%s' "$r" "$g" "$b" "${line:i:1}"
    done

    # 컬러 리셋(Reset)
    printf "$NO_FORMAT"
}

# BOOTWIZARD 그라데이션 텍스트 ----------------------------------------------- #
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
