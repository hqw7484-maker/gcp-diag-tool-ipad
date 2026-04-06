#!/bin/bash
BLUE='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# 1. 物理消杀
echo -e "${BLUE}[1/3]${RESET} 正在深度清理旧环境..."
pkill -9 xray; pkill -9 cf; pkill -9 python3; sleep 1
fuser -k 8080/tcp 2>/dev/null
fuser -k 8085/tcp 2>/dev/null
find . -maxdepth 1 ! -name 'setup.sh' ! -name 'start.sh' ! -name '.' -exec rm -rf {} +

# 2. 拉取组件与配置
echo -e "${BLUE}[2/3]${RESET} 正在拉取核心组件..."
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html
curl -sL "$RAW_URL/tunnel.yml" -o tunnel.yml

# 3. 启动 Xray 和网页
echo -e "${BLUE}[3/3]${RESET} 后端点火中..."
nohup ./xray -c config.json > node.log 2>&1 &
nohup python3 -m http.server 8085 --bind 0.0.0.0 > /dev/null 2>&1 &

# 4. 暴力提取域名：直接在前台运行 CF 直到抓到域名
echo -e "${YELLOW}🚀 正在强制请求隧道域名 (请稍后 5-10 秒)...${RESET}"
./cf tunnel --config tunnel.yml run > cf.log 2>&1 &

# 关键：这里用一个有限次的循环，如果拿不到就强制打印日志内容
for i in {1..15}; do
    sleep 2
    LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        clear
        echo -e "${GREEN}================================================${RESET}"
        echo -e "✅ ${GREEN}节点启动成功！${RESET}"
        echo -e "${BLUE}------------------------------------------------${RESET}"
        echo -e "🔗 ${YELLOW}隧道域名:${RESET} ${LINK}"
        echo -e "🔑 ${YELLOW}V2box 路径:${RESET} /vbox"
        echo -e "🕒 ${YELLOW}当前时间:${RESET} $(date '+%H:%M:%S')"
        echo -e "${BLUE}------------------------------------------------${RESET}"
        echo "正在进入保活监控模式..."
        sleep 2
        exit 0
    fi
    echo -ne "   ⏳ 正在重试抓取域名... ($((i * 2))s)\r"
done

echo -e "\n❌ 自动抓取失败，请手动查看日志内容："
grep "trycloudflare.com" cf.log
