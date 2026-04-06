#!/bin/bash
clear
CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "    ██╗██████╗  █████╗ ██████╗      ██████╗ ██╗   ██╗ █████╗ ██████╗ "
echo "    ██║██╔══██╗██╔══██╗██╔══██╗    ██╔════╝ ██║   ██║██╔══██╗██╔══██╗"
echo "    ██║██████╔╝███████║██║  ██║    ██║  ███╗██║   ██║███████║██████╔╝"
echo "    ██║██╔═══╝ ██╔══██║██║  ██║    ██║   ██║██║   ██║██╔══██║██╔══██╗"
echo "    ██║██║     ██║  ██║██████╔╝    ╚██████╔╝╚██████╔╝██║  ██║██║  ██║"
echo -e "${RESET}"
echo -e "    ${BOLD}─────────────────────────────────────────────────────────────${RESET}"
echo -e "    ${BOLD}Guard:${RESET} Active  |  ${BOLD}Sync:${RESET} Shared-Port   | ${BOLD}Status:${RESET} Linked"
echo -e "    ${BOLD}─────────────────────────────────────────────────────────────${RESET}"

LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
echo -e "🔗 ${BOLD}Entry URL:${RESET} ${PURPLE}${LINK:-Searching...}${RESET}\n"

for i in {1..540}
do
    PERCENT=$(( i * 100 / 540 ))
    BAR=$(printf "%0.s#" $(seq 1 $((PERCENT / 5))))
    # 指示作用检测
    if pgrep -x "xray" > /dev/null; then STATUS="${GREEN}ONLINE${RESET}"; else STATUS="\033[31mOFFLINE${RESET}"; fi
    
    printf "\r %-10s | [%-20s] %d%% | %d/540min | %s " "$STATUS" "$BAR" "$PERCENT" "$i" "$(date '+%H:%M')"
    [ $((i%5)) -eq 0 ] && echo "" 
    touch .keep_alive
    sleep 60
done
