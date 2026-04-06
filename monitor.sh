#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
YELLOW='\033[33m'
RESET='\033[0m'

# 信号捕捉：杀死监控时，自动杀掉后台保活
trap "pkill -f keepalive.sh; exit" SIGINT SIGTERM

while true; do
    TIME=$(date '+%H:%M:%S')
    XRAY=$(pgrep -x xray)
    WEB=$(pgrep -f http.server)
    # 实时检测保活脚本进程
    KA_PROC=$(pgrep -f keepalive.sh)
    # 抓取你 keepalive.sh 写入的最后一次脉冲时间
    LAST_KA=$(tail -n 1 .ka_log 2>/dev/null | cut -d' ' -f1)

    # 提取域名
    WEB_URL=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf_web.log | head -n 1)
    NODE_URL=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf_node.log | head -n 1)

    clear
    echo -e "${CYAN}╔══════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║         NODE & KEEPALIVE PANEL           ║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════╝${RESET}"

    echo -e "TIME      : $TIME"
    echo -e "XRAY      : ${XRAY:+${GREEN}ONLINE${RESET}}${XRAY:-${RED}OFFLINE${RESET}}"
    echo -e "WEB       : ${WEB:+${GREEN}ONLINE${RESET}}${WEB:-${RED}OFFLINE${RESET}}"
    # 实时掌握保活状态
    echo -e "KEEPALIVE : ${KA_PROC:+${GREEN}RUNNING${RESET}}${KA_PROC:-${RED}STOPPED${RESET}}"
    echo -e "PULSE     : ${YELLOW}${LAST_KA:-WAITING...}${RESET}"

    echo -e "${CYAN}------------------------------------------${RESET}"
    echo -e "🌐 WEB  : ${PURPLE}${WEB_URL:-Linking...}${RESET}"
    echo -e "📡 NODE : ${PURPLE}${NODE_URL:-Linking...}/vbox${RESET}"
    echo -e "${CYAN}------------------------------------------${RESET}"

    sleep 5
done
