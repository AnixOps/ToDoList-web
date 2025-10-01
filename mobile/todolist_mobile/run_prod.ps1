# Windows PowerShell 生产环境运行脚本
# 
# 使用方法：
# 1. 确保 .env 文件中 ENVIRONMENT=production
# 2. 运行此脚本
#
# 注意：现在配置通过 .env 文件管理，不再需要 --dart-define 参数

Write-Host "🚀 启动生产环境..." -ForegroundColor Green
Write-Host "📝 检查环境配置..." -ForegroundColor Yellow

# 检查 .env 文件是否存在
if (-Not (Test-Path ".env")) {
    Write-Host "❌ 错误: .env 文件不存在" -ForegroundColor Red
    Write-Host "💡 提示: 请先复制 .env.production 为 .env" -ForegroundColor Yellow
    Write-Host "   Copy-Item .env.production .env" -ForegroundColor Cyan
    exit 1
}

# 备份当前 .env
Copy-Item .env .env.backup -Force
Write-Host "✅ 已备份当前配置到 .env.backup" -ForegroundColor Green

# 使用生产环境配置
if (Test-Path ".env.production") {
    Copy-Item .env.production .env -Force
    Write-Host "✅ 已切换到生产环境配置" -ForegroundColor Green
} else {
    Write-Host "⚠️  警告: .env.production 不存在，使用当前 .env 配置" -ForegroundColor Yellow
}

Write-Host "🌐 启动应用..." -ForegroundColor Green
flutter run -d chrome

# 恢复之前的配置
Write-Host "`n🔄 恢复之前的配置..." -ForegroundColor Yellow
Copy-Item .env.backup .env -Force
Remove-Item .env.backup -Force
Write-Host "✅ 配置已恢复" -ForegroundColor Green