#!/bin/bash

# 开发环境运行脚本
flutter run -d chrome \
  --dart-define=ENVIRONMENT=development \
  --dart-define=DEV_API_URL=http://localhost:8080/api/v1