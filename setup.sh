#!/bin/bash
# --- 样式定义 ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

# 1. 深度环境消杀
clear
echo -e "${CYAN}${BOLD}>>> [1/3] 正在清理旧环境...${RESET}"
pkill -9 xray; pkill -9 cf; pkill -9 python3; sleep 1
fuser -k 8080/tcp 8085/tcp 2>/dev/null
find . -maxdepth 1 ! -name 'setup.sh' ! -name 'start.sh' ! -name 'monitor.sh' ! -name '.' -exec rm -rf {} +

# 2. 核心组件同步
echo -e "${CYAN}${BOLD}>>> [2/3] 正在拉取组件...${RESET}"
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 3. 资源部署
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

# 4. 点火顺序优化
echo -e "${CYAN}${BOLD}>>> [3/3] 正在激活混合分流隧道...${RESET}"
# 步骤 A: 启动网页后端 (不绑定 127.0.0.1 提高转发成功率)
nohup python3 -m http.server 8085 > /dev/null 2>&1 &
sleep 2

# 步骤 B: 启动 Xray 门户
nohup ./xray -c config.json > node.log 2>&1 &
sleep 1

# 步骤 C: 映射 Xray 端口 (不再需要 YAML)
echo -e "${YELLOW}🚀 正在强制提取隧道链接...${RESET}"
nohup ./cf tunnel --url http://127.0.0.1:8080 > cf.log 2>&1 &

# 5. 链接打捞
for i in {1..12}; do
    sleep 3
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        clear
        echo -e "${CYAN}${BOLD}============================================${RESET}"
        echo -e "🚀 ${GREEN}${BOLD}部署成功！全链路已打通${RESET}"
        echo -e "${CYAN}--------------------------------------------${RESET}"
        echo -e "🔗 ${PURPLE}${BOLD}${LINK}${RESET}"
        echo -e "✨ ${BOLD}提示:${RESET} 网页已复活，V2box 分流已就绪"
        echo -e "${CYAN}============================================${RESET}"
        exit 0
    fi
    echo -ne "   ⌛ 正在重构链路布局... ($((i*3))s)\r"
done
