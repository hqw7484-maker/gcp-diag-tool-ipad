#!/bin/bash
clear
echo -e "\033[0;36m\033[1m"
echo "    ██╗██████╗  █████╗ ██████╗      ██████╗ ██╗   ██╗ █████╗ ██████╗ "
echo "    ██║██╔══██╗██╔══██╗██╔══██╗    ██╔════╝ ██║   ██║██╔══██╗██╔══██╗"
echo "    ██║██████╔╝███████║██║  ██║    ██║  ███╗██║   ██║███████║██████╔╝"
echo "    ██║██╔═══╝ ██╔══██║██║  ██║    ██║   ██║██║   ██║██╔══██║██╔══██╗"
echo "    ██║██║     ██║  ██║██████╔╝    ╚██████╔╝╚██████╔╝██║  ██║██║  ██║"
echo -e "\033[0m"
echo -e "    \033[1;37m─────────────────────────────────────────────────────────────\033[0m"
echo -e "    \033[1mMode:\033[0m Hybrid-Fallback | \033[1mEntry:\033[0m 8080 | \033[1mTarget:\033[0m 8085"
echo -e "    \033[1;37m─────────────────────────────────────────────────────────────\033[0m"
echo ""

while true; do
    TIME=$(date '+%H:%M:%S')
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    
    # 三位一体监控
    if pgrep -x "xray" > /dev/null && pgrep -x "cf" > /dev/null && pgrep -f "python3 -m http.server" > /dev/null; then
        STATUS="\033[0;32mONLINE\033[0m"
    else
        STATUS="\033[0;31mOFFLINE\033[0m"
    fi

    printf "\r    \033[1m[\033[0;36m%s\033[0m\033[1m]\033[0m | \033[1mSTATUS:\033[0m %s | \033[1mURL:\033[0m \033[0;35m%s\033[0m" "$TIME" "$STATUS" "${LINK:-Searching...}"
    
    touch .keep_alive
    sleep 20
done
