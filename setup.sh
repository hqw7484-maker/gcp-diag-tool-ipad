#!/bin/bash
CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[33m'
BOLD='\033[1m'
RESET='\033[0m'

clear
# --- 第一步：带进度展示的物理清场 ---
echo -e "${CYAN}${BOLD}>>> [1/3] 正在执行系统环境深度清理...${RESET}"
tasks=("终结冗余 Xray/CF 进程" "强制释放 8080/8085 端口" "清除残留缓存与日志文件" "重置系统网络句柄")
for i in "${!tasks[@]}"; do
    case $i in
        0) pkill -9 xray; pkill -9 cf; pkill -9 python3 ;;
        1) fuser -k 8080/tcp 8085/tcp 2>/dev/null ;;
        2) rm -f xray cf config.json index.html cf.log node.log ;;
        3) sleep 1 ;;
    esac
    percent=$(( ($i + 1) * 100 / ${#tasks[@]} ))
    echo -e "    ${YELLOW}[${percent}%]${RESET} 正在执行: ${tasks[$i]}..."
    sleep 0.6
done
echo -e "${GREEN}✅ 物理环境重构完成！${RESET}\n"

# --- 第二步：注入核心组件 ---
echo -e "${CYAN}${BOLD}>>> [2/3] 正在注入 Xray-Core 极客驱动...${RESET}"
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 同步资源
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

# --- 第三步：激活智能分流模式 ---
echo -e "${CYAN}${BOLD}>>> [3/3] 启动全流量覆盖分流隧道...${RESET}"
# 网页后置
nohup python3 -m http.server 8085 --bind 127.0.0.1 > /dev/null 2>&1 &
# Xray 前置分流 (解决超时的关键)
nohup ./xray -c config.json > node.log 2>&1 &
sleep 2
# 隧道直连 Xray
nohup ./cf tunnel --url http://127.0.0.1:8080 > cf.log 2>&1 &

# 动态域名打捞
for i in {1..12}; do
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    if [ -n "$LINK" ]; then
        clear
        echo -e "${CYAN}${BOLD}============================================${RESET}"
        echo -e "🚀 ${GREEN}${BOLD}SYSTEM ONLINE | 极客分流已激活${RESET}"
        echo -e "${CYAN}--------------------------------------------${RESET}"
        echo -e "🔗 ${BOLD}ENTRY:${RESET} ${PURPLE}${BOLD}$LINK${RESET}"
        echo -e "📡 ${BOLD}PATH :${RESET} /api/v3/metrics"
        echo -e "✨ ${BOLD}STATE:${RESET} 网页直接显示 | 节点丝滑连通"
        echo -e "${CYAN}============================================${RESET}"
        exit 0
    fi
    echo -ne "   ${YELLOW}⌛ 正在从位流中提取域名... ($((i*3))s)${RESET}\r"
    sleep 3
done
