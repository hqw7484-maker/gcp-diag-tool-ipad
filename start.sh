#!/bin/bash
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"

# 1. 暴力清理残留 (防止端口占用导致超时)
pkill -9 xray; pkill -9 cf; pkill -f http.server; pkill -f keepalive.sh; pkill -f monitor.sh
fuser -k 8080/tcp 8085/tcp 2>/dev/null

# 2. 执行部署脚本
curl -sL "$RAW_URL/setup.sh?v=$(date +%s)" | bash

# 3. 稳态保活联动
if [ $? -eq 0 ]; then
    echo ">>> 正在启动保活脉冲..."
    # 下载到本地运行，确保进程名可被 pgrep 识别
    curl -sL "$RAW_URL/keepalive.sh?v=$(date +%s)" -o keepalive.sh
    chmod +x keepalive.sh
    nohup ./keepalive.sh > /dev/null 2>&1 &
    
    # 前台进入实时诊断面板
    curl -sL "$RAW_URL/monitor.sh?v=$(date +%s)" | bash
fi
