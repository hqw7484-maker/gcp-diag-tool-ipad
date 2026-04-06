#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

while true; do
    TIME=$(date '+%H:%M:%S')

    XRAY=$(pgrep -x xray)
    CF=$(pgrep -x cf)
    WEB=$(pgrep -f http.server)

    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)

    # ===== 状态绑定 =====
    if [ -z "$XRAY" ] && [ -n "$WEB" ]; then
        pkill -f http.server
    fi

    if [ -n "$XRAY" ] && [ -z "$WEB" ]; then
        nohup python3 -m http.server 8085 > web.log 2>&1 &
    fi

    # ===== UI =====
    clear
    echo -e "${CYAN}${BOLD}"
    echo "   NODE MONITOR PANEL"
    echo -e "${RESET}"

    printf "TIME   : %s\n" "$TIME"
    printf "XRAY   : %b\n" "${XRAY:+${GREEN}ONLINE${RESET}}${XRAY:-${RED}OFFLINE${RESET}}"
    printf "TUNNEL : %b\n" "${CF:+${GREEN}ONLINE${RESET}}${CF:-${RED}OFFLINE${RESET}}"
    printf "WEB    : %b\n" "${WEB:+${GREEN}ONLINE${RESET}}${WEB:-${RED}OFFLINE${RESET}}"

    echo ""
    echo -e "URL:"
    echo -e "${PURPLE}${LINK:-Generating...}${RESET}"

    sleep 5
done
