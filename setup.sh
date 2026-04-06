#!/bin/bash
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

clear
echo -e "${CYAN}${BOLD}>>> [1/4] 环境深度消杀...${RESET}"
pkill -9 xray; pkill -9 cf; pkill -9 python3; sleep 1
fuser -k 8080/tcp 8085/tcp 2>/dev/null
find . -maxdepth 1 ! -name 'setup.sh' ! -name 'start.sh' ! -name 'monitor.sh' ! -name '.' -exec rm -rf {} +

echo -e "${CYAN}${BOLD}>>> [2/4] 同步核心组件...${RESET}"
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

echo -e "${CYAN}${BOLD}>>> [3/4] 部署分流指挥中心...${RESET}"
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html
curl -sL "$RAW_URL/tunnel.yml" -o tunnel.yml

echo -e "${CYAN}${BOLD}>>> [4/4] 启动多链路分流隧道...${RESET}"
nohup ./xray -c config.json > node.log 2>&1 &
nohup python3 -m http.server 8085 --bind 0.0.0.0 > /dev/null 2>&1 &
# 关键：加载 tunnel.yml 开启分流
nohup ./cf tunnel --config tunnel.yml run > cf.log 2>&1 &

# 强力抓取逻辑
for i in {1..15}; do
    sleep 3
    # 更加流氓的正则，通杀所有格式
    LINK=$(grep -oE "https://[a-zA-Z0-9-]+\.trycloudflare\.com" cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        clear
        echo -e "${CYAN}${BOLD}================================================${RESET}"
        echo -e "🚀 ${GREEN}${BOLD}部署成功！分流模式已就绪${RESET}"
        echo -e "${CYAN}------------------------------------------------${RESET}"
        echo -e "🔗 ${BOLD}隧道入口:${RESET} ${PURPLE}${BOLD}${LINK}${RESET}"
        echo -e "📡 ${BOLD}节点路径:${RESET} ${YELLOW}${LINK}/vbox${RESET}"
        echo -e "${CYAN}------------------------------------------------${RESET}"
        exit 0
    fi
    echo -ne "   ${YELLOW}⌛ 正在从日志深处打捞链接... ($((i*3))s)${RESET}\r"
done

# 如果还是没出来，强制打印日志给用户看
echo -e "\n${YELLOW}⚠️ 自动抓取较慢，以下是 Cloudflare 实时日志回传：${RESET}"
grep "trycloudflare.com" cf.log
