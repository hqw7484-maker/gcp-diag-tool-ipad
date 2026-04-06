#!/bin/bash
clear
while true; do
    TIME=$(date '+%H:%M:%S')
    # 动态抓取最新链接
    LINK=$(grep -iE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" | head -n 1)
    
    echo -ne "\r\033[1;36m[iPad Guard]\033[0m \033[33m$TIME\033[0m | \033[32mACTIVE\033[0m | \033[35m${LINK:-Searching...}\033[0m"
    
    touch .keep_alive
    sleep 30
done
