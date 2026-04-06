#!/bin/bash
# 1. 环境清理
pkill -9 xray; pkill -9 cf; pkill -9 python3; rm -rf xray cf node.log cf.log tunnel.yml; sleep 1

# 2. 拉取组件
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf

# 3. 拉取新仓库配置
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

# 4. 启动后端
nohup ./xray -c config.json > node.log 2>&1 &
nohup python3 -m http.server 8085 --bind 0.0.0.0 > /dev/null 2>&1 &

# 5. 创建针对 iPad 分流的配置
cat > tunnel.yml <<EOF
ingress:
  - hostname: "*"
    path: /vbox
    service: http://127.0.0.1:8080
  - hostname: "*"
    service: http://127.0.0.1:8085
EOF

# 6. 开启隧道
nohup ./cf tunnel --config tunnel.yml run > cf.log 2>&1 &

echo "正在生成隧道链接..."
sleep 8
LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' cf.log | head -n 1)
echo "------------------------------------------------"
echo -e "✅ 部署成功！"
echo -e "🔗 诊断网页: $LINK"
echo -e "🔑 V2box 路径: /vbox"
echo "------------------------------------------------"
