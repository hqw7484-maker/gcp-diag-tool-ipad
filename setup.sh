#!/bin/bash
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[33m'
BOLD='\033[1m'
RESET='\033[0m'

clear
# --- [1/3] 物理清场进度 (仪式感拉满) ---
echo -e "${CYAN}${BOLD}>>> 正在启动系统环境极限净化...${RESET}"
tasks=("强制终结 Xray/CF 守护进程" "解绑 8000/8085 端口占用" "粉碎所有残留日志与配置" "重置 iPadOS 兼容性句柄")
for i in "${!tasks[@]}"; do
    case $i in
        0) pkill -9 xray; pkill -9 cf; pkill -9 python3 ;;
        1) fuser -k 8000/tcp 8085/tcp 2>/dev/null ;;
        2) rm -rf xray cf config.json index.html cf.log ;;
        3) sleep 1 ;;
    esac
    percent=$(( ($i + 1) * 100 / ${#tasks[@]} ))
    echo -e "    ${YELLOW}[${percent}%]${RESET} 执行: ${tasks[$i]}..."
    sleep 0.5
done
echo -e "${GREEN}✅ 物理环境重构完成！${RESET}\n"

# --- [2/3] 注入极客引擎 ---
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 拉取配置 (确保你的 GitHub 仓库里有这两个文件)
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

# --- [3/3] 暴力激活全链路 ---
# 1. 网页后端 (8085)
nohup python3 -m http.server 8085 --bind 127.0.0.1 > /dev/null 2>&1 &
# 2. Xray 后端 (8000)
nohup ./xray -c config.json > /dev/null 2>&1 &
sleep 2
# 3. 隧道入口 (直接对准 8000)
nohup ./cf tunnel --url http://127.0.0.1:8000 > cf.log 2>&1 &

# 闪电提取域名
for i in {1..12}; do
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        clear
        echo -e "${CYAN}${BOLD}============================================${RESET}"
        echo -e "🚀 ${GREEN}${BOLD}SYSTEM ONLINE | 极客链路已就绪${RESET}"
        echo -e "🔗 ${BOLD}ENTRY :${RESET} ${YELLOW}$LINK${RESET}"
        echo -e "✨ ${BOLD}ACTION:${RESET} 请执行 bash monitor.sh 进入精美监控${RESET}"
        echo -e "${CYAN}${BOLD}============================================${RESET}"
        exit 0
    fi
    echo -ne "   ⌛ 正在同步链路... ($((i*3))s)\r"
    sleep 3
done
