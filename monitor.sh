#!/bin/bash
clear
# 还原你最喜欢的简洁头部
echo ">>> IPAD GUARD: 监控启动 <<<"
echo "------------------------------"

LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
echo "入口: ${LINK:-同步中...}"
echo "------------------------------"

for i in {1..540}
do
    # 状态实时检测
    if pgrep -x "xray" > /dev/null && pgrep -x "python3" > /dev/null; then 
        STATUS="ON"
    else 
        STATUS="OFF"
    fi
    
    # 还原你原本的进度条显示方式 (移除 ANSI 颜色代码防止乱码)
    PERCENT=$(( i * 100 / 540 ))
    BAR=$(printf "%0.s#" $(seq 1 $((PERCENT / 5))))
    printf "\r[%-20s] %d%% | %d/540min | Status: %s" "$BAR" "$PERCENT" "$i" "$STATUS"
    
    # 每 5 分钟换行一次，保持界面整洁
    [ $((i%5)) -eq 0 ] && echo ""
    
    touch .keep_alive
    sleep 60
done
