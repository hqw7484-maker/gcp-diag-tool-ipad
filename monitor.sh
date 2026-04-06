#!/bin/bash

# --- 色彩定义 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m' # 清除色彩

clear

# --- 欢迎 LOGO (仪式感) ---
echo -e "${CYAN}${BOLD}"
echo "    ██╗██████╗  █████╗ ██████╗      ██████╗ ██╗   ██╗ █████╗ ██████╗ ██████╗ "
echo "    ██║██╔══██╗██╔══██╗██╔══██╗    ██╔════╝ ██║   ██║██╔══██╗██╔══██╗██╔══██╗"
echo "    ██║██████╔╝███████║██║  ██║    ██║  ███╗██║   ██║███████║██████╔╝██║  ██║"
echo "    ██║██╔═══╝ ██╔══██║██║  ██║    ██║   ██║██║   ██║██╔══██║██╔══██╗██║  ██║"
echo "    ██║██║     ██║  ██║██████╔╝    ╚██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝"
echo "    ╚═╝╚═╝     ╚═╝  ╚═╝╚═════╝      ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ "
echo -e "${NC}"
echo -e "${WHITE}    ─────────────────────────────────────────────────────────────────────────${NC}"
echo -e "    ${BOLD}System:${NC} Google Cloud Shell  |  ${BOLD}Core:${NC} Xray-Core v26.3.27  |  ${BOLD}Mode:${NC} WS+TLS"
echo -e "${WHITE}    ─────────────────────────────────────────────────────────────────────────${NC}"
echo ""

# --- 动态仪表盘 ---
while true; do
    TIME=$(date '+%Y-%m-%d %H:%M:%S')
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    
    # 获取运行状态 (简单检查进程)
    if pgrep -x "xray" > /dev/null; then
        STATUS="${GREEN}RUNNING${NC}"
    else
        STATUS="${RED}STOPPED${NC}"
    fi

    # 打印单行状态栏 (带背景感)
    # \r 让内容始终覆盖同一行
    printf "\r    ${BOLD}[${CYAN}SYSTEM${NC}${BOLD}]${NC} ${WHITE}${TIME}${NC} | ${BOLD}[${CYAN}STATUS${NC}${BOLD}]${NC} ${STATUS} | ${BOLD}[${CYAN}URL${NC}${BOLD}]${NC} ${PURPLE}${LINK:-Searching...}${NC}"
    
    touch .keep_alive
    sleep 30
done
