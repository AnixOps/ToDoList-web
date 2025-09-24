#!/bin/bash

# TodoList Backend Cross-Platform Build Script
# 支持构建 Windows 和 Linux 版本 / Supports building Windows and Linux versions

set -e

# 颜色输出 / Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置 / Configuration
APP_NAME="todolist-backend"
VERSION="${VERSION:-$(date +%Y%m%d-%H%M%S)}"
BUILD_DIR="builds"
SOURCE_DIR="."

# 目标平台配置
declare -A PLATFORMS=(
    ["windows-amd64"]="windows/amd64"
    ["windows-arm64"]="windows/arm64"
    ["linux-amd64"]="linux/amd64"
    ["linux-arm64"]="linux/arm64"
)

# 帮助信息
show_help() {
    echo -e "${BLUE}TodoList Backend 构建脚本${NC}"
    echo ""
    echo "用法: $0 [选项] [平台...]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -c, --clean    构建前清理构建目录"
    echo "  -v, --version  设置版本号 (默认: 当前时间戳)"
    echo "  -a, --all      构建所有平台"
    echo ""
    echo "可用平台:"
    for platform in "${!PLATFORMS[@]}"; do
        echo "  $platform"
    done
    echo ""
    echo "示例:"
    echo "  $0 --all                    # 构建所有平台"
    echo "  $0 windows-amd64 linux-amd64  # 构建指定平台"
    echo "  $0 -c -v 1.0.0 --all        # 清理后构建所有平台，版本号 1.0.0"
}

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

# 检查 Go 环境
check_go() {
    if ! command -v go &> /dev/null; then
        log_error "Go 未安装或不在 PATH 中"
        exit 1
    fi
    
    log_info "Go 版本: $(go version)"
}

# 清理构建目录
clean_build_dir() {
    if [ -d "$BUILD_DIR" ]; then
        log_info "清理构建目录: $BUILD_DIR"
        rm -rf "$BUILD_DIR"
    fi
}

# 创建构建目录
create_build_dir() {
    mkdir -p "$BUILD_DIR"
    log_info "创建构建目录: $BUILD_DIR"
}

# 获取依赖
get_dependencies() {
    log_info "获取 Go 依赖..."
    go mod download
    go mod tidy
}

# 构建单个平台
build_platform() {
    local platform=$1
    local target=${PLATFORMS[$platform]}
    
    if [ -z "$target" ]; then
        log_error "未知平台: $platform"
        return 1
    fi
    
    local os_arch=(${target//\// })
    local target_os=${os_arch[0]}
    local target_arch=${os_arch[1]}
    
    log_info "构建平台: $platform ($target_os/$target_arch)"
    
    # 设置输出文件名
    local output_name="$APP_NAME-$VERSION-$platform"
    if [ "$target_os" = "windows" ]; then
        output_name="$output_name.exe"
    fi
    
    local output_path="$BUILD_DIR/$output_name"
    
    # 设置环境变量并构建
    export GOOS=$target_os
    export GOARCH=$target_arch
    export CGO_ENABLED=0
    
    # 构建时添加版本信息和构建标签
    local ldflags="-w -s -X main.Version=$VERSION -X main.BuildTime=$(date -u +%Y-%m-%dT%H:%M:%SZ) -X main.Platform=$platform"
    
    if go build -ldflags "$ldflags" -o "$output_path" "$SOURCE_DIR"; then
        log_success "构建成功: $output_path"
        
        # 显示文件信息
        local file_size=$(du -h "$output_path" | cut -f1)
        log_info "文件大小: $file_size"
        
        # 创建平台特定的目录并复制相关文件
        local platform_dir="$BUILD_DIR/$platform"
        mkdir -p "$platform_dir"
        cp "$output_path" "$platform_dir/"
        
        # 复制配置文件
        if [ -d "config" ]; then
            cp -r config "$platform_dir/"
            log_info "已复制配置文件到 $platform_dir/"
        fi
        
        # 创建启动脚本
        create_startup_script "$platform_dir" "$output_name" "$target_os"
        
        return 0
    else
        log_error "构建失败: $platform"
        return 1
    fi
}

# 创建启动脚本
create_startup_script() {
    local platform_dir=$1
    local binary_name=$2
    local target_os=$3
    
    if [ "$target_os" = "windows" ]; then
        # Windows 批处理文件
        cat > "$platform_dir/start.bat" << EOF
@echo off
echo Starting TodoList Backend...
echo Version: $VERSION
echo Platform: $target_os
echo.
$binary_name
pause
EOF
        log_info "已创建 Windows 启动脚本: $platform_dir/start.bat"
    else
        # Linux/Unix shell 脚本
        cat > "$platform_dir/start.sh" << 'EOF'
#!/bin/bash
echo "Starting TodoList Backend..."
echo "Version: $VERSION"
echo "Platform: $target_os"
echo ""
./$(basename $binary_name)
EOF
        chmod +x "$platform_dir/start.sh"
        log_info "已创建 Linux 启动脚本: $platform_dir/start.sh"
    fi
}

# 创建 README 文件
create_readme() {
    cat > "$BUILD_DIR/README.md" << EOF
# TodoList Backend 构建文件

## 版本信息
- 版本: $VERSION
- 构建时间: $(date)
- Go 版本: $(go version)

## 文件说明
每个平台目录包含:
- 可执行文件
- config/ 配置目录
- 启动脚本 (start.sh 或 start.bat)

## 使用方法

### Linux
\`\`\`bash
cd linux-amd64/
./start.sh
# 或者直接运行
./$APP_NAME-$VERSION-linux-amd64
\`\`\`

### Windows
\`\`\`cmd
cd windows-amd64/
start.bat
# 或者直接运行
$APP_NAME-$VERSION-windows-amd64.exe
\`\`\`

## 配置
请根据需要修改 config/config.yaml 文件中的配置项。

## 注意事项
- 确保数据库连接配置正确
- 检查端口是否被占用
- 确保有足够的文件权限
EOF
    
    log_success "已创建 README.md"
}

# 显示构建摘要
show_summary() {
    echo ""
    log_success "======== 构建完成 ========"
    echo ""
    echo "构建目录: $BUILD_DIR"
    echo "版本: $VERSION"
    echo ""
    echo "构建的文件:"
    find "$BUILD_DIR" -type f -name "*$APP_NAME*" | while read file; do
        local size=$(du -h "$file" | cut -f1)
        echo "  $file ($size)"
    done
    echo ""
    echo "目录结构:"
    tree "$BUILD_DIR" 2>/dev/null || find "$BUILD_DIR" -type d | sed 's/^/  /'
}

# 主函数
main() {
    local platforms_to_build=()
    local clean_build=false
    local build_all=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--clean)
                clean_build=true
                shift
                ;;
            -v|--version)
                VERSION="$2"
                shift 2
                ;;
            -a|--all)
                build_all=true
                shift
                ;;
            *)
                if [[ "${PLATFORMS[$1]}" ]]; then
                    platforms_to_build+=("$1")
                else
                    log_error "未知参数或平台: $1"
                    show_help
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # 如果没有指定平台且没有 --all，显示帮助
    if [ ${#platforms_to_build[@]} -eq 0 ] && [ "$build_all" = false ]; then
        show_help
        exit 1
    fi
    
    # 如果指定了 --all，构建所有平台
    if [ "$build_all" = true ]; then
        platforms_to_build=($(printf '%s\n' "${!PLATFORMS[@]}" | sort))
    fi
    
    log_info "======== 开始构建 TodoList Backend ========"
    log_info "版本: $VERSION"
    log_info "目标平台: ${platforms_to_build[*]}"
    
    # 检查环境
    check_go
    
    # 清理构建目录
    if [ "$clean_build" = true ]; then
        clean_build_dir
    fi
    
    # 创建构建目录
    create_build_dir
    
    # 获取依赖
    get_dependencies
    
    # 构建各个平台
    local failed_builds=()
    for platform in "${platforms_to_build[@]}"; do
        if ! build_platform "$platform"; then
            failed_builds+=("$platform")
        fi
        echo ""
    done
    
    # 创建 README
    create_readme
    
    # 显示摘要
    show_summary
    
    # 检查是否有失败的构建
    if [ ${#failed_builds[@]} -gt 0 ]; then
        echo ""
        log_warning "以下平台构建失败:"
        for platform in "${failed_builds[@]}"; do
            echo "  - $platform"
        done
        exit 1
    fi
    
    log_success "所有平台构建成功！"
}

# 运行主函数
main "$@"