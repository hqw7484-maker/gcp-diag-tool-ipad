#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
RESET='\033[0m'

while true; do
    TIME=$(date '+%H:%M:%S')

    XRAY=$(pgrep -x xray)
    WEB=$(pgrep -f http.server)

    WEB_URL=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf_web.log | head -n 1)
    NODE_URL=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf_node.log | head -n 1)

    # 绑定控制
    if [ -z "$XRAY" ]; then
        pkill -f http.server
    fi

    clear
    echo -e "${CYAN}╔══════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║        NODE CONTROL PANEL        ║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════╝${RESET}"

    echo -e "TIME  : $TIME"
    echo -e "XRAY  : ${XRAY:+${GREEN}ONLINE${RESET}}${XRAY:-${RED}OFFLINE${RESET}}"
    echo -e "WEB   : ${WEB:+${GREEN}ONLINE${RESET}}${WEB:-${RED}OFFLINE${RESET}}"

    echo ""
    echo -e "🌐 ${PURPLE}${WEB_URL}${RESET}"
    echo -e "📡 ${PURPLE}${NODE_URL}/vbox${RESET}"

    sleep 5
done
