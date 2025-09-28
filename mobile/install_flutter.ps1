# Flutter安装和环境配置脚本

# 1. 安装Chocolatey（如果尚未安装）
Write-Host "检查Chocolatey..." -ForegroundColor Yellow
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "安装Chocolatey..." -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Host "Chocolatey已安装" -ForegroundColor Green
}

# 2. 使用Chocolatey安装Flutter
Write-Host "安装Git..." -ForegroundColor Yellow
choco install git -y

Write-Host "克隆Flutter SDK..." -ForegroundColor Yellow
if (!(Test-Path "C:\flutter")) {
    git clone https://github.com/flutter/flutter.git -b stable C:\flutter
} else {
    Write-Host "Flutter已存在，更新中..." -ForegroundColor Green
    Set-Location C:\flutter
    git pull
}

# 3. 设置环境变量
Write-Host "设置环境变量..." -ForegroundColor Yellow
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*C:\flutter\bin*") {
    [Environment]::SetEnvironmentVariable("Path", $currentPath + ";C:\flutter\bin", "User")
    Write-Host "已添加Flutter到PATH" -ForegroundColor Green
}

# 4. 刷新环境变量
$machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
$env:Path = $machinePath + ";" + $userPath

Write-Host "Flutter安装完成！请重启PowerShell或VS Code，然后运行 'flutter doctor' 检查环境。" -ForegroundColor Green
Write-Host "如果遇到问题，请手动设置环境变量或重启计算机。" -ForegroundColor Yellow