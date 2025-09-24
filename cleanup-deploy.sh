#!/bin/bash

# 清理deploy分支，移除后端和Docker相关内容
echo "开始清理deploy分支，移除后端和Docker相关内容..."

# 移除后端目录
if [ -d "backend" ]; then
    echo "移除backend目录..."
    git rm -rf backend/
fi

# 移除Docker相关文件
files_to_remove=(
    "Dockerfile"
    "docker-build.sh"
    "docker-compose.prod.yml"
    ".dockerignore"
    "nginx.conf"
    "start.sh"
    "test-release.sh"
    "release-test"
)

for file in "${files_to_remove[@]}"; do
    if [ -e "$file" ]; then
        echo "移除 $file..."
        git rm -rf "$file"
    fi
done

# 创建deploy分支专用的README
cat > README.md << 'EOF'
# ToDoList-web Frontend (Cloudflare Workers)

这是ToDoList-web项目的前端部署分支，专门用于部署到Cloudflare Workers。

## 🚀 快速部署

```bash
cd frontend
npm install
npm run build
npm run deploy
```

## 📖 详细部署指南

请查看 [CLOUDFLARE_DEPLOYMENT.md](./CLOUDFLARE_DEPLOYMENT.md) 获取完整的部署说明。

## 🔗 相关链接

- [主项目仓库](https://github.com/zdwtest/ToDoList-web)
- [后端部署说明](https://github.com/zdwtest/ToDoList-web/blob/main/README.md)

## 📝 分支说明

此分支(`deploy`)专门用于Cloudflare Workers部署：
- 只包含前端代码和相关配置
- 不包含后端代码和Docker配置
- 定期从主分支同步前端变更
EOF

echo "清理完成！"
echo "请运行以下命令提交变更："
echo "git add -A"
echo "git commit -m 'feat: optimize deploy branch for Cloudflare Workers only'"
echo "git push origin deploy"