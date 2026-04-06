#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

clear

while true; do
    TIME=$(date '+%H:%M:%S')

    XRAY=$(pgrep -x xray)
    CF=$(pgrep -x cf)
    WEB=$(pgrep -f http.server)

    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)

    # ===== 状态判断 =====
    if [ -n "$XRAY" ]; then
        XRAY_STATUS="${GREEN}ONLINE${RESET}"
    else
        XRAY_STATUS="${RED}OFFLINE${RESET}"
    fi

    if [ -n "$CF" ]; then
        CF_STATUS="${GREEN}ONLINE${RESET}"
    else
        CF_STATUS="${RED}OFFLINE${RESET}"
    fi

    if [ -n "$WEB" ]; then
        WEB_STATUS="${GREEN}ONLINE${RESET}"
    else
        WEB_STATUS="${RED}OFFLINE${RESET}"
    fi

    # ===== 强绑定逻辑 =====
    if [ -z "$XRAY" ] && [ -n "$WEB" ]; then
        pkill -f http.server
    fi

    if [ -n "$XRAY" ] && [ -z "$WEB" ]; then
        nohup python3 -m http.server 8085 > web.log 2>&1 &
    fi

    # ===== UI =====
    clear
    echo -e "${CYAN}${BOLD}"
    echo " ███╗   ██╗ ██████╗ ██████╗ ███████╗"
    echo " ████╗  ██║██╔═══██╗██╔══██╗██╔════╝"
    echo " ██╔██╗ ██║██║   ██║██║  ██║█████╗  "
    echo " ██║╚██╗██║██║   ██║██║  ██║██╔══╝  "
    echo " ██║ ╚████║╚██████╔╝██████╔╝███████╗"
    echo -e "${RESET}"

    echo -e "${BOLD}TIME:${RESET} $TIME"
    echo -e "${BOLD}XRAY:${RESET} $XRAY_STATUS"
    echo -e "${BOLD}TUNNEL:${RESET} $CF_STATUS"
    echo -e "${BOLD}WEB:${RESET} $WEB_STATUS"
    echo ""

    echo -e "${BOLD}URL:${RESET}"
    echo -e "${PURPLE}${LINK:-Generating...}${RESET}"
    echo ""

    echo -e "${YELLOW}Node <-> Web Binding: ACTIVE${RESET}"

    sleep 5
done
