#!/bin/bash
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[33m'
BOLD='\033[1m'
RESET='\033[0m'

clear
# --- [1/3] 物理清场序列 (保留你最爱的仪式感) ---
echo -e "${CYAN}${BOLD}>>> 正在启动系统环境极限净化...${RESET}"
tasks=("中断 Xray/CF 守护进程" "强力解绑 8000/8080/8085 端口" "抹除 Nginx 垃圾残留" "重置 Python 异步环境")
for i in "${!tasks[@]}"; do
    case $i in
        0) pkill -9 xray; pkill -9 cf; pkill -9 nginx; pkill -f gateway.py ;;
        1) fuser -k 8000/tcp 8080/tcp 8085/tcp 2>/dev/null ;;
        2) rm -rf nginx.conf xray cf config.json index.html cf.log gateway.log ;;
        3) sleep 1 ;;
    esac
    percent=$(( ($i + 1) * 100 / ${#tasks[@]} ))
    echo -e "    ${YELLOW}[${percent}%]${RESET} 状态: ${tasks[$i]}..."
    sleep 0.5
done
echo -e "${GREEN}✅ 物理净化完成！${RESET}\n"

# --- [2/3] 核心注入 ---
echo -e "${CYAN}${BOLD}>>> 注入极客核心引擎...${RESET}"
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 同步资源
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

# 编写【暴力分流网关】并带日志记录
cat > gateway.py <<EOF
import socket, select, threading, datetime

def bridge(source, destination):
    while True:
        try:
            data = source.recv(8192)
            if not data: break
            destination.sendall(data)
        except: break

def log_event(msg):
    with open("gateway.log", "a") as f:
        f.write(f"[{datetime.datetime.now().strftime('%H:%M:%S')}] {msg}\n")

def handle_client(client_socket):
    try:
        header = client_socket.recv(4096).decode('utf-8', 'ignore')
        if "/api/v3/metrics" in header:
            log_event("TRAFFIC: NODE-LINK")
            target = socket.create_connection(("127.0.0.1", 8080))
            target.sendall(header.encode())
        else:
            log_event("TRAFFIC: WEB-PAGE")
            target = socket.create_connection(("127.0.0.1", 8085))
            target.sendall(header.encode())
        
        threading.Thread(target=bridge, args=(client_socket, target)).start()
        bridge(target, client_socket)
    except: pass
    finally: client_socket.close()

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind(("127.0.0.1", 8000))
server.listen(100)
while True:
    client, _ = server.accept()
    threading.Thread(target=handle_client, args=(client,)).start()
EOF

# --- [3/3] 激活链路 ---
nohup python3 -m http.server 8085 --bind 127.0.0.1 > /dev/null 2>&1 &
nohup ./xray -c config.json > /dev/null 2>&1 &
nohup python3 gateway.py > /dev/null 2>&1 &
sleep 2
nohup ./cf tunnel --url http://127.0.0.1:8000 > cf.log 2>&1 &

for i in {1..12}; do
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        clear
        echo -e "${CYAN}${BOLD}============================================${RESET}"
        echo -e "🚀 ${GREEN}${BOLD}SYSTEM ONLINE | 暴力分流模式就绪${RESET}"
        echo -e "🔗 ${BOLD}ENTRY :${RESET} $LINK"
        echo -e "✨ ${BOLD}ACTION:${RESET} 请执行 bash monitor.sh 进入监控${RESET}"
        echo -e "${CYAN}============================================${RESET}"
        exit 0
    fi
    echo -ne "   ⌛ 同步链路中... ($((i*3))s)\r"
    sleep 3
done
