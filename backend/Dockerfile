# 使用多阶段构建 - 后端专用

# 阶段1: 构建Go后端
FROM golang:1.21-alpine AS backend-builder

WORKDIR /app/backend

# 安装必要的构建依赖
RUN apk add --no-cache \
    git \
    gcc \
    musl-dev \
    sqlite-dev \
    build-base

# 设置构建环境变量
ENV CGO_ENABLED=1
ENV GOOS=linux
ENV GOARCH=amd64

# 复制go模块文件
COPY go.mod go.sum ./
RUN go mod download

# 复制源代码
COPY . ./

# 构建应用 - 使用静态链接避免musl libc问题
RUN go build \
    -ldflags '-linkmode external -extldflags "-static"' \
    -a -installsuffix cgo \
    -o main .

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