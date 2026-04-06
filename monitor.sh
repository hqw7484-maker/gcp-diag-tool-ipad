#!/bin/bash

# ===== 核心配色方案 =====
G_BG='\033[42;30m'  # 绿底黑字
R_BG='\033[41;30m'  # 红底黑字
CYAN='\033[0;36m'   # 青色
GRAY='\033[0;90m'   # 深灰
WHITE='\033[1;37m'  # 亮白
RESET='\033[0m'     # 重置

# [自毁联动]
trap "pkill -f keepalive.sh; exit" SIGINT SIGTERM

while true; do
    TIME=$(date '+%H:%M:%S')
    XRAY=$(pgrep -x xray)
    WEB=$(pgrep -f http.server)
    KA_PROC=$(pgrep -f keepalive.sh)
    LAST_KA=$(tail -n 1 .ka_log 2>/dev/null | cut -d' ' -f1)
    
    # 物理关联逻辑
    if [ -z "$XRAY" ]; then pkill -f http.server; fi

    clear
    # --- 标题栏 ---
    echo -e "${CYAN}┌──────────────────────────────────────────────┐${RESET}"
    echo -e "${CYAN}│${RESET}  ${WHITE}SYSTEM DIAGNOSTIC TERMINAL${RESET}  ${GRAY}v2.1.0-DX2${RESET}  ${CYAN}│${RESET}"
    echo -e "${CYAN}└──────────────────────────────────────────────┘${RESET}"

    # --- 核心状态区 (使用色块增强视觉对比) ---
    echo -ne " ${WHITE}CORE ENGINE  :${RESET} "
    if [ -n "$XRAY" ]; then echo -e "${G_BG}  ACTIVE  ${RESET}"; else echo -e "${R_BG}  OFFLINE ${RESET}"; fi

    echo -ne " ${WHITE}WEB SERVICE  :${RESET} "
    if [ -n "$WEB" ]; then echo -e "${G_BG}  RUNNING ${RESET}"; else echo -e "${R_BG}  STOPPED ${RESET}"; fi

    echo -ne " ${WHITE}KEEPALIVE    :${RESET} "
    if [ -n "$KA_PROC" ]; then echo -e "${G_BG}  ENABLED ${RESET}"; else echo -e "${R_BG}  DISABLED${RESET}"; fi

    echo -e "${GRAY}------------------------------------------------${RESET}"

    # --- 实时数据流 ---
    echo -e " ${CYAN}TIME :${RESET} ${WHITE}$TIME${RESET}"
    echo -e " ${CYAN}KA-PULSE :${RESET} ${WHITE}${LAST_KA:-N/A}${RESET}"

    # --- 域名抓取显示 ---
    WEB_URL=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf_web.log | head -n 1)
    NODE_URL=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf_node.log | head -n 1)
    
    echo -e "${GRAY}------------------------------------------------${RESET}"
    echo -e " ${WHITE}ENTRY-URL :${RESET}"
    echo -e " ${CYAN}>>${RESET} ${PURPLE}${WEB_URL:-SYNCING...}${RESET}"
    echo -e " ${WHITE}NODE-URL  :${RESET}"
    echo -e " ${CYAN}>>${RESET} ${PURPLE}${NODE_URL:-SYNCING...}/vbox${RESET}"
    echo -e "${GRAY}------------------------------------------------${RESET}"

    # --- 底部动画感 (模拟加载) ---
    echo -ne "${GRAY}System polling... [${CYAN} OK ${GRAY}]${RESET}\r"

    sleep 5
done
