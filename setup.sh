#!/bin/bash
clear
echo ">>> 系统环境物理净化中..."
pkill -9 xray; pkill -9 cf; pkill -9 python3
fuser -k 8080/tcp 8085/tcp 2>/dev/null
rm -rf xray cf config.json index.html cf.log tunnel.yml
echo "[100%] 环境已净化"

# 注入组件
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 资源同步
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/index.html" -o index.html

# 编写隧道分流配置文件 (物理分流的核心)
cat > tunnel.yml <<EOF
ingress:
  - path: /api/v3/metrics
    service: http://localhost:8080
  - service: http://localhost:8085
EOF

# 激活
nohup python3 -m http.server 8085 --bind 127.0.0.1 > /dev/null 2>&1 &
nohup ./xray -c config.json > /dev/null 2>&1 &
sleep 2
# 使用配置文件模式启动，彻底解决阻塞
nohup ./cf tunnel --config tunnel.yml run --url http://localhost:8085 > cf.log 2>&1 &

echo "⌛ 正在同步物理链路..."
for i in {1..15}; do
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        echo "============================================"
        echo "🚀 物理并行架构已就绪"
        echo "🔗 域名: $LINK"
        echo "============================================"
        exit 0
    fi
    sleep 2
done
