#!/bin/bash
clear
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

# 极客 ASCII Logo
echo -e "${CYAN}${BOLD}"
echo "    ██╗██████╗  █████╗ ██████╗      ██████╗ ██╗   ██╗ █████╗ ██████╗ "
echo "    ██║██╔══██╗██╔══██╗██╔══██╗    ██╔════╝ ██║   ██║██╔══██╗██╔══██╗"
echo "    ██║██████╔╝███████║██║  ██║    ██║  ███╗██║   ██║███████║██████╔╝"
echo "    ██║██╔═══╝ ██╔══██║██║  ██║    ██║   ██║██║   ██║██╔══██║██╔══██╗"
echo "    ██║██║     ██║  ██║██████╔╝    ╚██████╔╝╚██████╔╝██║  ██║██║  ██║"
echo -e "${RESET}"
echo -e "    ${BOLD}─────────────────────────────────────────────────────────────${RESET}"
echo -e "    ${BOLD}Guard:${RESET} Active  |  ${BOLD}Split:${RESET} Python-Bridge | ${BOLD}Target:${RESET} iPad-Air"
echo -e "    ${BOLD}─────────────────────────────────────────────────────────────${RESET}"

# 获取域名
LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
echo -e "🔗 ${BOLD}Entry URL:${RESET} ${BLUE}${LINK:-Waiting...}${RESET}"
echo ""

for i in {1..540}
do
    # 多路状态锁
    if pgrep -x "xray" > /dev/null && pgrep -f "gateway.py" > /dev/null; then
        STATUS="${GREEN}${BOLD}● ONLINE${RESET}"
    else
        STATUS="${RED}${BOLD}○ OFFLINE${RESET}"
    fi

    # 进度条计算
    PERCENT=$(( i * 100 / 540 ))
    BAR=$(printf "%0.s#" $(seq 1 $((PERCENT / 5))))
    
    # 实时流量捕捉 (显示最后一条流量类型)
    TRAFFIC=$(tail -n 1 gateway.log 2>/dev/null | cut -d ' ' -f 2,3)
    
    # 单行刷新输出
    printf "\r %-12s | [%-20s] %d%% | %d/540min | ${CYAN}%-15s${RESET}" "$STATUS" "$BAR" "$PERCENT" "$i" "${TRAFFIC:-IDLE}"
    
    # 每 5 分钟保留一条心跳记录
    [ $((i%5)) -eq 0 ] && echo -e "\n   ${YELLOW}>>> Heartbeat at $(date '+%H:%M:%S')${RESET}"
    
    touch .keep_alive
    sleep 60
done
