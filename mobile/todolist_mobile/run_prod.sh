#!/bin/bash

# 生产环境运行脚本
flutter run -d chrome \
  --dart-define=ENVIRONMENT=production \
  --dart-define=PROD_API_URL=https://api.todolist.com/api/v1