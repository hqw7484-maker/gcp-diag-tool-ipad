#!/bin/bash
BLUE='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# 1. 环境净化
echo -e "${BLUE}[1/3]${RESET} 深度清理环境..."
pkill -9 xray; pkill -9 cf; pkill -9 python3; sleep 1
fuser -k 8080/tcp 2>/dev/null
fuser -k 8085/tcp 2>/dev/null
find . -maxdepth 1 ! -name 'setup.sh' ! -name 'start.sh' ! -name '.' -exec rm -rf {} +

# 2. 组件下载
echo -e "${BLUE}[2/3]${RESET} 正在拉取核心组件..."
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 3. 配置文件拉取 (确保仓库名带 -ipad)
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html
curl -sL "$RAW_URL/tunnel.yml" -o tunnel.yml

# 4. 点火启动
echo -e "${BLUE}[3/3]${RESET} 启动服务并强制提取域名..."
nohup ./xray -c config.json > node.log 2>&1 &
nohup python3 -m http.server 8085 --bind 0.0.0.0 > /dev/null 2>&1 &
nohup ./cf tunnel --config tunnel.yml run > cf.log 2>&1 &

# 5. 暴力显示链接逻辑
LINK=""
for i in {1..12}; do
    sleep 3
    # 只要包含 trycloudflare.com 就拿出来，不管它前后有什么字符
    LINK=$(grep -iE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" | head -n 1)
    
    if [ -z "$LINK" ]; then
        echo -ne "   ⌛ 正在从日志深处打捞链接... ($((i*3))s)\r"
    else
        clear
        echo -e "${GREEN}================================================${RESET}"
        echo -e "✅ ${GREEN}节点与网页已同步上线！${RESET}"
        echo -e "${BLUE}------------------------------------------------${RESET}"
        echo -e "🔗 ${YELLOW}访问地址:${RESET} ${LINK}"
        echo -e "🔑 ${YELLOW}V2box 路径:${RESET} /vbox"
        echo -e "📡 ${YELLOW}节点位置:${RESET} 自动分配 (通常为亚特兰大)"
        echo -e "${BLUE}------------------------------------------------${RESET}"
        echo "即将进入实时监控模式..."
        sleep 3
        exit 0
    fi
done

echo -e "\n❌ 自动抓取失败，请直接输入命令查看原始日志：cat cf.log"
