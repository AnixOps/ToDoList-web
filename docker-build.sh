#!/bin/bash

# TodoList Docker 构建和发布脚本 / TodoList Docker Build and Release Script
# 用于本地构建和推送到Docker Hub / For local building and pushing to Docker Hub

set -e

# 颜色输出 / Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置 / Configuration
DEFAULT_USERNAME="zdwtest"
DEFAULT_TAG="latest"

# 从命令行参数或环境变量获取配置
DOCKER_USERNAME="${1:-${DOCKER_USERNAME:-$DEFAULT_USERNAME}}"
TAG="${2:-${TAG:-$DEFAULT_TAG}}"
REGISTRY="${REGISTRY:-docker.io}"

# 镜像名称
BACKEND_IMAGE="$REGISTRY/$DOCKER_USERNAME/todolist-backend:$TAG"
FRONTEND_IMAGE="$REGISTRY/$DOCKER_USERNAME/todolist-frontend:$TAG"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 帮助信息
show_help() {
    echo -e "${BLUE}TodoList Docker 构建和发布脚本${NC}"
    echo ""
    echo "用法: $0 [Docker用户名] [标签]"
    echo ""
    echo "参数:"
    echo "  Docker用户名  Docker Hub用户名 (默认: $DEFAULT_USERNAME)"
    echo "  标签         镜像标签 (默认: $DEFAULT_TAG)"
    echo ""
    echo "环境变量:"
    echo "  DOCKER_USERNAME  Docker Hub用户名"
    echo "  TAG             镜像标签"
    echo "  REGISTRY        镜像仓库地址 (默认: docker.io)"
    echo ""
    echo "示例:"
    echo "  $0                          # 使用默认配置"
    echo "  $0 myuser v1.0.0           # 指定用户名和标签"
    echo "  TAG=latest $0 myuser       # 使用环境变量"
}

# 检查Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装或不在 PATH 中"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker 守护进程未运行"
        exit 1
    fi
    
    log_info "Docker 版本: $(docker --version)"
}

# 检查登录状态
check_docker_login() {
    log_info "检查 Docker Hub 登录状态..."
    
    if ! docker info | grep -q "Username"; then
        log_warning "未登录到 Docker Hub"
        log_info "请运行: docker login"
        read -p "是否现在登录? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker login
        else
            log_error "需要登录到 Docker Hub 才能推送镜像"
            exit 1
        fi
    else
        log_success "已登录到 Docker Hub"
    fi
}

# 构建后端镜像
build_backend() {
    log_info "构建后端镜像: $BACKEND_IMAGE"
    
    cd backend
    docker build -t "$BACKEND_IMAGE" .
    cd ..
    
    log_success "后端镜像构建完成"
}

# 构建前端镜像
build_frontend() {
    log_info "构建前端镜像: $FRONTEND_IMAGE"
    
    cd frontend
    docker build -t "$FRONTEND_IMAGE" .
    cd ..
    
    log_success "前端镜像构建完成"
}

# 推送镜像
push_images() {
    log_info "推送镜像到 Docker Hub..."
    
    log_info "推送后端镜像..."
    docker push "$BACKEND_IMAGE"
    
    log_info "推送前端镜像..."
    docker push "$FRONTEND_IMAGE"
    
    log_success "所有镜像推送完成"
}

# 显示镜像信息
show_image_info() {
    echo ""
    log_success "======== 构建完成 ========"
    echo ""
    echo "后端镜像: $BACKEND_IMAGE"
    echo "前端镜像: $FRONTEND_IMAGE"
    echo ""
    echo "镜像大小:"
    docker images | grep -E "(todolist-backend|todolist-frontend)" | grep "$TAG"
    echo ""
    echo "使用方法:"
    echo "1. 创建 .env 文件:"
    echo "   cp .env.example .env"
    echo "   # 编辑 .env 文件中的配置"
    echo ""
    echo "2. 启动服务:"
    echo "   docker-compose -f docker-compose.prod.yml up -d"
    echo ""
    echo "3. 查看日志:"
    echo "   docker-compose -f docker-compose.prod.yml logs -f"
}

# 清理本地镜像
cleanup() {
    read -p "是否清理本地构建的镜像? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "清理本地镜像..."
        docker rmi "$BACKEND_IMAGE" "$FRONTEND_IMAGE" 2>/dev/null || true
        log_success "清理完成"
    fi
}

# 主函数
main() {
    # 检查帮助参数
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi
    
    log_info "======== TodoList Docker 构建开始 ========"
    log_info "Docker用户名: $DOCKER_USERNAME"
    log_info "标签: $TAG"
    log_info "仓库: $REGISTRY"
    
    # 检查环境
    check_docker
    check_docker_login
    
    # 构建镜像
    build_backend
    build_frontend
    
    # 推送镜像
    push_images
    
    # 显示信息
    show_image_info
    
    # 可选清理
    cleanup
    
    log_success "所有操作完成！"
}

# 运行主函数
main "$@"