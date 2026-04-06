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
echo -e "    \033[1mGuard:\033[0m Active  |  \033[1mMode:\033[0m Dual-Split  |  \033[1mPort:\033[0m 8080"
echo -e "    ─────────────────────────────────────────────────────────────"

LINK=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" cf.log | head -n 1)
echo -e "🔗 \033[1mURL:\033[0m \033[35m${LINK:-Searching...}\033[0m\n"

for i in {1..540}
do
    PERCENT=$(( i * 100 / 540 ))
    BAR=$(printf "%0.s#" $(seq 1 $((PERCENT / 5))))
    STATUS=$(pgrep -x "xray" >/dev/null && echo -e "\033[32mON\033[0m" || echo -e "\033[31mOFF\033[0m")
    printf "\r %s | Progress: [%-20s] %d%% | %d/540min | %s " "$STATUS" "$BAR" "$PERCENT" "$i" "$(date '+%H:%M:%S')"
    [ $((i%5)) -eq 0 ] && echo "" 
    sleep 60
done
