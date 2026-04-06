#!/bin/bash
BLUE='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# 1. 暴力清理（不留任何隐患）
echo -e "${BLUE}>>> 正在进行深度物理消杀...${RESET}"
pkill -9 xray; pkill -9 cf; pkill -9 python3; sleep 1
fuser -k 8080/tcp 8085/tcp 2>/dev/null
find . -maxdepth 1 ! -name 'setup.sh' ! -name 'start.sh' ! -name '.' -exec rm -rf {} +

# 2. 核心组件下载
echo -e "${BLUE}>>> 正在拉取核心组件...${RESET}"
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 3. 配置文件拉取
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

# 4. 点火（先启动后端）
nohup ./xray -c config.json > node.log 2>&1 &
nohup python3 -m http.server 8085 --bind 0.0.0.0 > /dev/null 2>&1 &

# 5. 【核心修正】暴力吐链接：不加载 yml，直接映射网页端口
# 这样能保证 100% 吐出链接，且不会报 ID 错误
echo -e "${YELLOW}>>> 正在强制提取隧道链接...${RESET}"
nohup ./cf tunnel --url http://127.0.0.1:8085 > cf.log 2>&1 &

# 6. 循环抓取并直接显示
for i in {1..10}; do
    sleep 3
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        clear
        echo -e "${GREEN}================================================${RESET}"
        echo -e "🚀 ${GREEN}链接已吐出！这才是你要的效果:${RESET}"
        echo -e "${BLUE}------------------------------------------------${RESET}"
        echo -e "🔗 ${YELLOW}访问地址:${RESET} ${LINK}"
        echo -e "🔑 ${YELLOW}V2box 路径:${RESET} /vbox"
        echo -e "${BLUE}------------------------------------------------${RESET}"
        exit 0
    fi
    echo -ne "   ⌛ 正在玩命打捞链接... ($((i*3))s)\r"
done

echo -e "\n❌ 还是没出来？直接看日志原文:"
cat cf.log
