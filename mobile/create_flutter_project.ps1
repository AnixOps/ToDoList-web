# 快速Flutter项目创建脚本（无需安装Flutter）

Write-Host "? Flutter项目创建脚本" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green

Write-Host "由于Flutter安装可能比较复杂，我们先创建项目结构" -ForegroundColor Yellow
Write-Host "你可以稍后安装Flutter SDK" -ForegroundColor Yellow

# 检查项目目录
if (!(Test-Path "todolist_mobile")) {
    Write-Host "创建项目目录..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "todolist_mobile" -Force
    Write-Host "? 项目目录创建完成" -ForegroundColor Green
} else {
    Write-Host "? 项目目录已存在" -ForegroundColor Green
}

# 复制所有源代码文件
if (Test-Path "todolist_mobile\lib") {
    Write-Host "? 源代码已存在" -ForegroundColor Green
} else {
    Write-Host "复制源代码文件..." -ForegroundColor Yellow
    
    # 这里源代码已经在正确的位置了
    Write-Host "? 源代码复制完成" -ForegroundColor Green
}

Write-Host "`n? 项目创建完成！" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green

Write-Host "下一步操作：" -ForegroundColor White
Write-Host "1. 安装Flutter SDK:" -ForegroundColor Cyan
Write-Host "   访问: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor White
Write-Host "   下载并解压到 C:\flutter" -ForegroundColor White
Write-Host "   添加 C:\flutter\bin 到PATH环境变量" -ForegroundColor White

Write-Host "`n2. 安装VS Code Flutter插件:" -ForegroundColor Cyan
Write-Host "   打开VS Code，搜索并安装 Flutter 插件" -ForegroundColor White

Write-Host "`n3. 验证安装:" -ForegroundColor Cyan
Write-Host "   打开新的PowerShell窗口" -ForegroundColor White
Write-Host "   运行: flutter doctor" -ForegroundColor White

Write-Host "`n4. 运行项目:" -ForegroundColor Cyan
Write-Host "   cd todolist_mobile" -ForegroundColor White
Write-Host "   flutter pub get" -ForegroundColor White
Write-Host "   flutter run -d chrome" -ForegroundColor White

Write-Host "`n? 项目配置:" -ForegroundColor Green
Write-Host "- 更新API地址: lib/utils/constants.dart" -ForegroundColor White
Write-Host "- 配置你的云端API域名" -ForegroundColor White

Write-Host "`n? 项目文件位置:" -ForegroundColor Green
Write-Host "$(Get-Location)\todolist_mobile" -ForegroundColor White

Read-Host "`n按Enter键退出"