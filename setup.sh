#!/bin/bash
clear
echo -e "\033[36m>>> 正在清场重构环境...\033[0m"
pkill -9 xray; pkill -9 cf; pkill -9 python3
rm -rf xray cf config.json index.html cf.log
echo -e "    [100%] 物理清场完毕！"

# 下载核心
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf

# 拉取配置
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

# 暴力启动
nohup python3 -m http.server 8085 --bind 127.0.0.1 > /dev/null 2>&1 &
nohup ./xray -c config.json > /dev/null 2>&1 &
sleep 2
nohup ./cf tunnel --url http://127.0.0.1:8000 > cf.log 2>&1 &

LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
echo -e "\n\033[32m🚀 系统已上线：\033[0m $LINK"
