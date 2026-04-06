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
echo -e "    \033[1mGuard:\033[0m Active  |  \033[1mMode:\033[0m Smart-Gateway  |  \033[1mEngine:\033[0m iPad-OS"
echo -e "    \033[1;37m─────────────────────────────────────────────────────────────\033[0m"

# 动态抓取域名
LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
echo -e "🔗 \033[1mURL:\033[0m \033[0;35m${LINK:-Searching...}\033[0m"
echo ""

# 540 分钟核心监控
for i in {1..540}
do
    # 联锁检测
    if pgrep -x "xray" > /dev/null && pgrep -x "cf" > /dev/null && pgrep -f "gateway.py" > /dev/null; then
        STATUS="\033[32mRUNNING\033[0m"
    else
        STATUS="\033[31mOFFLINE\033[0m"
    fi

    # 计算进度条
    PERCENT=$(( i * 100 / 540 ))
    BAR=$(printf "%0.s#" $(seq 1 $((PERCENT / 5))))
    
    # 极客风格单行输出
    printf "\r %s | \033[1mProgress:\033[0m [%-20s] %d%% | %d/540min | %s " "$STATUS" "$BAR" "$PERCENT" "$i" "$(date '+%H:%M:%S')"
    
    # 每 5 分钟产生一个心跳换行
    [ $((i%5)) -eq 0 ] && echo "" 
    touch .keep_alive
    sleep 60
done
