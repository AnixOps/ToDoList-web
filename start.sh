#!/bin/bash

# ToDoList 项目启动脚本
# ToDoList Project Startup Script

echo "🚀 Starting ToDoList Application..."
echo "启动 ToDoList 应用..."

# 检查是否在项目根目录
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    echo "错误：请在项目根目录运行此脚本"
    exit 1
fi

# 函数：启动后端服务
start_backend() {
    echo "📦 Starting Backend Service..."
    echo "启动后端服务..."
    
    cd backend
    if [ ! -f "go.mod" ]; then
        echo "❌ Backend go.mod not found"
        exit 1
    fi
    
    # 下载依赖
    go mod download
    
    # 启动后端
    echo "🔧 Starting Go backend on port 8080..."
    go run main.go &
    BACKEND_PID=$!
    echo "Backend PID: $BACKEND_PID"
    cd ..
}

# 函数：启动前端服务
start_frontend() {
    echo "🎨 Starting Frontend Service..."
    echo "启动前端服务..."
    
    cd frontend
    if [ ! -f "package.json" ]; then
        echo "❌ Frontend package.json not found"
        exit 1
    fi
    
    # 安装依赖（如果需要）
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing npm dependencies..."
        npm install
    fi
    
    # 启动前端
    echo "🔧 Starting Vue frontend on port 3000..."
    npm run dev &
    FRONTEND_PID=$!
    echo "Frontend PID: $FRONTEND_PID"
    cd ..
}

# 函数：使用Docker启动
start_docker() {
    echo "🐳 Starting with Docker..."
    echo "使用 Docker 启动..."
    
    # 构建并启动
    docker-compose up --build -d
    
    echo "✅ Services started with Docker"
    echo "Docker 服务启动成功"
    echo "📱 Frontend: http://localhost:8080"
    echo "🔧 Backend API: http://localhost:8080/api/v1"
}

# 函数：显示帮助
show_help() {
    echo "ToDoList Project Startup Script"
    echo ""
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  dev     - Start in development mode (default)"
    echo "  docker  - Start with Docker Compose"
    echo "  help    - Show this help message"
    echo ""
    echo "Development mode starts:"
    echo "  - Backend on port 8080"
    echo "  - Frontend on port 3000"
    echo ""
    echo "Docker mode starts:"
    echo "  - Complete application on port 8080"
}

# 主逻辑
case "${1:-dev}" in
    "dev")
        echo "🔧 Starting in Development Mode..."
        echo "开发模式启动..."
        
        # 启动后端
        start_backend
        sleep 3
        
        # 启动前端
        start_frontend
        sleep 3
        
        echo ""
        echo "✅ Services started successfully!"
        echo "服务启动成功！"
        echo ""
        echo "📱 Frontend: http://localhost:3000"
        echo "🔧 Backend:  http://localhost:8080"
        echo "💚 Health:   http://localhost:8080/api/v1/health"
        echo ""
        echo "Press Ctrl+C to stop all services"
        echo "按 Ctrl+C 停止所有服务"
        
        # 等待用户中断
        trap 'echo ""; echo "🛑 Stopping services..."; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit 0' INT
        wait
        ;;
    "docker")
        start_docker
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "❌ Unknown option: $1"
        show_help
        exit 1
        ;;
esac