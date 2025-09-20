# 使用多阶段构建

# 阶段1: 构建Vue前端
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

# 复制package文件
COPY frontend/package*.json ./

# 安装所有依赖 (包括开发依赖，构建时需要)
RUN npm ci

# 复制源代码
COPY frontend/ ./

# 构建前端
RUN npm run build

# 阶段2: 最终镜像
FROM alpine:latest

WORKDIR /app

# 安装运行时依赖
RUN apk --no-cache add ca-certificates sqlite

# 创建非root用户
RUN addgroup -g 1001 -S todolist && \
    adduser -S todolist -u 1001

# 创建数据目录
RUN mkdir -p /app/data && \
    mkdir -p /app/static && \
    mkdir -p /app/config && \
    chown -R todolist:todolist /app

# 直接复制预编译的后端二进制文件
COPY backend/builds/todolist-backend-20250920-183325-linux-amd64 /app/main
COPY backend/config/config.yaml /app/config/

# 从构建阶段复制前端文件
COPY --from=frontend-builder /app/frontend/dist /app/static/

# 设置二进制文件权限
RUN chmod +x /app/main

# 切换到非root用户
USER todolist

# 暴露端口
EXPOSE 8080

# 设置环境变量
ENV GIN_MODE=release

# 运行应用
CMD ["./main"]
