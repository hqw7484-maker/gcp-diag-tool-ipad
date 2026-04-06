#!/bin/bash
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"

# 步骤 1: 部署
curl -sL "$RAW_URL/setup.sh" | bash

# 步骤 2: 启动守护
curl -sL "$RAW_URL/monitor.sh" | bash
