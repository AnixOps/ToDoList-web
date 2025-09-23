# 网络别名自动发现部署方案

## 概述

这个方案使用Docker网络别名实现服务间的自动发现，无需手动配置具体的服务名称。所有服务都在同一个`todolist-network`网络中，并且有统一的别名规则。

## 网络别名规则

### 后端服务别名
- `backend` - 主要别名
- `api` - API服务别名
- `todolist-api` - 完整别名
- `todolist-backend` - 服务名称

### 前端服务别名
- `frontend` - 主要别名
- `web` - Web服务别名
- `www` - Web服务别名
- `todolist-frontend` - 服务名称

### 数据库服务别名
- `database` - 主要别名
- `db` - 数据库别名
- `postgres` - PostgreSQL别名

### 缓存服务别名
- `cache` - 主要别名
- `redis` - Redis别名

## 部署场景

### 1. 仅后端部署
```bash
./deploy-backend.sh
```
- 启动后端服务
- 网络别名：`backend`, `api`, `todolist-api`
- 端口：8080

### 2. 仅前端部署
```bash
./deploy-frontend.sh
```
- 启动前端服务
- 自动尝试连接后端别名：`backend:8080`
- 如果后端不可用，返回友好的错误信息
- 端口：80

### 3. 完整部署
```bash
./deploy-full.sh
```
- 启动所有服务（前端、后端、数据库、缓存）
- 所有服务通过别名自动发现
- 包含健康检查和依赖管理

## 配置文件

### .env.backend
仅后端部署的环境配置：
```bash
COMPOSE_PROFILES=backend
DOCKER_USERNAME=kalijerry
TAG=dev
BACKEND_PORT=8080
```

### .env.frontend
仅前端部署的环境配置：
```bash
COMPOSE_PROFILES=frontend
DOCKER_USERNAME=kalijerry
TAG=dev
FRONTEND_PORT=80
NGINX_CONFIG=./frontend/nginx.auto.conf
```

### .env.full
完整部署的环境配置：
```bash
COMPOSE_PROFILES=full
DOCKER_USERNAME=kalijerry
TAG=dev
# 包含所有服务的端口和配置
```

## Nginx配置策略

### nginx.conf
使用简化的`backend:8080`别名，适用于标准部署。

### nginx.auto.conf
智能配置，会尝试多个后端别名：
1. 首先尝试 `backend:8080`
2. 失败时尝试 `api:8080`
3. 最终失败时返回详细错误信息

### nginx.standalone.conf
独立前端配置，不依赖后端服务，返回配置提示。

## 使用优势

1. **自动发现**：无需手动配置具体的服务名称
2. **灵活部署**：支持单独部署或组合部署
3. **容错能力**：智能的错误处理和备用连接
4. **统一管理**：一套配置支持多种部署场景
5. **易于扩展**：新增服务只需添加别名即可

## 命令示例

```bash
# 使用统一配置部署
docker compose -f docker-compose.unified.yml --env-file .env.backend up -d
docker compose -f docker-compose.unified.yml --env-file .env.frontend up -d
docker compose -f docker-compose.unified.yml --env-file .env.full up -d

# 检查服务状态
docker compose -f docker-compose.unified.yml ps

# 查看网络信息
docker network inspect todolist-network

# 进入容器测试连接
docker exec -it todolist-frontend wget -qO- http://backend:8080/health
```

## 故障排除

如果服务无法相互访问：

1. 检查是否在同一网络：
```bash
docker network inspect todolist-network
```

2. 测试网络别名解析：
```bash
docker exec -it todolist-frontend nslookup backend
```

3. 检查服务健康状态：
```bash
docker compose -f docker-compose.unified.yml ps
```

4. 查看服务日志：
```bash
docker compose -f docker-compose.unified.yml logs backend
docker compose -f docker-compose.unified.yml logs frontend
```