#!/bin/bash
clear
# 打印 Logo (只需打印一次)
echo -e "\033[0;36m\033[1m"
echo "    ██╗██████╗  █████╗ ██████╗      ██████╗ ██╗   ██╗ █████╗ ██████╗ "
echo "    ██║██╔══██╗██╔══██╗██╔══██╗    ██╔════╝ ██║   ██║██╔══██╗██╔══██╗"
echo "    ██║██████╔╝███████║██║  ██║    ██║  ███╗██║   ██║███████║██████╔╝"
echo "    ██║██╔═══╝ ██╔══██║██║  ██║    ██║   ██║██║   ██║██╔══██║██╔══██╗"
echo "    ██║██║     ██║  ██║██████╔╝    ╚██████╔╝╚██████╔╝██║  ██║██║  ██║"
echo -e "\033[0m"

while true; do
    TIME=$(date '+%H:%M:%S')
    # 动态抓取，即使 setup 没抓到，monitor 也会一直尝试抓
    LINK=$(grep -oE "https://[a-zA-Z0-9-]+\.trycloudflare\.com" cf.log | head -n 1)
    
    if pgrep -x "xray" > /dev/null; then STATUS="\033[0;32mRUNNING\033[0m"; else STATUS="\033[0;31mSTOPPED\033[0m"; fi

    printf "\r    \033[1m[\033[0;36mSYSTEM\033[0m\033[1m]\033[0m %s | \033[1m[\033[0;36mSTATUS\033[0m\033[1m]\033[0m %s | \033[1m[\033[0;36mURL\033[0m\033[1m]\033[0m \033[0;35m%s\033[0m" "$TIME" "$STATUS" "${LINK:-Searching...}"
    
    touch .keep_alive
    sleep 20
done
