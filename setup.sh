#!/bin/bash
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
BOLD='\033[1m'
RESET='\033[0m'

clear
echo -e "${CYAN}${BOLD}>>> [1/3] 极客环境初始化...${RESET}"
pkill -9 xray; pkill -9 cf; pkill -9 python3; sleep 1
# 保持脚本存在，清理其他垃圾
rm -f xray cf config.json index.html cf.log node.log

echo -e "${CYAN}${BOLD}>>> [2/3] 注入核心驱动...${RESET}"
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 拉取配置
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

echo -e "${CYAN}${BOLD}>>> [3/3] 启动全流量覆盖隧道...${RESET}"
# 先启动网页服务器 (127.0.0.1 确保安全)
nohup python3 -m http.server 8085 --bind 127.0.0.1 > /dev/null 2>&1 &
sleep 2

# 启动 Xray 负责分流
nohup ./xray -c config.json > node.log 2>&1 &
sleep 1

# 直接映射到 Xray 的 8080 端口，无需 YAML
nohup ./cf tunnel --url http://127.0.0.1:8080 > cf.log 2>&1 &

# 进度反馈
for i in {1..12}; do
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        clear
        echo -e "${CYAN}${BOLD}================================================${RESET}"
        echo -e "🚀 ${GREEN}${BOLD}SYSTEM ONLINE | 极客分流已激活${RESET}"
        echo -e "${CYAN}------------------------------------------------${RESET}"
        echo -e "🔗 ${BOLD}ENTRY:${RESET} ${PURPLE}${BOLD}${LINK}${RESET}"
        echo -e "📡 ${BOLD}PATH :${RESET} /api/v3/metrics"
        echo -e "${CYAN}================================================${RESET}"
        exit 0
    fi
    echo -ne "   ${CYAN}⌛ 正在同步比特流... ($((i*3))s)${RESET}\r"
    sleep 3
done
