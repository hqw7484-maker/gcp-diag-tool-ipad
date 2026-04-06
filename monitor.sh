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
echo -e "    \033[1mMode:\033[0m Hybrid Fallback | \033[1mEntry:\033[0m 8080 (Xray) | \033[1mLog:\033[0m cf.log"
echo -e "    \033[1;37m─────────────────────────────────────────────────────────────\033[0m"
echo ""

while true; do
    TIME=$(date '+%H:%M:%S')
    LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
    
    if pgrep -x "xray" > /dev/null && pgrep -x "cf" > /dev/null; then
        STATUS="\033[0;32mONLINE\033[0m"
    else
        STATUS="\033[0;31mOFFLINE\033[0m"
    fi

    printf "\r    \033[1m[\033[0;36mLOG\033[0m\033[1m]\033[0m %s | \033[1m[\033[0;36mSTATUS\033[0m\033[1m]\033[0m %s | \033[1m[\033[0;36mURL\033[0m\033[1m]\033[0m \033[0;35m%s\033[0m" "$TIME" "$STATUS" "${LINK:-Searching...}"
    
    touch .keep_alive
    sleep 20
done
