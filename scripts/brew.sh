#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# select_brewfiles: 사용자에게 Brewfile 목록을 보여주고,
# 선택 결과를 SELECTED_PATHS 배열에 저장한 뒤, 
# 이를 문자열(줄바꿈 구분)로 직렬화하여 SELECTED_PATHS_STR에 담음
# ------------------------------------------------------------
select_brewfiles() {
    # 유틸리티 로드
    source "$ROOT_DIR/scripts/utilities/format.sh"
    source "$ROOT_DIR/scripts/utilities/gum.sh"

    g_log info "📦 설치 가능한 Brewfile 목록을 불러옵니다..."

    # (1) BREWFILES_DIR 내 *.Brewfile 파일 목록 수집
    local brewfiles_list=()
    for f in "$BREWFILES_DIR"/*.Brewfile; do
        [[ -f "$f" ]] && brewfiles_list+=("$f")
    done

    if [[ ${#brewfiles_list[@]} -eq 0 ]]; then
        g_log error "설치 가능한 Brewfile을 찾을 수 없습니다: ${F_DIM}$BREWFILES_DIR/*.Brewfile${NO_FORMAT}"
        return 1
    fi

    # (2) display_list와 keys_list(=basename 목록) 구성
    local -a display_list=() keys_list=()
    for idx in "${!brewfiles_list[@]}"; do
        local file_path="${brewfiles_list[$idx]}"
        local base_name="$(basename "$file_path" .Brewfile)"

        # 상위 10줄에서 "Description:" 추출
        local description="(설명 없음)"
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*#[[:space:]]*[dD]escription:[[:space:]]*(.+)$ ]]; then
                description="${BASH_REMATCH[1]}"
                break
            fi
        done < <(head -n 10 "$file_path")

        display_list[$idx]="$base_name — ${F_DIM}$description${NO_FORMAT}"
        keys_list[$idx]="$base_name"
    done

    # (3) gum choose --no-limit 로 여러 항목 선택 (터미널에 직접 표시)
    local selected_displays
    selected_displays=$(gum choose --no-limit \
        --cursor="▶ " \
        --header="👉 설치할 Brewfile을 선택하세요 ${F_DIM}(화살표 ↑↓, Space 선택, Enter 확정):${NO_FORMAT}" \
        --height=15 \
        --selected="${display_list[0]}" \
        "${display_list[@]}")

    if [[ -z "$selected_displays" ]]; then
        g_log warn "⚠️ Brewfile 선택이 취소되었습니다."
        return 1
    fi

    # (4) 선택된 줄을 배열에 담아 SELECTED_PATHS에 저장
    SELECTED_PATHS=()
    local -a chosen_items=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && chosen_items+=("$line")
    done <<< "$selected_displays"

    for chosen in "${chosen_items[@]}"; do
        # 앞뒤 공백 제거
        local trimmed="${chosen#"${chosen%%[![:space:]]*}"}"
        trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

        # " — " 앞부분만 추출
        local key="${trimmed%% — *}"

        # keys_list에서 인덱스 찾기
        for i in "${!keys_list[@]}"; do
            if [[ "${keys_list[$i]}" == "$key" ]]; then
                SELECTED_PATHS+=("${brewfiles_list[$i]}")
                break
            fi
        done
    done

    if [[ ${#SELECTED_PATHS[@]} -eq 0 ]]; then
        g_log error "선택된 Brewfile을 찾을 수 없습니다."
        return 1
    fi

    # (5) 전역 문자열 변수에 줄바꿈으로 직렬화
    #     => child 프로세스(install_brewfiles)에서 이 문자열을 보고 다시 배열로 복원할 수 있음
    # SELECTED_PATHS_STR="$(printf "%s\n" "${SELECTED_PATHS[@]}")"
    # export SELECTED_PATHS_STR

    # return 0

    printf "%s\n" "${SELECTED_PATHS[@]}" > "$ROOT_DIR/.selected_brewfile"
    std_info ".selected_brewfile 파일에 선택 경로를 기록했습니다: ${F_DIM}$ROOT_DIR/.selected_brewfile${NO_FORMAT}"

    # (6) 전역 문자열 변수에도 줄바꿈으로 직렬화하여 저장(install_brewfiles에서 배열 복원용)
    SELECTED_PATHS_STR="$(printf "%s\n" "${SELECTED_PATHS[@]}")"
    export SELECTED_PATHS_STR

    return 0
}
export -f select_brewfiles


# ------------------------------------------------------------
# install_brewfiles: SELECTED_PATHS_STR을 줄바꿈으로 읽어 SELECTED_PATHS 배열로 복원한 뒤 설치 수행
# ------------------------------------------------------------
install_brewfiles() {
    # 유틸리티 로드
    source "$ROOT_DIR/scripts/utilities/format.sh"
    source "$ROOT_DIR/scripts/utilities/gum.sh"

    # (0) 외부에서 직렬화된 문자열을 배열로 복원
    IFS=$'\n' read -r -d '' -a SELECTED_PATHS <<< "${SELECTED_PATHS_STR}"$'\0'

    # Homebrew 설치 여부 확인
    if ! command -v brew >/dev/null 2>&1; then
        g_log error "Homebrew가 설치되지 않았습니다. 먼저 Homebrew 설치를 완료해주세요."
        return 1
    fi

    # 설치할 목록이 비어있으면 바로 종료
    if [[ ${#SELECTED_PATHS[@]} -eq 0 ]]; then
        g_log warn "⚠️ 설치할 Brewfile이 없습니다."
        return 0
    fi

    # 선택된 Brewfile 순차 설치
    local -a succeeded=() failed=()
    trap 'g_log warn "⏹️ Brewfile 설치가 중단되었습니다."; exit 1' INT

    for bf in "${SELECTED_PATHS[@]}"; do
        local bf_name="$(basename "$bf")"
        g_log info "📥 '$bf_name'에 정의된 패키지를 설치합니다..."
        g_log info "선택된 Brewfile 경로: ${F_DIM}$bf${NO_FORMAT}"

        brew tap homebrew/bundle >/dev/null 2>&1 || true

        if gum spin --spinner="dot" --title="Installing $bf_name" -- \
            brew bundle --file="$bf"; then
            g_log info "[BREW SUCCESS] '$bf_name' 설치가 완료되었습니다."
            succeeded+=("$bf_name")
        else
            g_log warn "⚠️ '$bf_name' 설치 중 일부 항목이 실패했습니다."
            failed+=("$bf_name")
        fi
    done

    trap - INT
}
export -f install_brewfiles


# ------------------------------------------------------------
# run_brew: select_brewfiles → install_brewfiles(로그 캡처 + 최종 요약)
# ------------------------------------------------------------
run_brew() {
    if ! g_confirm "이어서 Brewfile 설치를 진행할까요?"; then
        g_log error "Brewfile 설치가 중단되었습니다."
        return 1
    fi

    # 1) 선택 과정
    if ! select_brewfiles; then
        return 1
    fi

    local start_ts end_ts elapsed
    start_ts=$(date +%s)

    local TMP_LOG
    TMP_LOG=$(mktemp -t brewfiles_log)

    if gum spin --show-output --title "brewfiles 설치 중..." -- bash -c "install_brewfiles > \"${TMP_LOG}\" 2>&1"; then
        g_log info "✅ install_brewfiles가 성공적으로 완료되었습니다."
    else
        g_log error "❌ install_brewfiles 실행 중 오류가 발생했습니다. 로그 파일을 확인하세요: ${F_DIM}${TMP_LOG}${NO_FORMAT}"
        return 1
    fi

    sed -E 's/\x1B\[[0-9;?]*[A-Za-z]//g' "${TMP_LOG}" > "${TMP_LOG}.clean"
    mv "${TMP_LOG}.clean" "${TMP_LOG}"

    end_ts=$(date +%s)
    elapsed=$(( end_ts - start_ts ))

    local brewfile_count pkg_count
    brewfile_count=$(awk '/[BREW SUCCESS][[:space:]]/ { count++ } END { print (count ? count : 0) }' "${TMP_LOG}")
    pkg_count=$(awk '/Using[[:space:]]/ { count++ } END { print (count ? count : 0) }' "${TMP_LOG}")

    # 4) 최종 요약에 로그 파일 경로와 함께 표시
    gum style \
        --foreground 210 --border-foreground 210 --border double \
        --align left --width 100 --margin "1 0" --padding "1 2" \
        "================================================================================================" \
        " 🤖 ${F_BOLD}Brewfile 설치 요약${NO_FORMAT}    " \
        "================================================================================================" \
        "" \
        " BREWFILES:  ${brewfile_count}" \
        " TOTAL:      ${pkg_count}" \
        "" \
        " LOG FILE:   ${F_DIM}${TMP_LOG}${NO_FORMAT}" \
        " DURATION:   ${elapsed}초"

    return 0
}
export -f run_brew 