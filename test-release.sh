#!/bin/bash

# 本地测试发布构建脚本

set -e

VERSION=${1:-"v0.1.0"}
BUILD_DIR="./release-test"

echo "🚀 Testing release build for version: $VERSION"

# 清理之前的构建
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

# 构建后端二进制文件
echo "📦 Building backend binaries..."

cd backend

# Linux AMD64
echo "  Building Linux AMD64..."
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
  -ldflags="-s -w -X main.version=$VERSION -X main.commit=$(git rev-parse --short HEAD) -X main.date=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  -o ../release-test/todolist-backend-$VERSION-linux-amd64 \
  main.go

# Windows AMD64
echo "  Building Windows AMD64..."
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build \
  -ldflags="-s -w -X main.version=$VERSION -X main.commit=$(git rev-parse --short HEAD) -X main.date=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  -o ../release-test/todolist-backend-$VERSION-windows-amd64.exe \
  main.go

cd ..

# 创建发布包结构
echo "📁 Creating release packages..."

# Linux 包
mkdir -p $BUILD_DIR/linux-amd64/config
cp $BUILD_DIR/todolist-backend-$VERSION-linux-amd64 $BUILD_DIR/linux-amd64/
cp backend/config/config.yaml $BUILD_DIR/linux-amd64/config/
cat > $BUILD_DIR/linux-amd64/start.sh << EOF
#!/bin/bash
echo "Starting ToDoList Backend Server..."
chmod +x todolist-backend-$VERSION-linux-amd64
./todolist-backend-$VERSION-linux-amd64
EOF
chmod +x $BUILD_DIR/linux-amd64/start.sh

# Windows 包
mkdir -p $BUILD_DIR/windows-amd64/config
cp $BUILD_DIR/todolist-backend-$VERSION-windows-amd64.exe $BUILD_DIR/windows-amd64/
cp backend/config/config.yaml $BUILD_DIR/windows-amd64/config/
cat > $BUILD_DIR/windows-amd64/start.bat << 'EOF'
@echo off
echo Starting ToDoList Backend Server...
todolist-backend-$VERSION-windows-amd64.exe
pause
EOF

# 创建压缩包
echo "🗜️  Creating archives..."
cd $BUILD_DIR
tar -czf todolist-backend-$VERSION-linux-amd64.tar.gz -C linux-amd64 .
zip -r todolist-backend-$VERSION-windows-amd64.zip windows-amd64/
cd ..

# 测试二进制文件
echo "🧪 Testing binaries..."
echo "  Testing Linux binary version info..."
$BUILD_DIR/todolist-backend-$VERSION-linux-amd64 -version

if command -v wine >/dev/null 2>&1; then
    echo "  Testing Windows binary version info..."
    wine $BUILD_DIR/todolist-backend-$VERSION-windows-amd64.exe -version
else
    echo "  Wine not available, skipping Windows binary test"
fi

# 构建 Docker 镜像（可选）
if [ "$2" == "--docker" ]; then
    echo "🐳 Building Docker images..."
    docker build -t kalijerry/todolist-backend:$VERSION -f backend/Dockerfile.backend backend/
    docker build -t kalijerry/todolist-frontend:$VERSION -f frontend/Dockerfile frontend/
    echo "  Docker images built successfully"
fi

echo "✅ Release build test completed!"
echo ""
echo "📦 Generated files:"
ls -la $BUILD_DIR/*.tar.gz $BUILD_DIR/*.zip 2>/dev/null || true
echo ""
echo "🎯 To create a real release:"
echo "  1. Create and push a tag: git tag $VERSION && git push origin $VERSION"
echo "  2. The GitHub Actions workflow will automatically build and release"