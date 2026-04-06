#!/bin/bash
while true; do
    LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' cf.log 2>/dev/null | head -n 1)
    TIME=$(date '+%H:%M:%S')
    echo -ne "\r\033[1;36m[iPad Guard]\033[0m \033[33m$TIME\033[0m | \033[32mACTIVE\033[0m | \033[35m$LINK\033[0m"
    touch .keep_alive
    sleep 60
done
