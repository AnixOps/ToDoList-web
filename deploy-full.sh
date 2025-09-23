#!/bin/bash

# 完整部署所有服务的脚本

echo "开始部署 ToDoList 完整服务..."

# 使用完整环境配置
ENV_FILE=".env.full"

if [ -f "$ENV_FILE" ]; then
    echo "使用环境配置文件: $ENV_FILE"
    set -a  # 自动导出变量
    source $ENV_FILE
    set +a
else
    echo "警告: 环境配置文件 $ENV_FILE 不存在，使用默认配置"
    export COMPOSE_PROFILES="full"
    export DOCKER_USERNAME=${DOCKER_USERNAME:-kalijerry}
    export TAG=${TAG:-dev}
fi

echo "使用配置:"
echo "  Docker Username: ${DOCKER_USERNAME}"
echo "  Tag: ${TAG}"
echo "  Profiles: ${COMPOSE_PROFILES}"
echo "  Backend Port: ${BACKEND_PORT:-8080}"
echo "  Frontend Port: ${FRONTEND_PORT:-80}"
echo "  Database Port: ${POSTGRES_PORT:-5432}"
echo "  Cache Port: ${REDIS_PORT:-6379}"

# 停止并删除现有容器
echo "停止现有服务..."
docker compose -f docker-compose.unified.yml --env-file $ENV_FILE down

# 拉取最新镜像
echo "拉取最新镜像..."
docker compose -f docker-compose.unified.yml --env-file $ENV_FILE pull

# 启动服务
echo "启动所有服务..."
docker compose -f docker-compose.unified.yml --env-file $ENV_FILE up -d

# 等待服务健康检查
echo "等待服务启动..."
sleep 15

# 检查服务状态
echo "检查服务状态:"
docker compose -f docker-compose.unified.yml --env-file $ENV_FILE ps

echo ""
echo "==================== 部署完成 ===================="
echo "前端地址: http://localhost:${FRONTEND_PORT:-80}"
echo "后端API: http://localhost:${BACKEND_PORT:-8080}"
echo "数据库: localhost:${POSTGRES_PORT:-5432}"
echo "缓存: localhost:${REDIS_PORT:-6379}"
echo ""
echo "健康检查:"
echo "  前端: http://localhost:${FRONTEND_PORT:-80}/health"
echo "  后端: http://localhost:${BACKEND_PORT:-8080}/health"
echo "  API通过前端: http://localhost:${FRONTEND_PORT:-80}/api-health"
echo ""
echo "网络别名:"
echo "  后端: backend, api, todolist-api"
echo "  前端: frontend, web, www"
echo "  数据库: database, db, postgres"
echo "  缓存: cache, redis"
echo ""
echo "查看实时日志:"
echo "docker compose -f docker-compose.unified.yml --env-file $ENV_FILE logs -f"