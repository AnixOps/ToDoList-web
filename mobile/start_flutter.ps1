# ToDoList Flutter项目快速启动脚本
# 运行此脚本来快速设置和启动Flutter项目

Write-Host "🚀 ToDoList Flutter项目启动脚本" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# 检查Flutter是否已安装
Write-Host "1. 检查Flutter环境..." -ForegroundColor Yellow
$flutterInstalled = $false

try {
    $null = Get-Command flutter -ErrorAction Stop
    Write-Host "✅ Flutter已安装" -ForegroundColor Green
    flutter --version
    $flutterInstalled = $true
} catch {
    Write-Host "❌ Flutter未安装" -ForegroundColor Red
    
    Write-Host "请选择：" -ForegroundColor Yellow
    Write-Host "1. 运行Flutter安装脚本" -ForegroundColor White
    Write-Host "2. 手动安装Flutter" -ForegroundColor White
    Write-Host "3. 退出" -ForegroundColor White
    
    $installChoice = Read-Host "请选择 (1-3)"
    
    switch ($installChoice) {
        "1" {
            if (Test-Path "install_flutter_simple.ps1") {
                Write-Host "运行Flutter简易安装脚本..." -ForegroundColor Yellow
                .\install_flutter_simple.ps1
                
                Write-Host "请重启PowerShell后重新运行此脚本" -ForegroundColor Yellow
                Read-Host "按Enter键退出"
                exit
            } else {
                Write-Host "找不到安装脚本" -ForegroundColor Red
                exit
            }
        }
        "2" {
            Write-Host "请手动安装Flutter SDK:" -ForegroundColor Yellow
            Write-Host "访问: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Cyan
            Read-Host "按Enter键退出"
            exit
        }
        "3" {
            exit
        }
        default {
            Write-Host "无效选择，退出" -ForegroundColor Red
            exit
        }
    }
}

# 进入项目目录
Write-Host "`n2. 进入项目目录..." -ForegroundColor Yellow
if (!(Test-Path "todolist_mobile")) {
    Write-Host "创建Flutter项目..." -ForegroundColor Yellow
    flutter create todolist_mobile
    Write-Host "✅ 项目创建完成" -ForegroundColor Green
}

Set-Location todolist_mobile

# 检查pubspec.yaml是否存在我们的配置
if (Test-Path "../pubspec.yaml") {
    Write-Host "复制项目配置文件..." -ForegroundColor Yellow
    Copy-Item "../pubspec.yaml" "pubspec.yaml" -Force
    Write-Host "✅ 配置文件已更新" -ForegroundColor Green
}

# 安装依赖
Write-Host "`n3. 安装项目依赖..." -ForegroundColor Yellow
flutter pub get
Write-Host "✅ 依赖安装完成" -ForegroundColor Green

# 检查可用设备
Write-Host "`n4. 检查可用设备..." -ForegroundColor Yellow
flutter devices

# 运行代码生成
Write-Host "`n5. 生成代码文件..." -ForegroundColor Yellow
try {
    flutter packages pub run build_runner build --delete-conflicting-outputs
    Write-Host "✅ 代码生成完成" -ForegroundColor Green
} catch {
    Write-Host "⚠️ 代码生成跳过（可能是首次运行）" -ForegroundColor Yellow
}

Write-Host "`n📱 项目准备就绪！" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host "选择运行方式：" -ForegroundColor White
Write-Host "1. Chrome浏览器（推荐用于开发测试）" -ForegroundColor Cyan
Write-Host "2. Android模拟器" -ForegroundColor Cyan
Write-Host "3. iOS模拟器（需要macOS和Xcode）" -ForegroundColor Cyan
Write-Host "4. 连接的设备" -ForegroundColor Cyan
Write-Host "5. 退出" -ForegroundColor Cyan

do {
    $choice = Read-Host "`n请选择 (1-5)"
    
    switch ($choice) {
        "1" {
            Write-Host "启动Chrome浏览器版本..." -ForegroundColor Green
            flutter run -d chrome
            break
        }
        "2" {
            Write-Host "启动Android模拟器版本..." -ForegroundColor Green
            flutter run -d android
            break
        }
        "3" {
            Write-Host "启动iOS模拟器版本..." -ForegroundColor Green
            flutter run -d ios
            break
        }
        "4" {
            Write-Host "启动设备版本..." -ForegroundColor Green
            flutter run
            break
        }
        "5" {
            Write-Host "退出脚本" -ForegroundColor Yellow
            break
        }
        default {
            Write-Host "无效选择，请重新输入" -ForegroundColor Red
        }
    }
} while ($choice -notin @("1", "2", "3", "4", "5"))

Write-Host "`n开发提示：" -ForegroundColor Green
Write-Host "- 按 'r' 键热重载" -ForegroundColor White
Write-Host "- 按 'R' 键热重启" -ForegroundColor White
Write-Host "- 按 'q' 键退出" -ForegroundColor White
Write-Host "- 使用VS Code Flutter插件获得更好的开发体验" -ForegroundColor White