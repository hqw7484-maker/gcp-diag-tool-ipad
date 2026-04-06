#!/bin/bash
clear
echo -e "\033[36m"
echo "################################################"
echo "#          iPad Guard - 9H 持续运行中          #"
echo "################################################"
echo -e "\033[0m"

# 实时提取域名
LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
echo -e "🔗 \033[1m当前域名:\033[0m \033[32m${LINK:-未检测到}\033[0m"
echo -e "🕒 \033[1m启动时间:\033[0m $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "------------------------------------------------"

# 540 分钟核心监控
for i in {1..540}
do
    # 状态检测
    if pgrep -x "xray" > /dev/null && pgrep -x "cf" > /dev/null; then
        STATUS="\033[32mONLINE\033[0m"
    else
        STATUS="\033[31mOFFLINE\033[0m"
    fi

    # 计算进度条 (你的原创逻辑)
    PERCENT=$(( i * 100 / 540 ))
    BAR=$(printf "%0.s#" $(seq 1 $((PERCENT / 5))))
    SPACES=$(printf "%0.s " $(seq 1 $((20 - PERCENT / 5))))

    printf "\r%s | [%-20s] %d%% | %d/540min | %s " "$STATUS" "$BAR" "$PERCENT" "$i" "$(date '+%H:%M:%S')"
    
    # 周期性换行防止终端假死
    if [ $((i%5)) -eq 0 ]; then echo ""; fi
    
    touch .keep_alive
    sleep 60
done
