#!/bin/bash
# CORE DX-2.0 SYSTEM SETUP (STABLE VERSION)
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RESET='\033[0m'

clear
echo -e "${CYAN}>>> 正在初始化核心环境...${RESET}"

# 1. 物理清场
rm -f xray cf config.json index.html env.js keepalive.sh

# 2. 下载核心组件
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip -o Xray-linux-64.zip xray >/dev/null && chmod +x xray && rm -f Xray-linux-64.zip
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf

# 3. 强制同步最新的暗黑版 UI (改名为 index.html 确保 Python 识别)
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json?v=$(date +%s)" -o config.json
curl -sL "$RAW_URL/monitor.html?v=$(date +%s)" -o index.html

# 4. 启动 Xray 核心 (关键：休眠 3 秒确保就绪，防止 V2Box 超时)
nohup ./xray -c config.json > node.log 2>&1 &
sleep 3

# 5. 启动网页与隧道服务
nohup python3 -m http.server 8085 > web.log 2>&1 &
nohup ./cf tunnel --url http://127.0.0.1:8085 > cf_web.log 2>&1 &
nohup ./cf tunnel --url http://127.0.0.1:8080 > cf_node.log 2>&1 &

# 6. 地址下发与 env.js 注入
for i in {1..15}; do
    sleep 2
    WEB=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf_web.log | head -n 1)
    NODE=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf_node.log | head -n 1)
    if [ -n "$WEB" ] && [ -n "$NODE" ]; then
        echo "window.NODE_URL='${NODE}';" > env.js
        clear
        echo -e "${GREEN}部署成功！${RESET}"
        echo -e "🌐 WEB  : ${WEB}"
        echo -e "📡 NODE : ${NODE}/vbox"
        exit 0
    fi
done
exit 1
