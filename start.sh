#!/bin/bash
RAW_URL="https://raw.githubusercontent.com/hqw7484-maker/gcp-diag-tool-ipad/main"

# 1. 执行部署并吐链接
curl -sL "$RAW_URL/setup.sh" | bash

# 2. 只有 setup 成功结束后，才进入保活监控
curl -sL "$RAW_URL/monitor.sh" | bash
