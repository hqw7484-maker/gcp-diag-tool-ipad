#!/bin/bash
clear
echo -e "\033[1;36m>>> IPAD GUARD: 监控启动 <<<\033[0m\n"

for i in {1..540}
do
    PERCENT=$(( i * 100 / 540 ))
    BAR=$(printf "%0.s#" $(seq 1 $((PERCENT / 5))))
    # 极简状态检测
    STATUS=$(pgrep -x "xray" >/dev/null && echo "ON" || echo "OFF")
    
    printf "\r [%-20s] %d%% | %d/540min | Status: %s" "$BAR" "$PERCENT" "$i" "$STATUS"
    
    [ $((i%5)) -eq 0 ] && echo "" 
    sleep 60
done
