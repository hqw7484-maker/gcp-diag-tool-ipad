#!/bin/bash
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

# 1. 清理
clear
echo -e "${CYAN}${BOLD}>>> [1/3] 正在清理环境...${RESET}"
pkill -9 xray; pkill -9 cf; pkill -9 python3; sleep 1
fuser -k 8080/tcp 8085/tcp 2>/dev/null
find . -maxdepth 1 ! -name 'setup.sh' ! -name 'start.sh' ! -name 'monitor.sh' ! -name '.' -exec rm -rf {} +

# 2. 组件下载
echo -e "${CYAN}${BOLD}>>> [2/3] 同步核心组件...${RESET}"
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 3. 配置文件拉取
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

# 4. 点火 (核心：先启动网页，再启动 Xray)
echo -e "${CYAN}${BOLD}>>> [3/3] 正在激活 Hybrid 分流模式...${RESET}"
# 确保监听 127.0.0.1:8085，只允许 Xray 转发进来
nohup python3 -m http.server 8085 --bind 127.0.0.1 > /dev/null 2>&1 &
sleep 1
nohup ./xray -c config.json > node.log 2>&1 &
sleep 1
# 隧道直接挂载到 Xray
nohup ./cf tunnel --url http://127.0.0.1:8080 > cf.log 2>&1 &

# 5. 显示逻辑 (略) ...
for i in {1..12}; do
    sleep 3
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        clear
        echo -e "${CYAN}${BOLD}================================================${RESET}"
        echo -e "🚀 ${GREEN}${BOLD}部署成功！网页白屏已修复${RESET}"
        echo -e "${CYAN}------------------------------------------------${RESET}"
        echo -e "🔗 ${BOLD}访问地址:${RESET} ${PURPLE}${BOLD}${LINK}${RESET}"
        echo -e "🔑 ${BOLD}V2box 路径:${RESET} ${YELLOW}/vbox${RESET}"
        echo -e "✨ ${BOLD}提示:${RESET} 若仍白屏，请刷新浏览器缓存${RESET}"
        echo -e "${CYAN}================================================${RESET}"
        exit 0
    fi
    echo -ne "   ${YELLOW}⌛ 正在打捞域名... ($((i*3))s)${RESET}\r"
done
