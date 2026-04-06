#!/bin/bash

# ===== UI =====
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

clear
echo -e "${CYAN}${BOLD}>>> 初始化部署环境...${RESET}"

# ===== 1. 清理 =====
pkill -9 xray 2>/dev/null
pkill -9 cf 2>/dev/null
pkill -f http.server 2>/dev/null
fuser -k 8080/tcp 8085/tcp 2>/dev/null
sleep 1

# ===== 2. 拉核心 =====
echo -e "${CYAN}${BOLD}>>> 下载核心组件...${RESET}"

wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip -o Xray-linux-64.zip xray >/dev/null
chmod +x xray
rm -f Xray-linux-64.zip

wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf
chmod +x cf

# ===== 3. 拉配置 =====
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"

curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

# ===== 4. 启动 Xray =====
echo -e "${CYAN}${BOLD}>>> 启动 Xray 核心...${RESET}"
nohup ./xray -c config.json > node.log 2>&1 &
sleep 2

# ===== 5. 启动网页（依赖 Xray）=====
if pgrep -x "xray" > /dev/null; then
    echo -e "${CYAN}${BOLD}>>> 启动网页服务...${RESET}"
    nohup python3 -m http.server 8085 > web.log 2>&1 &
else
    echo -e "${YELLOW}Xray 启动失败，终止部署${RESET}"
    exit 1
fi

sleep 2

# ===== 6. 启动隧道 =====
echo -e "${CYAN}${BOLD}>>> 建立 Cloudflare 隧道...${RESET}"
nohup ./cf tunnel --url http://127.0.0.1:8080 > cf.log 2>&1 &

# ===== 7. 获取链接 =====
echo -e "${YELLOW}>>> 正在提取访问地址...${RESET}"

for i in {1..15}; do
    sleep 2
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)

    if [ -n "$LINK" ]; then
        clear
        echo -e "${CYAN}${BOLD}========================================${RESET}"
        echo -e "🚀 ${GREEN}${BOLD}部署成功${RESET}"
        echo -e "${CYAN}----------------------------------------${RESET}"
        echo -e "🌐 URL: ${PURPLE}${LINK}${RESET}"
        echo -e "📡 V2 Path: /vbox"
        echo -e "🧠 状态绑定: 已启用"
        echo -e "${CYAN}${BOLD}========================================${RESET}"
        exit 0
    fi
done

echo -e "${YELLOW}未获取到链接，请查看 cf.log${RESET}"
