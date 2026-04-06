#!/bin/bash
clear
echo -e "\033[0;36m\033[1m"
echo "    ██╗██████╗  █████╗ ██████╗      ██████╗ ██╗   ██╗ █████╗ ██████╗ "
echo "    ██║██╔══██╗██╔══██╗██╔══██╗    ██╔════╝ ██║   ██║██╔══██╗██╔══██╗"
echo "    ██║██████╔╝███████║██║  ██║    ██║  ███╗██║   ██║███████║██████╔╝"
echo "    ██║██╔═══╝ ██╔══██║██║  ██║    ██║   ██║██║   ██║██╔══██║██╔══██╗"
echo "    ██║██║     ██║  ██║██████╔╝    ╚██████╔╝╚██████╔╝██║  ██║██║  ██║"
echo -e "\033[0m"
echo -e "    \033[1;37m─────────────────────────────────────────────────────────────\033[0m"
echo -e "    \033[1mGuard:\033[0m Active  |  \033[1mMode:\033[0m Xray-Fallback  |  \033[1mEntry:\033[0m 8080"
echo -e "    \033[1;37m─────────────────────────────────────────────────────────────\033[0m"

# 实时提取当前域名
LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
echo -e "🔗 \033[1mURL:\033[0m \033[35m${LINK:-Searching...}\033[0m"
echo ""

for i in {1..540}
do
    # 极客进度条计算
    PERCENT=$(( i * 100 / 540 ))
    BAR=$(printf "%0.s#" $(seq 1 $((PERCENT / 5))))
    
    # 状态检测：必须 Xray、Cloudflare 和 Python 都在线才算 OK
    if pgrep -x "xray" > /dev/null && pgrep -x "cf" > /dev/null && pgrep -f "http.server" > /dev/null; then
        STATUS="\033[32mOK\033[0m"
    else
        STATUS="\033[31mKO\033[0m"
    fi

    # 打印单行状态
    printf "\r %s | \033[1mProgress:\033[0m [%-20s] %d%% | %d/540min | %s " "$STATUS" "$BAR" "$PERCENT" "$i" "$(date '+%H:%M:%S')"
    
    # 每 5 分钟换行，保持日志可追溯
    [ $((i%5)) -eq 0 ] && echo "" 
    
    touch .keep_alive
    sleep 60
done
