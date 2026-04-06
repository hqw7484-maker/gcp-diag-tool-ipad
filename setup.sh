#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

clear
echo -e "${CYAN}${BOLD}>>> 启动系统...${RESET}"

# ===== 清理 =====
pkill -9 xray 2>/dev/null
pkill -9 cf 2>/dev/null
pkill -f http.server 2>/dev/null
fuser -k 8080/tcp 8085/tcp 2>/dev/null
sleep 1

# ===== 下载 =====
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip -o Xray-linux-64.zip xray >/dev/null
chmod +x xray
rm -f Xray-linux-64.zip

wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf
chmod +x cf

# ===== 拉资源 =====
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"

curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/monitor.html" -o monitor.html

# ===== 启动 Xray =====
echo -e "${CYAN}>>> 启动 Xray${RESET}"
nohup ./xray -c config.json > node.log 2>&1 &
sleep 2

# ===== 启动网页 =====
nohup python3 -m http.server 8085 > web.log 2>&1 &
sleep 2

# ===== 双隧道 =====
echo -e "${CYAN}>>> 建立双隧道${RESET}"

nohup ./cf tunnel --url http://127.0.0.1:8085 > cf_web.log 2>&1 &
nohup ./cf tunnel --url http://127.0.0.1:8080 > cf_node.log 2>&1 &

# ===== 获取地址 =====
for i in {1..20}; do
    sleep 2
    WEB=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf_web.log | head -n 1)
    NODE=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf_node.log | head -n 1)

    if [ -n "$WEB" ] && [ -n "$NODE" ]; then
        clear
        echo -e "${GREEN}部署成功${RESET}"
        echo ""
        echo -e "🌐 WEB  : ${PURPLE}${WEB}${RESET}"
        echo -e "📡 NODE : ${PURPLE}${NODE}/vbox${RESET}"
        echo ""

        # 写入给网页用
        echo "window.NODE_URL='${NODE}/vbox';" > env.js

        exit 0
    fi
done
