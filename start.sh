#!/bin/bash
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"

# 执行部署
curl -sL "$RAW_URL/setup.sh" | bash

# 进入监控
curl -sL "$RAW_URL/monitor.sh" | bash
