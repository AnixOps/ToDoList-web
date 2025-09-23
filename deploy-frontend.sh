#!/bin/bash

# 仅部署前端服务的脚本

echo "开始部署 ToDoList 前端服务..."

# 使用前端环境配置
ENV_FILE=".env.frontend"

if [ -f "$ENV_FILE" ]; then
    echo "使用环境配置文件: $ENV_FILE"
    set -a  # 自动导出变量
    source $ENV_FILE
    set +a
else
    echo "警告: 环境配置文件 $ENV_FILE 不存在，使用默认配置"
    export COMPOSE_PROFILES="frontend"
    export DOCKER_USERNAME=${DOCKER_USERNAME:-kalijerry}
    export TAG=${TAG:-dev}
fi

echo "使用配置:"
echo "  Docker Username: ${DOCKER_USERNAME}"
echo "  Tag: ${TAG}"
echo "  Profiles: ${COMPOSE_PROFILES}"
echo "  Frontend Port: ${FRONTEND_PORT:-80}"
echo "  Nginx Config: ${NGINX_CONFIG:-./frontend/nginx.auto.conf}"

# 停止并删除现有容器
echo "停止现有服务..."
docker compose -f docker-compose.unified.yml --env-file $ENV_FILE down

# 拉取最新镜像
echo "拉取最新镜像..."
docker compose -f docker-compose.unified.yml --env-file $ENV_FILE pull

# 启动服务
echo "启动前端服务..."
docker compose -f docker-compose.unified.yml --env-file $ENV_FILE up -d

# 等待服务健康检查
echo "等待服务启动..."
sleep 10

# 检查服务状态
echo "检查服务状态:"
docker compose -f docker-compose.unified.yml --env-file $ENV_FILE ps

echo "前端服务部署完成!"
echo "前端地址: http://localhost:${FRONTEND_PORT:-80}"
echo "健康检查: http://localhost:${FRONTEND_PORT:-80}/health"
echo "API健康检查: http://localhost:${FRONTEND_PORT:-80}/api-health"
echo "网络别名: frontend, web, www"

# 显示日志
echo ""
echo "查看实时日志:"
echo "docker compose -f docker-compose.unified.yml --env-file $ENV_FILE logs -f"