#!/bin/bash
CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[33m'
BOLD='\033[1m'
RESET='\033[0m'

clear
# --- 第一步：带进度展示的物理清场 ---
echo -e "${CYAN}${BOLD}>>> [1/3] 正在重构系统物理环境...${RESET}"
tasks=("杀掉旧进程" "清理端口占用" "擦除临时文件" "重置日志句柄")
for i in "${!tasks[@]}"; do
    case $i in
        0) pkill -9 xray; pkill -9 cf; pkill -9 python3 ;;
        1) fuser -k 8080/tcp 8085/tcp 2>/dev/null ;;
        2) rm -f xray cf config.json index.html cf.log node.log gateway.py ;;
        3) sleep 1 ;;
    esac
    percent=$(( ($i + 1) * 100 / ${#tasks[@]} ))
    echo -e "    ${YELLOW}[${percent}%]${RESET} 正在执行: ${tasks[$i]}..."
    sleep 0.5
done
echo -e "${GREEN}✅ 环境净化完成！${RESET}\n"

# --- 第二步：驱动注入 ---
echo -e "${CYAN}${BOLD}>>> [2/3] 注入极客核心组件...${RESET}"
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 同步资源
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

# 写入智能转发网关
cat > gateway.py <<EOF
import http.server, socketserver, http.client
class SmartHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/api/v3/metrics':
            self.proxy_request()
        else:
            super().do_GET()
    def proxy_request(self):
        conn = http.client.HTTPConnection("127.0.0.1", 8080)
        conn.request(self.command, self.path, None, {k:v for k,v in self.headers.items()})
        res = conn.getresponse()
        self.send_response(res.status)
        for k,v in res.getheaders(): self.send_header(k,v)
        self.end_headers()
        self.wfile.write(res.read())
with socketserver.TCPServer(("127.0.0.1", 8085), SmartHandler) as httpd:
    httpd.serve_forever()
EOF

# --- 第三步：点火启动 ---
echo -e "${CYAN}${BOLD}>>> [3/3] 启动智能分流隧道...${RESET}"
nohup ./xray -c config.json > node.log 2>&1 &
sleep 1
nohup python3 gateway.py > /dev/null 2>&1 &
sleep 2
nohup ./cf tunnel --url http://127.0.0.1:8085 > cf.log 2>&1 &

# 提取域名反馈
for i in {1..12}; do
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        clear
        echo -e "${CYAN}${BOLD}============================================${RESET}"
        echo -e "🚀 ${GREEN}${BOLD}SYSTEM ONLINE | 极客模式已激活${RESET}"
        echo -e "${CYAN}--------------------------------------------${RESET}"
        echo -e "🔗 ${BOLD}ENTRY:${RESET} ${PURPLE}${BOLD}$LINK${RESET}"
        echo -e "📡 ${BOLD}PATH :${RESET} /api/v3/metrics"
        echo -e "✨ ${BOLD}STATE:${RESET} 网页直接显示 | 节点丝滑连通"
        echo -e "${CYAN}============================================${RESET}"
        exit 0
    fi
    echo -ne "   ${YELLOW}⌛ 正在打捞隧道域名... ($((i*3))s)${RESET}\r"
    sleep 3
done
