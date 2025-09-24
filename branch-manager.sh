#!/bin/bash

# 分支管理便捷脚本
# Branch Management Utility Script

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 函数：显示帮助信息
show_help() {
    echo "分支管理工具 (Branch Management Tool)"
    echo ""
    echo "用法: $0 [命令] [选项]"
    echo ""
    echo "命令:"
    echo "  status     - 显示所有分支状态"
    echo "  sync-deploy - 同步main分支的前端变更到deploy分支"
    echo "  create-feature <name> - 从dev创建新的功能分支"
    echo "  create-release <version> - 从main创建发布分支"
    echo "  cleanup    - 清理已合并的功能分支"
    echo "  deploy-cf  - 部署到Cloudflare Workers"
    echo "  help       - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 status"
    echo "  $0 create-feature user-auth"
    echo "  $0 create-release v1.0.1"
    echo "  $0 sync-deploy"
    echo "  $0 deploy-cf"
}

# 函数：显示分支状态
show_status() {
    print_message $BLUE "📊 分支状态概览"
    echo ""
    
    print_message $YELLOW "本地分支:"
    git branch
    echo ""
    
    print_message $YELLOW "远程分支:"
    git branch -r
    echo ""
    
    print_message $YELLOW "最近提交历史:"
    git log --oneline --graph --all -10
    echo ""
    
    print_message $YELLOW "各分支提交差异:"
    echo "dev领先main的提交:"
    git log main..dev --oneline | head -5
    echo ""
    echo "main领先release的提交:"
    latest_release=$(git branch -r | grep "origin/release" | sort -V | tail -1 | xargs)
    if [ ! -z "$latest_release" ]; then
        git log ${latest_release}..main --oneline | head -5
    else
        echo "未找到release分支"
    fi
}

# 函数：同步deploy分支
sync_deploy() {
    print_message $BLUE "🔄 同步main分支前端变更到deploy分支"
    
    # 确保当前在deploy分支
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "deploy" ]; then
        print_message $YELLOW "切换到deploy分支..."
        git checkout deploy
    fi
    
    # 拉取最新的远程变更
    print_message $YELLOW "拉取远程变更..."
    git pull origin deploy
    git pull origin main
    
    # 合并main分支的前端变更
    print_message $YELLOW "合并main分支变更..."
    if git merge main --no-edit; then
        print_message $GREEN "✅ 成功合并main分支变更"
        
        # 推送到远程
        read -p "是否推送到远程仓库? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push origin deploy
            print_message $GREEN "✅ 已推送到远程deploy分支"
        fi
    else
        print_message $RED "❌ 合并失败，请手动解决冲突"
        exit 1
    fi
}

# 函数：创建功能分支
create_feature() {
    local feature_name=$1
    if [ -z "$feature_name" ]; then
        print_message $RED "❌ 请提供功能分支名称"
        echo "用法: $0 create-feature <feature-name>"
        exit 1
    fi
    
    print_message $BLUE "🌿 创建功能分支: feature/$feature_name"
    
    # 切换到dev分支并拉取最新变更
    git checkout dev
    git pull origin dev
    
    # 创建新的功能分支
    git checkout -b "feature/$feature_name"
    
    print_message $GREEN "✅ 已创建功能分支 feature/$feature_name"
    print_message $YELLOW "开发完成后请使用以下命令合并到dev分支:"
    echo "  git checkout dev"
    echo "  git merge feature/$feature_name"
    echo "  git push origin dev"
}

# 函数：创建发布分支
create_release() {
    local version=$1
    if [ -z "$version" ]; then
        print_message $RED "❌ 请提供版本号"
        echo "用法: $0 create-release <version> (例如: v1.0.1)"
        exit 1
    fi
    
    print_message $BLUE "🚀 创建发布分支: release/$version"
    
    # 切换到main分支并拉取最新变更
    git checkout main
    git pull origin main
    
    # 创建发布分支
    git checkout -b "release/$version"
    
    print_message $GREEN "✅ 已创建发布分支 release/$version"
    print_message $YELLOW "发布流程:"
    echo "  1. 进行必要的bug修复"
    echo "  2. 创建标签: git tag $version"
    echo "  3. 推送分支和标签:"
    echo "     git push origin release/$version"
    echo "     git push origin $version"
}

# 函数：清理分支
cleanup_branches() {
    print_message $BLUE "🧹 清理已合并的功能分支"
    
    # 显示已合并的分支
    merged_branches=$(git branch --merged dev | grep -E "feature/|fix/" | grep -v "\*" || true)
    
    if [ -z "$merged_branches" ]; then
        print_message $GREEN "✅ 没有需要清理的分支"
        return
    fi
    
    print_message $YELLOW "以下分支已合并到dev，可以删除:"
    echo "$merged_branches"
    echo ""
    
    read -p "是否删除这些分支? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$merged_branches" | xargs -n 1 git branch -d
        print_message $GREEN "✅ 已删除合并的功能分支"
    fi
    
    # 清理远程跟踪分支
    print_message $YELLOW "清理过期的远程跟踪分支..."
    git remote prune origin
    print_message $GREEN "✅ 已清理远程跟踪分支"
}

# 函数：部署到Cloudflare Workers
deploy_cloudflare() {
    print_message $BLUE "☁️  部署到Cloudflare Workers"
    
    # 确保在deploy分支
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "deploy" ]; then
        print_message $YELLOW "切换到deploy分支..."
        git checkout deploy
        git pull origin deploy
    fi
    
    # 检查frontend目录
    if [ ! -d "frontend" ]; then
        print_message $RED "❌ 未找到frontend目录"
        exit 1
    fi
    
    cd frontend
    
    # 安装依赖
    print_message $YELLOW "安装依赖..."
    npm install
    
    # 构建项目
    print_message $YELLOW "构建项目..."
    npm run build
    
    # 部署
    print_message $YELLOW "部署到Cloudflare Workers..."
    if npm run deploy; then
        print_message $GREEN "✅ 成功部署到Cloudflare Workers"
    else
        print_message $RED "❌ 部署失败"
        exit 1
    fi
}

# 主逻辑
case "${1:-help}" in
    "status")
        show_status
        ;;
    "sync-deploy")
        sync_deploy
        ;;
    "create-feature")
        create_feature "$2"
        ;;
    "create-release")
        create_release "$2"
        ;;
    "cleanup")
        cleanup_branches
        ;;
    "deploy-cf")
        deploy_cloudflare
        ;;
    "help"|*)
        show_help
        ;;
esac