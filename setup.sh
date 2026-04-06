#!/bin/bash
# ==========================================
# iPad GCS 终极部署脚本 (吸收电脑版精华)
# ==========================================

# 1. 深度物理清场
pkill -9 xray; pkill -9 cf; pkill -9 python3; sleep 2
find . -maxdepth 1 ! -name 'setup.sh' ! -name 'start.sh' ! -name 'monitor.sh' ! -name '.' -exec rm -rf {} +

# 2. 静默拉取
echo -e "\033[36m[1/3] 正在拉取核心组件...\033[0m"
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

# 3. 启动后台服务 (网页 8085 / Xray 8080)
echo -e "\033[36m[2/3] 正在激活 Hybrid 分流模式...\033[0m"
# 网页监听所有接口，确保 Xray 转发能进去
nohup python3 -m http.server 8085 > /dev/null 2>&1 &
sleep 2
nohup ./xray -c config.json > node.log 2>&1 &
sleep 1

# 4. 映射 Xray 端口 (免 YAML 模式)
echo -e "\033[33m[3/3] 正在强制打捞临时隧道链接...\033[0m"
nohup ./cf tunnel --url http://127.0.0.1:8080 > cf.log 2>&1 &

# 5. 等待链接喷出
for i in {1..12}; do
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        clear
        echo -e "\n\033[32m✅ === [ 部署完成 ] ===\033[0m"
        echo -e "🔗 \033[1m门面网页:\033[0m \033[36m$LINK\033[0m"
        echo -e "🔑 \033[1m节点路径:\033[0m \033[33m/api/v3/metrics\033[0m"
        echo -e "🚀 \033[35m状态: 网页分流正常，V2box 连接已就绪\033[0m\n"
        exit 0
    fi
    echo -ne "   ⌛ 正在同步链路状态... ($((i*3))s)\r"
    sleep 3
done
