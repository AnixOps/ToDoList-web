#!/bin/bash

# Cloudflare Pages 部署脚本

set -e

echo "🚀 开始部署 ToDoList 前端到 Cloudflare Pages..."

# 检查是否在 frontend 目录
if [ ! -f "package.json" ]; then
    echo "❌ 错误：请在 frontend 目录下运行此脚本"
    exit 1
fi

# 检查是否设置了后端 API 地址
if [ ! -f ".env.production" ]; then
    echo "⚠️  警告：未找到 .env.production 文件"
    echo "请创建 .env.production 文件并设置 VITE_API_BASE_URL"
    echo "示例：VITE_API_BASE_URL=https://your-backend-domain.com/api/v1"
    read -p "是否继续？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 安装依赖
echo "📦 安装依赖..."
npm install

# 构建项目
echo "🔨 构建项目..."
npm run build

# 检查是否安装了 wrangler
if ! command -v wrangler &> /dev/null; then
    echo "📥 安装 wrangler..."
    npm install -g wrangler
fi

# 部署到 Cloudflare Pages
echo "🚀 部署到 Cloudflare Pages..."
npm run deploy

echo "✅ 部署完成！"
echo "🌐 您的应用现在应该已经在 Cloudflare Pages 上运行了"
echo "📝 请确保您的后端 API 已正确部署并配置了 CORS"