#!/bin/bash
clear
CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

# 极客 ASCII Logo (回归)
echo -e "${CYAN}${BOLD}"
echo "    ██╗██████╗  █████╗ ██████╗      ██████╗ ██╗   ██╗ █████╗ ██████╗ "
echo "    ██║██╔══██╗██╔══██╗██╔══██╗    ██╔════╝ ██║   ██║██╔══██╗██╔══██╗"
echo "    ██║██████╔╝███████║██║  ██║    ██║  ███╗██║   ██║███████║██████╔╝"
echo "    ██║██╔═══╝ ██╔══██║██║  ██║    ██║   ██║██║   ██║██╔══██║██╔══██╗"
echo "    ██║██║     ██║  ██║██████╔╝    ╚██████╔╝╚██████╔╝██║  ██║██║  ██║"
echo -e "${RESET}"
echo -e "    ${BOLD}─────────────────────────────────────────────────────────────${RESET}"
echo -e "    ${BOLD}Guard:${RESET} Active  |  ${BOLD}Split:${RESET} Xray-Fallback | ${BOLD}Status:${RESET} 540M-Cycle"
echo -e "    ${BOLD}─────────────────────────────────────────────────────────────${RESET}"

# 实时提取域名
LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
echo -e "🔗 ${BOLD}Entry URL:${RESET} ${PURPLE}${LINK:-Searching...}${RESET}\n"

for i in {1..540}
do
    PERCENT=$(( i * 100 / 540 ))
    BAR=$(printf "%0.s#" $(seq 1 $((PERCENT / 5))))
    
    # 状态实时监测
    if pgrep -x "xray" > /dev/null; then STATUS="${GREEN}ON${RESET}"; else STATUS="\033[31mOFF${RESET}"; fi
    
    # 单行整洁刷新
    printf "\r %-8s | [%-20s] %d%% | %d/540min | %s " "$STATUS" "$BAR" "$PERCENT" "$i" "$(date '+%H:%M')"
    
    [ $((i%5)) -eq 0 ] && echo "" 
    touch .keep_alive
    sleep 60
done
