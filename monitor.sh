#!/bin/bash
clear
while true; do
    TIME=$(date '+%H:%M:%S')
    # 再次尝试从日志抓取最新链接，确保显示不为空
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    
    # 找回你原本喜欢的那种漂亮单行仪表盘
    echo -ne "\r\033[1;36m[iPad Guard]\033[0m \033[33m$TIME\033[0m | \033[32mACTIVE\033[0m | \033[35m${LINK:-Searching...}\033[0m"
    
    touch .keep_alive
    sleep 60
done
