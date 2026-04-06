#!/bin/bash
# ------------------------------------------------
# GCP iPad 强力版 - 确保链接必出
# ------------------------------------------------
BLUE='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# 1. 物理消杀
echo -e "${BLUE}[1/3]${RESET} 深度清理环境..."
pkill -9 xray; pkill -9 cf; pkill -9 python3; sleep 1
fuser -k 8080/tcp 2>/dev/null
fuser -k 8085/tcp 2>/dev/null
find . -maxdepth 1 ! -name 'setup.sh' ! -name 'start.sh' ! -name '.' -exec rm -rf {} +

# 2. 下载与配置
echo -e "${BLUE}[2/3]${RESET} 同步仓库配置..."
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html
curl -sL "$RAW_URL/tunnel.yml" -o tunnel.yml

# 3. 启动并暴力抓取
echo -e "${BLUE}[3/3]${RESET} 激活隧道 (正在暴力提取域名)..."
nohup ./xray -c config.json > node.log 2>&1 &
nohup python3 -m http.server 8085 --bind 0.0.0.0 > /dev/null 2>&1 &
nohup ./cf tunnel --config tunnel.yml run > cf.log 2>&1 &

# 关键：循环死等链接出现
LINK=""
while [ -z "$LINK" ]; do
    sleep 3
    LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' cf.log | head -n 1)
    echo -ne "   ⌛ 正在同步 Cloudflare 节点状态...\r"
done

clear
echo -e "${GREEN}================================================${RESET}"
echo -e "🚀 ${GREEN}GCP 核心节点部署成功！${RESET}"
echo -e "${BLUE}------------------------------------------------${RESET}"
echo -e "🔗 ${YELLOW}隧道域名:${RESET} ${LINK}"
echo -e "🔑 ${YELLOW}V2box 路径:${RESET} /vbox"
echo -e "🎨 ${YELLOW}面板状态:${RESET} ONLINE"
echo -e "${BLUE}------------------------------------------------${RESET}"
echo -e "即将进入实时监控模式..."
sleep 2
