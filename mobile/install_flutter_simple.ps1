# Flutter简易安装脚本 - 修复版本

Write-Host "🚀 Flutter环境设置助手" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green

# 检查是否以管理员身份运行
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "⚠️  请以管理员身份运行PowerShell" -ForegroundColor Yellow
    Write-Host "1. 右键点击PowerShell" -ForegroundColor White
    Write-Host "2. 选择'以管理员身份运行'" -ForegroundColor White
    Read-Host "按Enter键退出"
    exit
}

Write-Host "选择安装方式：" -ForegroundColor White
Write-Host "1. 自动安装（推荐）" -ForegroundColor Cyan
Write-Host "2. 手动下载指导" -ForegroundColor Cyan
Write-Host "3. 跳过安装，直接创建项目" -ForegroundColor Cyan

$choice = Read-Host "请选择 (1-3)"

switch ($choice) {
    "1" {
        Write-Host "开始自动安装..." -ForegroundColor Green
        
        # 下载Flutter
        Write-Host "正在下载Flutter SDK..." -ForegroundColor Yellow
        $flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip"
        $downloadPath = "$env:TEMP\flutter.zip"
        
        try {
            Invoke-WebRequest -Uri $flutterUrl -OutFile $downloadPath
            Write-Host "✅ Flutter下载完成" -ForegroundColor Green
            
            # 解压到C盘
            Write-Host "正在解压Flutter..." -ForegroundColor Yellow
            Expand-Archive -Path $downloadPath -DestinationPath "C:\" -Force
            Write-Host "✅ Flutter解压完成" -ForegroundColor Green
            
            # 设置环境变量
            Write-Host "设置环境变量..." -ForegroundColor Yellow
            $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
            if ($currentPath -notlike "*C:\flutter\bin*") {
                [Environment]::SetEnvironmentVariable("Path", $currentPath + ";C:\flutter\bin", "Machine")
                Write-Host "✅ 环境变量设置完成" -ForegroundColor Green
            }
            
            # 清理下载文件
            Remove-Item $downloadPath -Force
            
            Write-Host "🎉 Flutter安装完成！" -ForegroundColor Green
            Write-Host "请重启PowerShell并运行 'flutter doctor' 检查环境" -ForegroundColor Yellow
            
        } catch {
            Write-Host "❌ 自动安装失败: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "请选择手动安装方式" -ForegroundColor Yellow
        }
    }
    
    "2" {
        Write-Host "📋 手动安装步骤：" -ForegroundColor Green
        Write-Host "1. 访问 https://flutter.dev/docs/get-started/install/windows" -ForegroundColor White
        Write-Host "2. 下载Flutter SDK zip文件" -ForegroundColor White
        Write-Host "3. 解压到 C:\flutter" -ForegroundColor White
        Write-Host "4. 将 C:\flutter\bin 添加到系统PATH环境变量" -ForegroundColor White
        Write-Host "5. 重启PowerShell并运行 'flutter doctor'" -ForegroundColor White
    }
    
    "3" {
        Write-Host "跳过Flutter安装，继续项目创建..." -ForegroundColor Yellow
    }
    
    default {
        Write-Host "无效选择" -ForegroundColor Red
        exit
    }
}

Write-Host "`n按Enter键继续..." -ForegroundColor White
Read-Host