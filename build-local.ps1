# CXK运营决策助手 - Windows 本地一键构建脚本
# 以管理员身份运行 PowerShell

param(
    [switch]$SkipIcon = $false,
    [switch]$SkipBuild = $false
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "Continue"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     CXK运营决策助手 - Windows 本地构建脚本            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# 获取项目根目录
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $projectRoot) {
    $projectRoot = Get-Location
}
Set-Location $projectRoot

Write-Host "📁 项目目录: $projectRoot" -ForegroundColor Gray
Write-Host ""

# ==================== 步骤 1: 环境检查 ====================
Write-Host "🔍 步骤 1/5: 检查环境依赖..." -ForegroundColor Yellow

# 检查 Node.js
try {
    $nodeVersion = node -v 2>$null
    if ($nodeVersion) {
        Write-Host "   ✅ Node.js: $nodeVersion" -ForegroundColor Green
    } else {
        throw "Node.js not found"
    }
} catch {
    Write-Host "   ❌ Node.js 未安装" -ForegroundColor Red
    Write-Host "      请从 https://nodejs.org/ 下载安装 LTS 版本" -ForegroundColor Yellow
    exit 1
}

# 检查 Rust
try {
    $rustVersion = rustc --version 2>$null
    if ($rustVersion) {
        Write-Host "   ✅ Rust: $rustVersion" -ForegroundColor Green
    } else {
        throw "Rust not found"
    }
} catch {
    Write-Host "   ⚠️ Rust 未安装，正在安装..." -ForegroundColor Yellow
    Write-Host "      执行: winget install Rustlang.Rustup" -ForegroundColor Gray
    try {
        winget install Rustlang.Rustup --accept-package-agreements --accept-source-agreements
        Write-Host "      ✅ Rust 安装完成，请重启 PowerShell 后重新运行此脚本" -ForegroundColor Green
    } catch {
        Write-Host "      ❌ Rust 安装失败，请手动安装: https://rustup.rs/" -ForegroundColor Red
    }
    exit 1
}

# 检查 cargo
try {
    $cargoVersion = cargo --version 2>$null
    Write-Host "   ✅ Cargo: $cargoVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Cargo 未找到" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ==================== 步骤 2: 安装依赖 ====================
Write-Host "📦 步骤 2/5: 安装前端依赖..." -ForegroundColor Yellow

if (-not (Test-Path "$projectRoot\frontend\package.json")) {
    Write-Host "   ❌ 找不到 frontend/package.json" -ForegroundColor Red
    exit 1
}

Set-Location "$projectRoot\frontend"

try {
    Write-Host "   正在执行 npm install..." -ForegroundColor Gray
    npm install 2>&1 | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
    
    if ($LASTEXITCODE -ne 0) {
        throw "npm install failed with exit code $LASTEXITCODE"
    }
    Write-Host "   ✅ 前端依赖安装完成" -ForegroundColor Green
} catch {
    Write-Host "   ❌ npm install 失败: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ==================== 步骤 3: 生成图标 ====================
if (-not $SkipIcon) {
    Write-Host "🎨 步骤 3/5: 生成应用图标..." -ForegroundColor Yellow
    
    Set-Location $projectRoot
    
    # 创建图标目录
    $iconsDir = "$projectRoot\src-tauri\icons"
    if (-not (Test-Path $iconsDir)) {
        New-Item -ItemType Directory -Force -Path $iconsDir | Out-Null
        Write-Host "   📁 创建图标目录" -ForegroundColor Gray
    }
    
    # 生成图标
    try {
        Write-Host "   正在生成 1024x1024 图标..." -ForegroundColor Gray
        
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        
        $size = 1024
        $bmp = New-Object System.Drawing.Bitmap($size, $size)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        
        # 橙色背景
        $g.Clear([System.Drawing.Color]::FromArgb(255, 153, 0))
        
        # 白色文字
        $font = New-Object System.Drawing.Font("Arial", 300, [System.Drawing.FontStyle]::Bold)
        $brush = [System.Drawing.Brushes]::White
        $format = New-Object System.Drawing.StringFormat
        $format.Alignment = [System.Drawing.StringAlignment]::Center
        $format.LineAlignment = [System.Drawing.StringAlignment]::Center
        
        $g.DrawString("CXK", $font, $brush, $size/2, $size/2, $format)
        
        $iconPath = "$iconsDir\icon.png"
        $bmp.Save($iconPath, [System.Drawing.Imaging.ImageFormat]::Png)
        
        $g.Dispose()
        $bmp.Dispose()
        $font.Dispose()
        
        Write-Host "   ✅ 图标已生成: $iconPath" -ForegroundColor Green
        
        # 生成各种尺寸的图标
        Write-Host "   正在生成各种尺寸图标..." -ForegroundColor Gray
        
        # 检查是否已安装 tauri-cli
        $tauriCli = cargo install --list | Select-String "tauri-cli"
        if (-not $tauriCli) {
            Write-Host "   📦 安装 Tauri CLI..." -ForegroundColor Gray
            cargo install tauri-cli --version "^2.0.0" --locked 2>&1 | ForEach-Object { 
                if ($_ -match "error|warning|Installed") { Write-Host "      $_" -ForegroundColor DarkGray }
            }
        }
        
        Set-Location "$projectRoot\src-tauri"
        cargo tauri icon icons/icon.png 2>&1 | ForEach-Object {
            if ($_ -match "error|warning|Generated|Complete") { Write-Host "      $_" -ForegroundColor DarkGray }
        }
        
        Write-Host "   ✅ 图标生成完成" -ForegroundColor Green
        
    } catch {
        Write-Host "   ⚠️ 图标生成失败，将使用默认图标: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "🎨 步骤 3/5: 跳过图标生成 (--SkipIcon)" -ForegroundColor Gray
}

Write-Host ""

# ==================== 步骤 4: 构建应用 ====================
if (-not $SkipBuild) {
    Write-Host "🔨 步骤 4/5: 构建 Tauri 应用..." -ForegroundColor Yellow
    Write-Host "   ⚠️ 首次构建需要 10-20 分钟，请耐心等待..." -ForegroundColor Magenta
    Write-Host ""
    
    Set-Location $projectRoot
    
    try {
        # 执行构建
        cargo tauri build 2>&1 | ForEach-Object {
            # 过滤输出，只显示重要信息
            if ($_ -match "Compiling|Finished|Running|Building|Generating|Complete|bundle|error\[|warning:") {
                if ($_ -match "error\[") {
                    Write-Host "   ❌ $_" -ForegroundColor Red
                } elseif ($_ -match "warning:") {
                    Write-Host "   ⚠️  $_" -ForegroundColor Yellow
                } else {
                    Write-Host "   $_" -ForegroundColor Gray
                }
            }
        }
        
        if ($LASTEXITCODE -ne 0) {
            throw "Build failed with exit code $LASTEXITCODE"
        }
        
        Write-Host ""
        Write-Host "   ✅ 构建成功!" -ForegroundColor Green
        
    } catch {
        Write-Host ""
        Write-Host "   ❌ 构建失败: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "   常见解决方案:" -ForegroundColor Yellow
        Write-Host "   1. 确保已安装 Visual Studio Build Tools (使用 C++ 的桌面开发)" -ForegroundColor White
        Write-Host "   2. 运行: winget install Microsoft.VisualStudio.2022.BuildTools" -ForegroundColor White
        Write-Host "   3. 重启 PowerShell 后重试" -ForegroundColor White
        exit 1
    }
} else {
    Write-Host "🔨 步骤 4/5: 跳过构建 (--SkipBuild)" -ForegroundColor Gray
}

Write-Host ""

# ==================== 步骤 5: 输出结果 ====================
Write-Host "📋 步骤 5/5: 构建产物..." -ForegroundColor Yellow

$bundleDir = "$projectRoot\src-tauri\target\release\bundle"
$exePath = "$projectRoot\src-tauri\target\release\CXK运营决策助手.exe"

$foundFiles = @()

# 查找 MSI
$msiPath = Get-ChildItem -Path "$bundleDir\msi" -Filter "*.msi" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($msiPath) {
    $foundFiles += @{ Type = "MSI 安装包"; Path = $msiPath.FullName; Size = "$([math]::Round($msiPath.Length/1MB, 2)) MB" }
}

# 查找 NSIS
$nsisPath = Get-ChildItem -Path "$bundleDir\nsis" -Filter "*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($nsisPath) {
    $foundFiles += @{ Type = "EXE 安装包"; Path = $nsisPath.FullName; Size = "$([math]::Round($nsisPath.Length/1MB, 2)) MB" }
}

# 查找直接运行的 EXE
if (Test-Path $exePath) {
    $exeFile = Get-Item $exePath
    $foundFiles += @{ Type = "可直接运行"; Path = $exePath; Size = "$([math]::Round($exeFile.Length/1MB, 2)) MB" }
}

if ($foundFiles.Count -eq 0) {
    Write-Host "   ⚠️ 未找到构建产物" -ForegroundColor Yellow
    Write-Host "      可能构建未完成或路径错误" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "   ✅ 找到以下构建产物:" -ForegroundColor Green
    Write-Host ""
    foreach ($file in $foundFiles) {
        Write-Host "   📦 $($file.Type)" -ForegroundColor Cyan
        Write-Host "      路径: $($file.Path)" -ForegroundColor White
        Write-Host "      大小: $($file.Size)" -ForegroundColor Gray
        Write-Host ""
    }
}

# 完成
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              🎉 构建完成!                            ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

if ($foundFiles.Count -gt 0) {
    Write-Host "💡 使用方式:" -ForegroundColor Yellow
    Write-Host "   - MSI/EXE 安装包: 双击安装后使用" -ForegroundColor White
    Write-Host "   - 直接运行 EXE: 无需安装，双击即可" -ForegroundColor White
    Write-Host ""
}

Write-Host "📖 更多帮助: QUICK_START.md" -ForegroundColor Gray
Write-Host ""

# 暂停查看结果
Pause
