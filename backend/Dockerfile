# 使用 Debian 基础镜像避免 Alpine musl libc 问题

# 阶段1: 构建Go后端
FROM golang:1.23-bullseye AS backend-builder

WORKDIR /app/backend

# 更新包管理器并安装必要依赖
RUN apt-get update && apt-get install -y \
    gcc \
    libc6-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# 设置构建环境变量
ENV CGO_ENABLED=1
ENV GOOS=linux
ENV GOARCH=amd64

# 复制go模块文件
COPY go.mod go.sum ./
RUN go mod download

# 复制源代码
COPY . ./

# 构建应用 - 使用简化的构建命令避免标签冲突
RUN go build \
    -ldflags '-w -s' \
    -o main .

# 阶段2: 最终镜像 - 使用轻量级但兼容的基础镜像
FROM debian:bullseye-slim

WORKDIR /app

# 安装运行时依赖
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libsqlite3-0 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 创建非root用户
RUN groupadd -g 1001 todolist && \
    useradd -r -u 1001 -g todolist todolist

# 创建数据目录
RUN mkdir -p /app/data && \
    mkdir -p /app/config && \
    chown -R todolist:todolist /app

# 从构建阶段复制文件
COPY --from=backend-builder /app/backend/main /app/
COPY --from=backend-builder /app/backend/config/config.yaml /app/config/

# 切换到非root用户
USER todolist

# 暴露端口
EXPOSE 8080

# 设置环境变量
ENV GIN_MODE=release

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# 运行应用
CMD ["./main"]