#!/bin/bash

# 仅部署前端服务的脚本

echo "开始部署 ToDoList 前端服务..."

# 设置默认值
export DOCKER_USERNAME=${DOCKER_USERNAME:-zdwtest}
export TAG=${TAG:-latest}

# 检查环境变量
if [ -z "$DOCKER_USERNAME" ]; then
    echo "警告: DOCKER_USERNAME 未设置，使用默认值: zdwtest"
fi

if [ -z "$TAG" ]; then
    echo "警告: TAG 未设置，使用默认值: latest"
fi

echo "使用配置:"
echo "  Docker Username: $DOCKER_USERNAME"
echo "  Tag: $TAG"

# 停止并删除现有容器
echo "停止现有服务..."
docker-compose -f docker-compose.frontend.yml down

# 拉取最新镜像
echo "拉取最新镜像..."
docker-compose -f docker-compose.frontend.yml pull

# 启动服务
echo "启动前端服务..."
docker-compose -f docker-compose.frontend.yml up -d

# 等待服务健康检查
echo "等待服务启动..."
sleep 10

# 检查服务状态
echo "检查服务状态:"
docker-compose -f docker-compose.frontend.yml ps

echo "前端服务部署完成!"
echo "前端地址: http://localhost"
echo "健康检查: http://localhost/health"

# 显示日志
echo ""
echo "查看实时日志:"
echo "docker-compose -f docker-compose.frontend.yml logs -f"