#!/bin/bash
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"

# 1. 彻底清场
pkill -9 xray; pkill -9 cf; pkill -f http.server; pkill -f keepalive.sh; pkill -f monitor.sh

# 2. 部署阶段 (必须等待 setup.sh 拿到域名 exit 0)
echo ">>> 正在执行系统部署 (Setup)..."
curl -sL "$RAW_URL/setup.sh" | bash

# 3. 联动阶段
if [ $? -eq 0 ]; then
    echo ">>> 部署成功，正在同步启动保活与监控..."
    # 后台静默运行你的保活脚本
    curl -sL "$RAW_URL/keepalive.sh" | bash > /dev/null 2>&1 &
    # 前台进入实时监控面板
    curl -sL "$RAW_URL/monitor.sh" | bash
fi
