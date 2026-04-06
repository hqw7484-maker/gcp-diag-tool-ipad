#!/bin/bash

# ===== 颜色（极客风）=====
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[33m'
RESET='\033[0m'

echo -e "${CYAN}>>> KEEPALIVE ENGINE STARTED${RESET}"

# ===== 初始化 =====
touch .ka_log .ka_tmp

# ===== 主循环 =====
while true; do
    TIME=$(date '+%H:%M:%S')

    # 1️⃣ 文件写入（核心）
    echo "$TIME alive" >> .ka_log

    # 2️⃣ IO 扰动（防 idle）
    dd if=/dev/zero of=.ka_tmp bs=1K count=10 conv=fsync 2>/dev/null
    rm -f .ka_tmp

    # 3️⃣ 网络心跳（多目标）
    curl -s https://www.cloudflare.com > /dev/null 2>&1
    curl -s https://www.google.com > /dev/null 2>&1

    # 4️⃣ DNS 查询（轻量网络）
    nslookup google.com > /dev/null 2>&1

    # 5️⃣ CPU 微负载（避免完全空闲）
    echo $((RANDOM * RANDOM)) > /dev/null

    # 6️⃣ 触发文件更新时间（关键）
    touch .keepalive_ping

    # ===== UI =====
    echo -ne "${GREEN}[KEEPALIVE]${RESET} $TIME | pulse sent\r"

    sleep 15
done
