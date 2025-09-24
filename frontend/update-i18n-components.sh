#!/bin/bash

# 多语言组件更新脚本
# Multilingual Components Update Script

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

print_message $BLUE "🌐 开始更新组件多语言支持"
echo ""

# 需要更新的组件列表
COMPONENTS=(
    "src/views/Register.vue"
    "src/views/Profile.vue" 
    "src/components/TaskPanel.vue"
    "src/components/EventDialog.vue"
)

# 检查文件是否存在
check_file_exists() {
    local file=$1
    if [ ! -f "$file" ]; then
        print_message $RED "❌ 文件不存在: $file"
        return 1
    fi
    return 0
}

# 备份文件
backup_file() {
    local file=$1
    local backup_file="${file}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$file" "$backup_file"
    print_message $YELLOW "📋 已备份: $file -> $backup_file"
}

# 为组件添加 useI18n 导入
add_i18n_import() {
    local file=$1
    if grep -q "useI18n" "$file"; then
        print_message $YELLOW "⏭️  $file 已包含 useI18n 导入"
        return 0
    fi
    
    # 在 script setup 后添加 useI18n 导入
    if grep -q "import.*vue.*" "$file"; then
        sed -i '/import.*vue.*/a import { useI18n } from '\''vue-i18n'\''' "$file"
        print_message $GREEN "✅ 已添加 useI18n 导入到 $file"
    else
        print_message $YELLOW "⚠️  无法自动添加导入到 $file，请手动添加"
    fi
}

# 添加 t 函数解构
add_t_function() {
    local file=$1
    if grep -q "const.*t.*=.*useI18n" "$file"; then
        print_message $YELLOW "⏭️  $file 已包含 t 函数"
        return 0
    fi
    
    # 在 setup 函数开始后添加
    if grep -q "const.*useRouter\|const.*useAuthStore\|const.*useTodoStore" "$file"; then
        sed -i '0,/const.*use/{s/const.*use.*/const { t } = useI18n()\n&/;}' "$file"
        print_message $GREEN "✅ 已添加 t 函数到 $file"
    else
        print_message $YELLOW "⚠️  无法自动添加 t 函数到 $file，请手动添加"
    fi
}

# 创建常用翻译键值对列表
create_translation_guide() {
    cat << 'EOF' > translation_guide.md
# 常用翻译键值对参考

## 通用翻译
- 确定 -> {{ $t('common.ok') }}
- 取消 -> {{ $t('common.cancel') }}
- 保存 -> {{ $t('common.save') }}
- 删除 -> {{ $t('common.delete') }}
- 编辑 -> {{ $t('common.edit') }}
- 加载中 -> {{ $t('common.loading') }}

## 认证相关
- 用户名 -> {{ $t('auth.username') }}
- 密码 -> {{ $t('auth.password') }}
- 登录 -> {{ $t('auth.login') }}
- 注册 -> {{ $t('auth.register') }}

## 待办事项相关
- 待办事项 -> {{ $t('todo.title') }}
- 添加待办 -> {{ $t('todo.addTodo') }}
- 编辑待办 -> {{ $t('todo.editTodo') }}
- 完成 -> {{ $t('todo.completed') }}
- 待处理 -> {{ $t('todo.pending') }}

## 个人资料相关
- 个人资料 -> {{ $t('profile.title') }}
- 个人信息 -> {{ $t('profile.personalInfo') }}
- 修改密码 -> {{ $t('profile.changePassword') }}

## 使用方法
1. 在模板中使用: {{ $t('key.name') }}
2. 在脚本中使用: t('key.name')
3. 动态参数: {{ $t('key.name', { param: value }) }}
EOF
    print_message $GREEN "📝 已创建翻译指南: translation_guide.md"
}

# 主要更新流程
main() {
    print_message $BLUE "🔍 检查前端目录..."
    
    if [ ! -d "frontend" ]; then
        print_message $RED "❌ 未找到 frontend 目录"
        exit 1
    fi
    
    cd frontend
    
    print_message $YELLOW "📋 准备更新以下组件:"
    for component in "${COMPONENTS[@]}"; do
        echo "  - $component"
    done
    echo ""
    
    read -p "是否继续? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message $YELLOW "❌ 用户取消操作"
        exit 0
    fi
    
    # 为每个组件添加多语言支持
    for component in "${COMPONENTS[@]}"; do
        print_message $BLUE "📝 处理组件: $component"
        
        if check_file_exists "$component"; then
            backup_file "$component"
            add_i18n_import "$component"
            add_t_function "$component"
            print_message $GREEN "✅ 完成处理: $component"
        else
            print_message $YELLOW "⏭️  跳过不存在的组件: $component"
        fi
        echo ""
    done
    
    # 创建翻译指南
    create_translation_guide
    
    print_message $BLUE "🎉 多语言支持更新完成！"
    echo ""
    print_message $YELLOW "📋 后续步骤:"
    echo "1. 手动检查各组件的 import 语句"
    echo "2. 将硬编码文本替换为 \$t() 函数调用"  
    echo "3. 参考 translation_guide.md 进行翻译"
    echo "4. 运行 npm run build 测试构建"
    echo "5. 测试各语言切换功能"
    echo ""
    print_message $GREEN "🚀 准备就绪，可以开始手动翻译工作！"
}

# 执行主函数
main "$@"