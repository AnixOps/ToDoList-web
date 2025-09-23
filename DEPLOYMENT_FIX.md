# 解决nginx找不到后端服务的问题

## 问题描述
在部署后端服务时，前端的nginx配置中引用了 `todolist-backend` 服务，但当只部署后端服务时，nginx启动失败并报错：
```
nginx: [emerg] host not found in upstream "todolist-backend" in /etc/nginx/conf.d/default.conf:14
```

## 问题原因
1. 前端nginx配置文件 `frontend/nginx.conf` 中硬编码了后端服务名 `todolist-backend:8080`
2. 当独立部署前端或后端时，nginx在启动时无法解析到对应的服务名
3. Docker网络中服务名必须在同一个网络中才能相互解析

## 解决方案

### 1. 修改前端nginx配置（已实现）
- 使用动态服务解析，避免nginx启动时的硬性依赖
- 添加错误处理，当后端不可用时返回友好的错误信息
- 设置适当的超时时间

### 2. 创建独立的配置文件（已实现）
- `nginx.standalone.conf`: 用于独立前端部署，不依赖后端服务
- 返回503状态码和说明信息，提示需要配置API端点

### 3. 创建分离的docker-compose文件（已实现）
- `docker-compose.backend.yml`: 仅部署后端服务
- `docker-compose.frontend.yml`: 仅部署前端服务（使用独立配置）
- `docker-compose.prod.yml`: 完整的生产环境部署

### 4. 统一服务命名（已实现）
- 将开发环境的 `backend` 服务名改为 `todolist-backend`
- 确保所有环境中的服务名称一致

### 5. 提供便捷的部署脚本（已实现）
- `deploy-backend.sh`: 一键部署后端服务
- `deploy-frontend.sh`: 一键部署前端服务

## 使用方法

### 仅部署后端
```bash
# 使用脚本
./deploy-backend.sh

# 或手动执行
docker-compose -f docker-compose.backend.yml up -d
```
访问: http://localhost:8080

### 仅部署前端
```bash
# 使用脚本
./deploy-frontend.sh

# 或手动执行
docker-compose -f docker-compose.frontend.yml up -d
```
访问: http://localhost

### 完整部署
```bash
# 生产环境
docker-compose -f docker-compose.prod.yml up -d

# 开发环境
docker-compose up -d
```

## 文件变更清单

### 新增文件
- `docker-compose.backend.yml` - 后端独立部署配置
- `docker-compose.frontend.yml` - 前端独立部署配置
- `frontend/nginx.standalone.conf` - 前端独立nginx配置
- `deploy-backend.sh` - 后端部署脚本
- `deploy-frontend.sh` - 前端部署脚本

### 修改文件
- `frontend/nginx.conf` - 添加动态解析和错误处理
- `docker-compose.yml` - 统一服务命名（backend -> todolist-backend）
- `README.md` - 更新部署文档

## 注意事项
1. 部署脚本需要执行权限（已设置）
2. 独立部署时，前端和后端之间需要通过外部网络通信
3. 生产环境建议使用 `docker-compose.prod.yml`
4. 服务间通信需要确保网络配置正确