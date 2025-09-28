#!/bin/bash

# ToDoList Mobile Flutter项目快速创建脚本

echo "🚀 开始创建ToDoList Flutter项目..."

# 检查Flutter是否已安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未安装，请先安装Flutter"
    echo "Windows: 运行 install_flutter.ps1"
    echo "macOS: brew install flutter"
    echo "Linux: 参考官方文档"
    exit 1
fi

# 检查Flutter环境
echo "🔍 检查Flutter环境..."
flutter doctor

# 创建Flutter项目
echo "📱 创建Flutter项目..."
flutter create todolist_mobile
cd todolist_mobile

# 添加依赖包
echo "📦 添加项目依赖..."
flutter pub add http shared_preferences provider json_annotation cupertino_icons
flutter pub add --dev json_serializable build_runner

# 创建项目结构
echo "📂 创建项目目录结构..."
mkdir -p lib/models
mkdir -p lib/services  
mkdir -p lib/providers
mkdir -p lib/screens
mkdir -p lib/widgets
mkdir -p lib/utils

echo "✅ Flutter项目创建完成！"
echo "📍 项目位置: $(pwd)"
echo "🔧 下一步："
echo "   1. cd todolist_mobile"
echo "   2. flutter pub get"
echo "   3. flutter run"