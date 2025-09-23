#!/bin/bash

# 分支关系修复脚本
# Fix Branch Relationship Issues

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_message $BLUE "🔧 开始修复分支关系问题"
echo ""

# 1. 检查当前状态
print_message $YELLOW "1. 检查当前分支状态..."
git status
echo ""

# 2. 备份当前状态
print_message $YELLOW "2. 创建备份标签..."
current_time=$(date +"%Y%m%d-%H%M%S")
git tag "backup-before-merge-$current_time" HEAD
print_message $GREEN "✅ 创建备份标签: backup-before-merge-$current_time"
echo ""

# 3. 切换到main分支并拉取最新
print_message $YELLOW "3. 切换到main分支..."
git checkout main
git pull origin main
echo ""

# 4. 检查dev分支的改进
print_message $YELLOW "4. 显示dev分支的改进内容..."
echo "Dev分支相对于main的文件差异:"
git diff main..dev --name-only
echo ""

# 5. 询问用户确认
print_message $YELLOW "准备将dev分支的改进合并到main分支"
print_message $YELLOW "这将包括:"
echo "  - 完整的Docker配置文件"
echo "  - 部署脚本和环境配置"
echo "  - 改进的nginx配置"
echo "  - 网络别名处理改进"
echo ""

read -p "是否继续合并? 输入 'YES' 确认: " -r
if [[ ! $REPLY == "YES" ]]; then
    print_message $RED "❌ 用户取消操作"
    exit 1
fi

# 6. 合并dev到main
print_message $YELLOW "5. 合并dev分支到main..."
if git merge dev --no-ff -m "feat: merge latest Docker improvements and deployment features from dev

- Add comprehensive Docker configuration files  
- Include deployment scripts and environment configs
- Update nginx configurations with better proxy handling
- Improve network alias handling and service discovery
- Add dynamic frontend configuration support
- Include multiple deployment strategies (backend-only, frontend-only, full)

This merge brings dev branch improvements into main to establish
proper branch hierarchy where main contains stable, complete features."; then
    print_message $GREEN "✅ 成功合并dev分支到main"
else
    print_message $RED "❌ 合并失败，请手动解决冲突"
    echo "冲突解决后，请运行:"
    echo "  git add ."
    echo "  git commit"
    echo "  然后重新运行此脚本"
    exit 1
fi

# 7. 推送main分支
print_message $YELLOW "6. 推送main分支..."
read -p "是否推送main分支到远程? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git push origin main
    print_message $GREEN "✅ 已推送main分支到远程"
fi

# 8. 重置dev分支到main
print_message $YELLOW "7. 重置dev分支到main (清理历史)..."
git checkout dev
git reset --hard main
print_message $GREEN "✅ dev分支已重置到main"

read -p "是否推送dev分支? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git push origin dev --force-with-lease
    print_message $GREEN "✅ 已推送dev分支到远程"
fi

# 9. 更新deploy分支
print_message $YELLOW "8. 更新deploy分支..."
git checkout deploy

# 检查是否需要同步main的前端变更
print_message $YELLOW "检查是否需要同步main的前端变更到deploy分支..."

# 比较main分支的frontend目录和deploy分支的frontend目录
if git diff main deploy --quiet -- frontend/ 2>/dev/null || true; then
    print_message $GREEN "✅ deploy分支的前端代码已是最新"
else
    print_message $YELLOW "需要同步main分支的前端变更..."
    read -p "是否同步前端变更到deploy分支? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # 只合并frontend相关的变更
        git checkout main -- frontend/ || true
        git add frontend/
        if git diff --staged --quiet; then
            print_message $GREEN "✅ 前端代码无变更"
        else
            git commit -m "feat: sync frontend changes from main branch

- Update frontend code to match main branch
- Ensure deploy branch has latest frontend features
- Maintain deploy branch focus on Cloudflare Workers deployment"
            git push origin deploy
            print_message $GREEN "✅ 已同步前端变更到deploy分支"
        fi
    fi
fi

# 10. 显示最终状态
print_message $BLUE "🎉 分支修复完成！"
echo ""
print_message $YELLOW "最终分支状态:"
git branch -a
echo ""

print_message $YELLOW "各分支最新提交:"
echo "Main分支:"
git log --oneline main -3
echo ""
echo "Dev分支:"  
git log --oneline dev -3
echo ""
echo "Deploy分支:"
git log --oneline deploy -3
echo ""

print_message $GREEN "✅ 分支关系已修复！"
print_message $YELLOW "现在的分支层次结构:"
echo "  main   - 稳定的生产代码 (包含所有功能)"
echo "  dev    - 开发分支 (基于main，用于新功能开发)"  
echo "  deploy - 纯前端部署分支 (Cloudflare Workers专用)"
echo "  release/x.x.x - 发布分支 (从main创建)"

echo ""
print_message $BLUE "备份标签: backup-before-merge-$current_time"
print_message $YELLOW "如需回滚，可使用: git reset --hard backup-before-merge-$current_time"