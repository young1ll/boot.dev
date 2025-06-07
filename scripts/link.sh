#!/usr/bin/env bash
set -euo pipefail

# 실제로 심볼릭 링크를 구성하는 대신, 복사 또는 편집하는 방식으로 dotfile 구성
link_dotfiles () {
    exec 1>&2  # stdout을 stderr로 전환: 로그를 stderr로 찍어서, 임시 파일로 통합 캡처됨

    # 유틸리티 로드:
    source "$ROOT_DIR/scripts/utilities/format.sh"
    source "$ROOT_DIR/scripts/utilities/gum.sh"

    # -----------------------------------------------------------------------------
    # 1) .selected_brewfile 확인
    # -----------------------------------------------------------------------------
    if [[ ! -f "$SELECTED_FILE" ]]; then
        g_log error "❌ .selected_brewfile 파일을 찾을 수 없습니다: ${F_DIM}$SELECTED_FILE${NO_FORMAT}"
        exit 1
    fi

    # -----------------------------------------------------------------------------
    # 2) Brewfile 목록에서 tool 이름만 추출
    # -----------------------------------------------------------------------------
    declare -a tools_list=()
    while IFS= read -r brewfile_path; do
        [[ -z "$brewfile_path" || "${brewfile_path:0:1}" == "#" ]] && continue

        if [[ ! -f "$brewfile_path" ]]; then
            g_log warn "${F_DIM}Brewfile 경로가 존재하지 않습니다: $brewfile_path${NO_FORMAT}"
            continue
        fi

        while IFS= read -r line; do
            trimmed="${line#"${line%%[![:space:]]*}"}"
            if [[ "$trimmed" =~ ^(brew|cask)[[:space:]]\"([^\"]+)\" ]]; then
                tools_list+=("${BASH_REMATCH[2]}")
            fi
        done < "$brewfile_path"
    done < "$SELECTED_FILE"

    # -----------------------------------------------------------------------------
    # 3) 중복 제거하여 고유한 도구 목록 생성 (unique_tools)
    # -----------------------------------------------------------------------------
    declare -a unique_tools=()
    while IFS= read -r tool; do
        unique_tools+=("$tool")
        echo $tool
    done < <(printf "%s\n" "${tools_list[@]}" | sort -u)

    # -----------------------------------------------------------------------------
    # 4) ignore 목록 정의 (mas, zsh, zsh-* 은 제외)
    # -----------------------------------------------------------------------------
    declare -a ignore_tools=(
        "mas" "zsh" "zsh-*"
        "font-*"
        "firefox" "google-chrome" "google-drive"
    )

    # -----------------------------------------------------------------------------
    # 5) 각 도구별 apply.sh 실행
    # -----------------------------------------------------------------------------
    for tool in "${unique_tools[@]}"; do
        # (A) ignore_tools 패턴 중 하나와 매칭되면 건너뜀
        skip=false
        for pat in "${ignore_tools[@]}"; do
            if [[ "$tool" == $pat ]]; then
                # "[IGNORE]" 태그가 있는 로그를 찍어 두면 요약에서 갯수를 셀 수 있음
                g_log warn "${F_DIM}[IGNORE] dotfiles/$tool/apply.sh${NO_FORMAT}"
                skip=true
                break
            fi
        done
        $skip && continue

        # (B) dotfiles/<tool>/apply.sh 경로 결정
        tool_apply="$DOTFILES_DIR/$tool/apply.sh"

        # (C) apply.sh 가 실제로 존재하면 실행
        if [[ -f "$tool_apply" ]]; then
            if [[ -x "$tool_apply" ]]; then
                # "[APPLY]" 태그를 찍어서 요약에서 갯수를 셀 수 있음
                g_log info "[APPLY] dotfiles/$tool/apply.sh 적용합니다: ${F_DIM}$tool_apply${NO_FORMAT}"
                source "$tool_apply"
            else
                g_log info "▶ dotfiles/$tool/apply.sh 발견, bash 로 실행: ${F_DIM}$tool_apply${NO_FORMAT}"
                bash "$tool_apply"
            fi
        else
            # "[NOT FOUND]" 태그를 찍어서 요약에서 갯수를 셀 수 있음
            g_log warn "${F_DIM}[NOT FOUND] dotfiles/$tool/apply.sh 를 찾을 수 없습니다: $tool_apply${NO_FORMAT}"
        fi
    done

    # -----------------------------------------------------------------------------
    # 6) 최종 완료 로그 (요약이 아닌, 내부 검사용)
    # -----------------------------------------------------------------------------
    g_log info "[COMPLETE] link_dotfiles 함수 실행 종료"
}

export -f link_dotfiles

run_link () {
    if ! g_confirm "이어서 앞서 설치한 Brewfile의 dotfiles 설정을 진행할까요?"; then
        g_log error "dotfiles 설정이 중단되었습니다."
        return 1
    fi

    local start_ts end_ts elapsed
    start_ts=$(date +%s)

    # 1) 임시 파일 생성
    local TMP_LOG
    TMP_LOG=$(mktemp -t dotfiles_log)

    if gum spin --show-output --title "dotfiles 적용중..." -- bash -c "link_dotfiles > \"${TMP_LOG}\" 2>&1"; then
        g_log info "✅ link_dotfiles가 성공적으로 완료되었습니다. ${F_DIM}${TMP_LOG}${NO_FORMAT}"
    else
        g_log error "❌ link_dotfiles 실행 중 오류가 발생했습니다. 로그 파일을 확인하세요: ${F_DIM}${TMP_LOG}${NO_FORMAT}"
        return 1
    fi

    sed -E 's/\x1B\[[0-9;?]*[A-Za-z]//g' "${TMP_LOG}" > "${TMP_LOG}.clean"
    mv "${TMP_LOG}.clean" "${TMP_LOG}"

    end_ts=$(date +%s)
    elapsed=$(( end_ts - start_ts ))

    # 3) gum spin이 종료된 시점: 이제 TMP_LOG 에 run_link 전체 로그가 들어 있음
    #    여기서 “[APPLY]”, “[IGNORE]”, “[NOT FOUND]” 태그를 기준으로 요약 통계 내기
    local applied_count ignored_count notfound_count
    applied_count=$(awk '/\[APPLY\][[:space:]]/ { count++ } END { print (count ? count : 0) }' "${TMP_LOG}")
    ignored_count=$(awk '/\[IGNORE\][[:space:]]/ { count++ } END { print (count ? count : 0) }' "${TMP_LOG}")
    notfound_count=$(awk '/\[NOT[[:space:]]FOUND\][[:space:]]/ { count++ } END { print (count ? count : 0) }' "${TMP_LOG}")

    # 4) 사용자에게 요약만 출력
    gum style \
        --foreground 210 --border-foreground 210 --border double \
        --align left --width 100 --margin "1 0" --padding "1 2" \
        "================================================================================================" \
        " 🤖 ${F_BOLD}dotfiles 설정 요약${NO_FORMAT}" \
        "================================================================================================" \
        "" \
        "APPLIED:       ${applied_count}" \
        "IGNORED:       ${ignored_count}" \
        "NOT FOUNDED:   ${notfound_count}" \
        "" \
        "LOG FILE:      ${TMP_LOG}" \
        "DURATION:      ${elapsed}초"

    # 5) 임시 파일은 더 이상 필요 없으므로 삭제
    # rm -f "${TMP_LOG}"

    return 0
}
export -f run_link 