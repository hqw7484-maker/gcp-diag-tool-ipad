#!/bin/bash
clear
while true; do
    # 每次循环重新抓取，防止域名变动，同时增加错误检查
    LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' cf.log | head -n 1)
    TIME=$(date '+%H:%M:%S')
    
    # 漂亮、直观的单行仪表盘
    echo -ne "\r\033[1;36m[iPad Guard]\033[0m \033[33m$TIME\033[0m | \033[32mACTIVE\033[0m | \033[35m${LINK:-Waiting...}\033[0m"
    
    touch .keep_alive
    sleep 30
done
