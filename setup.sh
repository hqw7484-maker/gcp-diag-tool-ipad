#!/bin/bash
CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[33m'
BOLD='\033[1m'
RESET='\033[0m'

clear
# --- [1/3] 物理清场进度展示 ---
echo -e "${CYAN}${BOLD}>>> 正在初始化极客净化序列...${RESET}"
tasks=("强制终结 Xray 核心" "切断 Cloudflare 隧道" "释放 Python 监听端口" "粉碎残留日志与缓存")
for i in "${!tasks[@]}"; do
    case $i in
        0) pkill -9 xray ;;
        1) pkill -9 cf ;;
        2) pkill -9 python3; fuser -k 8080/tcp 8085/tcp 2>/dev/null ;;
        3) rm -f xray cf config.json index.html cf.log node.log ;;
    esac
    percent=$(( ($i + 1) * 100 / ${#tasks[@]} ))
    echo -e "    ${YELLOW}[${percent}%]${RESET} 执行: ${tasks[$i]}..."
    sleep 0.5
done
echo -e "${GREEN}✅ 物理环境已彻底净空！${RESET}\n"

# --- [2/3] 驱动注入 ---
echo -e "${CYAN}${BOLD}>>> 注入 Xray-Core 极客引擎...${RESET}"
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 资源拉取
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

# --- [3/3] 激活分流隧道 ---
echo -e "${CYAN}${BOLD}>>> 启动智能分流指挥部...${RESET}"
# 网页监听在 8085 (让 Xray 能够把非节点流量转过来)
nohup python3 -m http.server 8085 --bind 127.0.0.1 > /dev/null 2>&1 &
# Xray 监听在 8080 (负责接收隧道流量并分流)
nohup ./xray -c config.json > node.log 2>&1 &
sleep 2
# 隧道直接对接 Xray (8080)
nohup ./cf tunnel --url http://127.0.0.1:8080 > cf.log 2>&1 &

# 动态打捞域名
for i in {1..15}; do
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        clear
        echo -e "${CYAN}${BOLD}============================================${RESET}"
        echo -e "🚀 ${GREEN}${BOLD}SYSTEM ONLINE | 完美分流已就绪${RESET}"
        echo -e "${CYAN}--------------------------------------------${RESET}"
        echo -e "🔗 ${BOLD}ENTRY:${RESET} ${PURPLE}${BOLD}$LINK${RESET}"
        echo -e "📡 ${BOLD}PATH :${RESET} /api/v3/metrics"
        echo -e "✨ ${BOLD}RESULT:${RESET} V2box 连通 & 网页正常显示"
        echo -e "${CYAN}============================================${RESET}"
        exit 0
    fi
    echo -ne "   ${YELLOW}⌛ 正在从数据深渊中打捞域名... ($((i*2))s)${RESET}\r"
    sleep 2
done
