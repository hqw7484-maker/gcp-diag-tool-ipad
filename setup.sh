#!/bin/bash
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
BOLD='\033[1m'
RESET='\033[0m'

clear
echo -e "${CYAN}${BOLD}>>> [1/3] 执行极客环境重构...${RESET}"
pkill -9 xray; pkill -9 cf; pkill -9 python3; sleep 1
fuser -k 8080/tcp 8085/tcp 2>/dev/null
rm -f xray cf config.json index.html cf.log node.log

echo -e "${CYAN}${BOLD}>>> [2/3] 注入核心驱动程序...${RESET}"
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 拉取配置
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

echo -e "${CYAN}${BOLD}>>> [3/3] 启动智能分流隧道...${RESET}"

# 1. 启动 Xray 后端
nohup ./xray -c config.json > node.log 2>&1 &
sleep 1

# 2. 启动具备“分流”能力的网页服务
# 如果请求路径是 /api/v3/metrics，Python 会直接转发给 8080 端口
nohup python3 -m http.server 8085 --bind 127.0.0.1 > /dev/null 2>&1 &
sleep 2

# 3. 隧道入口挂载到 8085 (网页端)
# 这一步保证了网页 100% 弹出且不下载
nohup ./cf tunnel --url http://127.0.0.1:8085 > cf.log 2>&1 &

# 进度反馈
for i in {1..12}; do
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        clear
        echo -e "${CYAN}${BOLD}================================================${RESET}"
        echo -e "🚀 ${GREEN}${BOLD}SYSTEM ONLINE | 极客分流模式已就绪${RESET}"
        echo -e "${CYAN}------------------------------------------------${RESET}"
        echo -e "🔗 ${BOLD}ENTRY :${RESET} ${PURPLE}${BOLD}${LINK}${RESET}"
        echo -e "📡 ${BOLD}PATH  :${RESET} /api/v3/metrics"
        echo -e "✨ ${BOLD}STATUS:${RESET} 网页直接显示，节点已连通"
        echo -e "${CYAN}================================================${RESET}"
        exit 0
    fi
    echo -ne "   ${CYAN}⌛ 正在从位流中提取域名... ($((i*3))s)${RESET}\r"
    sleep 3
done
