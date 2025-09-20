# 使用多阶段构建

# 阶段1: 构建Go后端
FROM golang:1.21-alpine AS backend-builder

WORKDIR /app/backend

# 安装依赖
RUN apk add --no-cache git gcc musl-dev sqlite-dev

# 复制go模块文件
COPY backend/go.mod backend/go.sum ./
RUN go mod download

# 复制源代码
COPY backend/ ./

# 构建应用
RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -o main .

# 阶段2: 构建Vue前端
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

# 复制package文件
COPY frontend/package*.json ./

# 安装依赖
RUN npm ci --only=production

# 复制源代码
COPY frontend/ ./

# 构建前端
RUN npm run build

# 阶段3: 最终镜像
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
    chown -R todolist:todolist /app

# 从构建阶段复制文件
COPY --from=backend-builder /app/backend/main /app/
COPY --from=backend-builder /app/backend/config/config.yaml /app/config/
COPY --from=frontend-builder /app/frontend/dist /app/static/

# 切换到非root用户
USER todolist

# 暴露端口
EXPOSE 8080

# 设置环境变量
ENV GIN_MODE=release

# 运行应用
CMD ["./main"]