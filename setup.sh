#!/bin/bash
CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[33m'
BOLD='\033[1m'
RESET='\033[0m'

clear
# --- [1/3] 物理清场序列 ---
echo -e "${CYAN}${BOLD}>>> 正在启动极客环境深度清理序列...${RESET}"
tasks=("终结 Xray/CF 守护进程" "切断 Nginx 与 Python 链路" "释放 8080/8085/8000 端口占用" "擦除所有残留日志与配置")
for i in "${!tasks[@]}"; do
    case $i in
        0) pkill -9 xray; pkill -9 cf ;;
        1) pkill -9 python3; pkill -9 nginx ;;
        2) fuser -k 8080/tcp 8085/tcp 8000/tcp 2>/dev/null ;;
        3) rm -rf nginx.conf xray cf config.json index.html cf.log nginx.pid ;;
    esac
    percent=$(( ($i + 1) * 100 / ${#tasks[@]} ))
    echo -e "    ${YELLOW}[${percent}%]${RESET} 状态: ${tasks[$i]}..."
    sleep 0.5
done
echo -e "${GREEN}✅ 物理环境重构完成！${RESET}\n"

# --- [2/3] 核心组件注入 ---
echo -e "${CYAN}${BOLD}>>> 注入极客核心引擎组件...${RESET}"
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 同步外部资源
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

# 生成 Nginx 精准分流配置文件
# 这是解决“网页白板”和“V2box超时”的工业级方案
cat > nginx.conf <<EOF
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    server {
        listen 127.0.0.1:8000;
        
        # 流量入口：网页端
        location / {
            proxy_pass http://127.0.0.1:8085;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }

        # 流量入口：V2box 节点路径 (WebSocket 强力透传)
        location /api/v3/metrics {
            proxy_redirect off;
            proxy_pass http://127.0.0.1:8080;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host \$host;
        }
    }
}
EOF

# --- [3/3] 启动工业级联运架构 ---
echo -e "${CYAN}${BOLD}>>> 激活智能分流指挥中心...${RESET}"
# 1. 启动网页后端
nohup python3 -m http.server 8085 --bind 127.0.0.1 > /dev/null 2>&1 &
# 2. 启动 Xray 后端
nohup ./xray -c config.json > /dev/null 2>&1 &
# 3. 启动 Nginx 调度员 (监听 8000)
# 针对 GCS 权限限制，使用自定义 PID 文件
/usr/sbin/nginx -c $(pwd)/nginx.conf -g "pid $(pwd)/nginx.pid; daemon off;" > /dev/null 2>&1 &
sleep 3
# 4. 隧道入口对接 Nginx
nohup ./cf tunnel --url http://127.0.0.1:8000 > cf.log 2>&1 &

# 提取链接
for i in {1..15}; do
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        clear
        echo -e "${CYAN}${BOLD}============================================${RESET}"
        echo -e "🚀 ${GREEN}${BOLD}SYSTEM ONLINE | 工业级分流已就绪${RESET}"
        echo -e "${CYAN}--------------------------------------------${RESET}"
        echo -e "🔗 ${BOLD}ENTRY :${RESET} ${PURPLE}${BOLD}$LINK${RESET}"
        echo -e "📡 ${BOLD}PATH  :${RESET} /api/v3/metrics"
        echo -e "✨ ${BOLD}STATUS:${RESET} 节点透传 + 网页渲染 (双路并发)"
        echo -e "${CYAN}============================================${RESET}"
        exit 0
    fi
    echo -ne "   ${YELLOW}⌛ 正在从位流中提取隧道入口... ($((i*2))s)${RESET}\r"
    sleep 2
done
