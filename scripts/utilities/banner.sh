#!/usr/bin/env bash

    # "            ____              _        _            "
    # "           | __ )  ___   ___ | |_   __| | _____   __"
    # "           |  _ \ / _ \ / _ \| __| / _` |/ _ \ \ / /"
    # "           | |_) | (_) | (_) | |_ | (_| |  __/\ V / "
    # "           |____/ \___/ \___/ \__(_)__,_|\___| \_/  "
BANNER_ONBOARDING=(
    '                               ____              _        _            '
    '                              | __ )  ___   ___ | |_   __| | _____   __'
    '                              |  _ \ / _ \ / _ \| __| / _` |/ _ \ \ / /'
    '                              | |_) | (_) | (_) | |_ | (_| |  __/\ V / '
    '                              |____/ \___/ \___/ \__(_)__,_|\___| \_/  '
    "                                                                                           "
    "                        Effortless MacOS Bootstrapping, from zero to ready                 "
    "                              Boot.dev v1.0.0. Maintainer: @young1ll                       "
)

BANNER_OFFBOARDING=(
    "╔════════════════════════════════════════════════════════════════════════════════════════════════════╗"
    "║                                                                                                    ║"
    "║                                                                                                    ║"
    "║           ALL SYSTEMS GO! ALL SYSTEMS GO! ALL SYSTEMS GO! ALL SYSTEMS GO! ALL SYSTEMS GO!          ║"
    "║                      Boot.dev Successfully Completed! Now you are ready to go!                     ║"
    "║                 새로운 세션에서 Boot.dev로 업데이트된 환경으로 시작할 수 있습니다.                 ║"
    "║                                                                                                    ║"
    "║                                                                                                    ║"
    "╚════════════════════════════════════════════════════════════════════════════════════════════════════╝"
)

print_specs() {
    # OS 정보
    local os_name os_version kernel
    os_name=$(sw_vers -productName)
    os_version=$(sw_vers -productVersion)
    kernel=$(uname -r)

    # CPU
    local cpu
    cpu=$(sysctl -n machdep.cpu.brand_string)

    # 메모리 (Bytes → GB)
    local mem_bytes mem_gb
    mem_bytes=$(sysctl -n hw.memsize)
    mem_gb=$(printf "%.1f" "$(bc -l <<< "$mem_bytes/1024/1024/1024")")

    # 디스크(/) 사용량
    local disk_total disk_avail
    read -r _ disk_total _ disk_avail _ < <(df -h / | awk 'NR==2{print}')
    
    echo
    echo -e "${C_GREY0} ==================================================================================================== "
    echo "   Operating System: ${os_name} ${os_version} (kernel ${kernel})"
    echo "   CPU: ${cpu}"
    echo "   Memory: ${mem_gb} GB"
    echo "   Disk (/): ${disk_total} total, ${disk_avail} available"
    echo -e " ==================================================================================================== ${NO_FORMAT}"
    echo
}

print_banner_onboarding() {
    clear; echo

    gradient_text "${BANNER_ONBOARDING[@]}"
    print_specs
}

print_banner_offboarding() {
    sleep 1; echo

    gradient_text "${BANNER_OFFBOARDING[@]}"
    echo "  - ~/.p10k.zsh 설정 추천:"
    echo "    POWERLEVEL9K_SHORTEN_STRATEGY=\"truncate_to_last\""
    echo "    POWERLEVEL9K_SHORTEN_DIR_LENGTH=2"
}