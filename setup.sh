#!/bin/bash
# ==========================================
# GCS iPad 最终版：物理消杀 + 循环抓取
# ==========================================

echo "正在执行物理清场..."
pkill -9 xray; pkill -9 cf; pkill -9 python3; sleep 1
fuser -k 8080/tcp 2>/dev/null
fuser -k 8085/tcp 2>/dev/null
# 彻底清理残留 (保留脚本本身)
find . -maxdepth 1 ! -name 'setup.sh' ! -name 'start.sh' ! -name '.' -exec rm -rf {} +

echo "正在拉取核心组件..."
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 同步配置 (请确保仓库名正确)
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html
curl -sL "$RAW_URL/tunnel.yml" -o tunnel.yml

echo "后端服务启动中..."
nohup ./xray -c config.json > node.log 2>&1 &
nohup python3 -m http.server 8085 --bind 0.0.0.0 > /dev/null 2>&1 &

echo "正在激活隧道并循环检测链接..."
nohup ./cf tunnel --config tunnel.yml run > cf.log 2>&1 &

# 循环抓取逻辑：每 5 秒看一次，最多等 40 秒
MAX_RETRIES=8
RETRY_COUNT=0
LINK=""

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    sleep 5
    LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        break
    fi
    echo "获取中... ($(( (RETRY_COUNT + 1) * 5 ))s)"
    RETRY_COUNT=$((RETRY_COUNT + 1))
done

if [ -z "$LINK" ]; then
    echo "❌ 失败：链接未生成。请手动运行: grep -o 'https://[-0-9a-z]*\.trycloudflare.com' cf.log"
else
    clear
    echo -e "\n\033[32m=== [ 部署完成 | 网页与节点已对齐 ] ===\033[0m"
    echo -e "🔗 \033[1m诊断链接:\033[0m \033[36m$LINK\033[0m"
    echo -e "🔑 \033[1mV2box 路径:\033[0m \033[33m/vbox\033[0m"
    echo -e "🕒 \033[1m环境已纯净化，保活模式开启中\033[0m\n"
fi
