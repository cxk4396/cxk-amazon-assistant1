# Windows 本地构建脚本
# 以管理员身份运行 PowerShell

Write-Host "🚀 CXK运营决策助手 - Windows本地构建" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# 检查 Node.js
try {
    $nodeVersion = node -v
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js 未安装，请从 https://nodejs.org 下载安装" -ForegroundColor Red
    exit 1
}

# 检查 Rust
try {
    $rustVersion = rustc --version
    Write-Host "✅ Rust: $rustVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Rust 未安装，正在安装..." -ForegroundColor Yellow
    winget install Rustlang.Rustup
    Write-Host "⚠️ 请重启 PowerShell 后重新运行此脚本" -ForegroundColor Yellow
    exit 1
}

# 进入项目目录
$projectRoot = $PSScriptRoot
if (-not $projectRoot) {
    $projectRoot = Get-Location
}
Set-Location $projectRoot

Write-Host ""
Write-Host "📦 步骤1: 安装前端依赖..." -ForegroundColor Cyan
cd frontend
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ npm install 失败" -ForegroundColor Red
    exit 1
}
Write-Host "✅ 前端依赖安装完成" -ForegroundColor Green

Write-Host ""
Write-Host "🔧 步骤2: 安装Tauri CLI..." -ForegroundColor Cyan
cargo install tauri-cli --version "^2.0.0" --locked
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Tauri CLI 可能已安装，继续..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🖼️ 步骤3: 创建应用图标..." -ForegroundColor Cyan
cd ..\src-tauri
if (-not (Test-Path "icons")) {
    New-Item -ItemType Directory -Force -Path "icons" | Out-Null
}

# 创建图标
Add-Type -AssemblyName System.Drawing
$size = 1024
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::FromArgb(255, 153, 0))
$font = New-Object System.Drawing.Font("Arial", 300, [System.Drawing.FontStyle]::Bold)
$brush = [System.Drawing.Brushes]::White
$format = New-Object System.Drawing.StringFormat
$format.Alignment = [System.Drawing.StringAlignment]::Center
$format.LineAlignment = [System.Drawing.StringAlignment]::Center
$g.DrawString("CXK", $font, $brush, $size/2, $size/2, $format)
$bmp.Save("icons/icon.png")
$g.Dispose()
$bmp.Dispose()
Write-Host "✅ 图标创建完成" -ForegroundColor Green

Write-Host ""
Write-Host "🏗️ 步骤4: 生成各种尺寸图标..." -ForegroundColor Cyan
cargo tauri icon icons/icon.png
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ 图标生成可能有问题，但继续构建..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔨 步骤5: 构建应用（首次构建需要10-15分钟）..." -ForegroundColor Cyan
cargo tauri build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 构建失败" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ 构建成功！" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# 查找构建产物
$exePath = "target\release\CXK运营决策助手.exe"
$msiPath = "target\release\bundle\msi\CXK运营决策助手_1.0.0_x64_en-US.msi"
$nsisPath = "target\release\bundle\nsis\CXK运营决策助手_1.0.0_x64-setup.exe"

if (Test-Path $exePath) {
    Write-Host "📍 可执行文件: $projectRoot\$exePath" -ForegroundColor Cyan
}
if (Test-Path $msiPath) {
    Write-Host "📍 MSI安装包: $projectRoot\$msiPath" -ForegroundColor Cyan
}
if (Test-Path $nsisPath) {
    Write-Host "📍 NSIS安装包: $projectRoot\$nsisPath" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "🎉 完成！直接运行EXE或安装包即可使用。" -ForegroundColor Green

# 暂停查看结果
Pause
