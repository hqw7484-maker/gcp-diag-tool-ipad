#!/bin/bash
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[33m'
BOLD='\033[1m'
RESET='\033[0m'

clear
# --- [1/3] 物理清场序列 (找回极客仪式感) ---
echo -e "${CYAN}${BOLD}>>> 正在启动系统环境极限净化...${RESET}"
tasks=("中断 Xray/CF 守护进程" "强力解绑 8000/8085 端口占用" "粉碎残留日志与垃圾文件" "重置 iPadOS 兼容性运行环境")
for i in "${!tasks[@]}"; do
    case $i in
        0) pkill -9 xray; pkill -9 cf; pkill -9 python3 ;;
        1) fuser -k 8000/tcp 8085/tcp 2>/dev/null ;;
        2) rm -rf xray cf config.json index.html cf.log ;;
        3) sleep 1 ;;
    esac
    percent=$(( ($i + 1) * 100 / ${#tasks[@]} ))
    echo -e "    ${YELLOW}[${percent}%]${RESET} 状态: ${tasks[$i]}..."
    sleep 0.5
done
echo -e "${GREEN}✅ 物理环境重构完成！${RESET}\n"

# --- [2/3] 核心组件注入 ---
wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && unzip -o Xray-linux-64.zip xray && chmod +x xray
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cf && chmod +x cf
rm -f Xray-linux-64.zip

# 资源同步
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"
curl -sL "$RAW_URL/config.json" -o config.json
curl -sL "$RAW_URL/index.html" -o index.html

# --- [3/3] 激活三位一体架构 ---
# 1. 网页后端 (8085) - 强制指定目录并无缓冲运行
nohup python3 -u -m http.server 8085 --directory . > /dev/null 2>&1 &
# 2. Xray 入口 (8000) - 负责 V2box + Fallback 网页
nohup ./xray -c config.json > /dev/null 2>&1 &
sleep 2
# 3. 隧道出口 (对准 8000)
nohup ./cf tunnel --url http://127.0.0.1:8000 > cf.log 2>&1 &

LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
echo -e "\n${CYAN}${BOLD}============================================${RESET}"
echo -e "🚀 ${GREEN}${BOLD}SYSTEM ONLINE | 物理关联已就绪${RESET}"
echo -e "🔗 ${BOLD}ENTRY :${RESET} ${YELLOW}$LINK${RESET}"
echo -e "✨ ${BOLD}ACTION:${RESET} 请执行 bash monitor.sh 进入精美监控${RESET}"
echo -e "${CYAN}${BOLD}============================================${RESET}"
