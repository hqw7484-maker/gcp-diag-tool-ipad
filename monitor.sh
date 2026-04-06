#!/bin/bash
clear
while true; do
    LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' cf.log 2>/dev/null | head -n 1)
    TIME=$(date '+%H:%M:%S')
    printf "\r\033[K"
    echo -ne "\033[36m[iPad Guard]\033[0m 时间: $TIME | 状态: \033[32mACTIVE\033[0m | 链接: $LINK"
    # 模拟文件操作，保持磁盘 IO 活动
    touch .keep_alive
    sleep 60
done
