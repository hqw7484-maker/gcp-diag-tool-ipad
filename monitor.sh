#!/bin/bash
clear
echo -e "\033[0;36m\033[1m"
echo "    ██╗██████╗  █████╗ ██████╗      ██████╗ ██╗   ██╗ █████╗ ██████╗ "
echo "    ██║██╔══██╗██╔══██╗██╔══██╗    ██╔════╝ ██║   ██║██╔══██╗██╔══██╗"
echo "    ██║██████╔╝███████║██║  ██║    ██║  ███╗██║   ██║███████║██████╔╝"
echo "    ██║██╔═══╝ ██╔══██║██║  ██║    ██║   ██║██║   ██║██╔══██║██╔══██╗"
echo "    ██║██║     ██║  ██║██████╔╝    ╚██████╔╝╚██████╔╝██║  ██║██║  ██║"
echo -e "\033[0m"
echo -e "    ─────────────────────────────────────────────────────────────"
echo -e "    \033[1mGuard:\033[0m Active  |  \033[1mMode:\033[0m Nginx-Reverse | \033[1mUptime:\033[0m 540M"
echo -e "    ─────────────────────────────────────────────────────────────"

LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
echo -e "🔗 \033[1mURL:\033[0m \033[0;35m${LINK:-Searching...}\033[0m"
echo ""

for i in {1..540}
do
    PERCENT=$(( i * 100 / 540 ))
    BAR=$(printf "%0.s#" $(seq 1 $((PERCENT / 5))))
    # 双路状态监测：必须 Xray 和 Nginx 都活着
    if pgrep -x "xray" > /dev/null && pgrep -f "nginx" > /dev/null; then
        STATUS="\033[32mHEALTHY\033[0m"
    else
        STATUS="\033[31mCRITICAL\033[0m"
    fi

    printf "\r %s | \033[1mProgress:\033[0m [%-20s] %d%% | %d/540min | %s " "$STATUS" "$BAR" "$PERCENT" "$i" "$(date '+%H:%M:%S')"
    
    [ $((i%5)) -eq 0 ] && echo "" 
    touch .keep_alive
    sleep 60
done
