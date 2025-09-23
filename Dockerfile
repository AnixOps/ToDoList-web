# 使用多阶段构建

# 阶段1: 构建Go后端
FROM golang:1.21-bullseye AS backend-builder

WORKDIR /app/backend

# 更新包管理器并安装必要依赖
RUN apt-get update && apt-get install -y \
    gcc \
    libc6-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# 复制go模块文件
COPY backend/go.mod backend/go.sum ./
RUN go mod download

# 复制源代码
COPY backend/ ./

# 构建应用
RUN CGO_ENABLED=1 GOOS=linux go build -a -o main .

# 阶段2: 构建Vue前端
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

# 阶段3: 最终镜像
FROM debian:bullseye-slim

WORKDIR /app

# 安装运行时依赖
RUN apt-get update && apt-get install -y \
    ca-certificates \
    sqlite3 \
    libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

# 创建非root用户
RUN groupadd -g 1001 todolist && \
    useradd -r -u 1001 -g todolist todolist

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
EXPOSE 3000

# 设置环境变量
ENV GIN_MODE=release

# 运行应用
CMD ["./main"]
