# Windows PowerShell 开发环境运行脚本
# 
# 使用方法：
# 1. 确保 .env 文件中 ENVIRONMENT=development
# 2. 运行此脚本
#
# 注意：现在配置通过 .env 文件管理，不再需要 --dart-define 参数

Write-Host "🚀 启动开发环境..." -ForegroundColor Green
Write-Host "📝 检查环境配置..." -ForegroundColor Yellow

# 检查 .env 文件是否存在
if (-Not (Test-Path ".env")) {
    Write-Host "❌ 错误: .env 文件不存在" -ForegroundColor Red
    Write-Host "💡 提示: 请先复制 .env.example 为 .env" -ForegroundColor Yellow
    Write-Host "   Copy-Item .env.example .env" -ForegroundColor Cyan
    exit 1
}

Write-Host "✅ 配置文件检查完成" -ForegroundColor Green
Write-Host "🌐 启动应用..." -ForegroundColor Green

# 启动应用（默认使用 Chrome）
flutter run -d chrome