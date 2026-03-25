# CXK运营决策助手 - Windows一键部署脚本
# 使用方法: 右键以管理员身份运行 PowerShell，然后执行:
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
# .\deploy-windows.ps1

param(
    [switch]$Dev,      # 开发模式
    [switch]$Build,    # 构建模式
    [switch]$Check     # 仅检查环境
)

# 设置错误处理
$ErrorActionPreference = "Stop"

# 颜色定义
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"

function Write-Info($msg) { Write-Host "${Blue}[INFO]${Reset} $msg" }
function Write-Success($msg) { Write-Host "${Green}[✓]${Reset} $msg" }
function Write-Error($msg) { Write-Host "${Red}[✗]${Reset} $msg" }
function Write-Warning($msg) { Write-Host "${Yellow}[!]${Reset} $msg" }

# 标题
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  CXK运营决策助手 - Windows部署脚本" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否为管理员
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Warning "建议以管理员身份运行此脚本，以避免权限问题"
    Write-Host ""
}

# 检查项目路径是否包含中文
$currentPath = Get-Location
if ($currentPath.Path -match '[\u4e00-\u9fa5]') {
    Write-Error "项目路径包含中文字符，可能导致编译失败！"
    Write-Info "当前路径: $($currentPath.Path)"
    Write-Info "建议移动到纯英文路径，如: C:\projects\cxk-amazon-assistant\"
    exit 1
}

Write-Info "项目路径: $($currentPath.Path)"
Write-Host ""

# ==================== 环境检查 ====================

Write-Host "------------------------------------------" -ForegroundColor Yellow
Write-Host "  第一步: 检查系统环境" -ForegroundColor Yellow
Write-Host "------------------------------------------" -ForegroundColor Yellow
Write-Host ""

# 检查操作系统
$osInfo = Get-CimInstance Win32_OperatingSystem
Write-Info "操作系统: $($osInfo.Caption) ($($osInfo.OSArchitecture))"

# 检查Node.js
Write-Host ""
Write-Info "检查 Node.js..."
try {
    $nodeVersion = node --version 2>$null
    if ($nodeVersion) {
        $majorVersion = [int]($nodeVersion -replace 'v', '').Split('.')[0]
        if ($majorVersion -ge 18) {
            Write-Success "Node.js $nodeVersion 已安装"
        } else {
            Write-Error "Node.js版本过低: $nodeVersion (需要v18+)"
            Write-Info "请访问 https://nodejs.org/ 下载并安装Node.js v18或更高版本"
            exit 1
        }
    } else {
        throw "Node.js未安装"
    }
} catch {
    Write-Error "Node.js 未安装"
    Write-Info "安装方法:"
    Write-Host "  1. 访问 https://nodejs.org/ 下载安装程序"
    Write-Host "  2. 或使用 winget: winget install OpenJS.NodeJS"
    exit 1
}

# 检查Rust
Write-Host ""
Write-Info "检查 Rust..."
try {
    $rustVersion = rustc --version 2>$null
    if ($rustVersion) {
        Write-Success "Rust $rustVersion 已安装"
    } else {
        throw "Rust未安装"
    }
} catch {
    Write-Error "Rust 未安装"
    Write-Info "正在自动安装 Rust..."
    Write-Host ""
    
    # 下载并运行rustup-init
    $rustupUrl = "https://win.rustup.rs/x86_64"
    $rustupPath = "$env:TEMP\rustup-init.exe"
    
    try {
        Invoke-WebRequest -Uri $rustupUrl -OutFile $rustupPath
        Write-Info "运行 Rust 安装程序..."
        Start-Process -FilePath $rustupPath -ArgumentList "-y" -Wait
        
        # 重新加载环境变量
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        
        $rustVersion = rustc --version 2>$null
        if ($rustVersion) {
            Write-Success "Rust $rustVersion 安装成功"
        } else {
            Write-Error "Rust 安装后仍无法检测到，请手动安装"
            Write-Info "访问 https://rustup.rs/ 下载安装"
            exit 1
        }
    } catch {
        Write-Error "Rust 自动安装失败"
        Write-Info "请手动访问 https://rustup.rs/ 下载安装"
        exit 1
    }
}

# 检查Visual Studio Build Tools
Write-Host ""
Write-Info "检查 Visual Studio Build Tools..."
try {
    # 检查cl.exe是否存在
    $clPath = Get-Command cl.exe -ErrorAction SilentlyContinue
    if ($clPath) {
        Write-Success "Visual Studio Build Tools 已安装"
    } else {
        # 检查是否有其他编译器
        $linkPath = Get-Command link.exe -ErrorAction SilentlyContinue
        if ($linkPath) {
            Write-Success "MSVC Linker 已安装"
        } else {
            throw "未找到"
        }
    }
} catch {
    Write-Warning "Visual Studio Build Tools 可能未安装"
    Write-Info "请下载并安装 Visual Studio Build Tools:"
    Write-Host "  https://aka.ms/vs/17/release/vs_BuildTools.exe"
    Write-Host ""
    Write-Info "安装时必须勾选:"
    Write-Host "  ☑ 使用C++的桌面开发"
    Write-Host "  ☑ MSVC v143 - VS 2022 C++ x64/x86 生成工具"
    Write-Host "  ☑ Windows 11 SDK"
    Write-Host ""
    Write-Warning "安装完成后，请关闭并重新打开终端，然后重新运行此脚本"
    
    $continue = Read-Host "是否继续尝试部署? (y/N)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        exit 1
    }
}

# 检查WebView2
Write-Host ""
Write-Info "检查 WebView2 Runtime..."
try {
    $webviewKey = Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}' -ErrorAction SilentlyContinue
    if ($webviewKey) {
        Write-Success "WebView2 Runtime 已安装"
    } else {
        throw "未找到"
    }
} catch {
    Write-Warning "WebView2 Runtime 未安装"
    Write-Info "正在自动安装 WebView2 Runtime..."
    
    $webviewUrl = "https://go.microsoft.com/fwlink/p/?LinkId=2124703"
    $webviewPath = "$env:TEMP\MicrosoftEdgeWebview2Setup.exe"
    
    try {
        Invoke-WebRequest -Uri $webviewUrl -OutFile $webviewPath
        Start-Process -FilePath $webviewPath -ArgumentList "/silent /install" -Wait
        Write-Success "WebView2 Runtime 安装完成"
    } catch {
        Write-Error "WebView2 自动安装失败"
        Write-Info "请手动下载安装:"
        Write-Host "  https://developer.microsoft.com/en-us/microsoft-edge/webview2/"
        exit 1
    }
}

Write-Host ""
Write-Success "环境检查完成！"
Write-Host ""

# 如果是仅检查模式，到此结束
if ($Check) {
    Write-Info "环境检查完成，可以开始部署"
    exit 0
}

# ==================== 安装依赖 ====================

Write-Host "------------------------------------------" -ForegroundColor Yellow
Write-Host "  第二步: 安装项目依赖" -ForegroundColor Yellow
Write-Host "------------------------------------------" -ForegroundColor Yellow
Write-Host ""

# 检查前端目录
if (-not (Test-Path "frontend")) {
    Write-Error "未找到 frontend 目录，请确保在项目根目录运行此脚本"
    exit 1
}

# 安装Node依赖
Write-Info "安装 Node.js 依赖..."
Set-Location frontend

try {
    # 配置国内镜像（可选）
    $npmRegistry = npm config get registry
    if ($npmRegistry -notmatch "npmmirror" -and $npmRegistry -notmatch "taobao") {
        Write-Info "配置 npm 国内镜像..."
        npm config set registry https://registry.npmmirror.com
    }
    
    # 安装依赖
    npm install
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Node.js 依赖安装完成"
    } else {
        throw "npm install 失败"
    }
} catch {
    Write-Error "Node.js 依赖安装失败"
    Write-Info "可能的解决方案:"
    Write-Host "  1. 检查网络连接"
    Write-Host "  2. 尝试清除缓存: npm cache clean --force"
    Write-Host "  3. 删除 node_modules 后重试"
    exit 1
}

# 配置Rust国内镜像
Write-Host ""
Write-Info "配置 Rust 国内镜像..."
$cargoConfigDir = "$env:USERPROFILE\.cargo"
$cargoConfigFile = "$cargoConfigDir\config.toml"

if (-not (Test-Path $cargoConfigDir)) {
    New-Item -ItemType Directory -Path $cargoConfigDir -Force | Out-Null
}

$cargoConfig = @"
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
"@

Set-Content -Path $cargoConfigFile -Value $cargoConfig
Write-Success "Rust 镜像配置完成"

Set-Location ..

# ==================== 运行/构建 ====================

Write-Host ""
Write-Host "------------------------------------------" -ForegroundColor Yellow
Write-Host "  第三步: 启动应用" -ForegroundColor Yellow
Write-Host "------------------------------------------" -ForegroundColor Yellow
Write-Host ""

if ($Build) {
    # 构建生产版本
    Write-Info "构建 Windows 生产版本..."
    Set-Location frontend
    
    try {
        npm run tauri-build
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Success "构建成功！"
            Write-Host ""
            Write-Info "安装包位置:"
            
            $msiPath = "..\src-tauri\target\release\bundle\msi"
            $exePath = "..\src-tauri\target\release\bundle\nsis"
            
            if (Test-Path $msiPath) {
                Write-Host "  MSI: $msiPath"
            }
            if (Test-Path $exePath) {
                Write-Host "  EXE: $exePath"
            }
        } else {
            throw "构建失败"
        }
    } catch {
        Write-Error "构建失败"
        exit 1
    }
} else {
    # 开发模式
    Write-Info "启动开发服务器..."
    Set-Location frontend
    
    Write-Host ""
    Write-Host "正在启动应用，请稍候..." -ForegroundColor Cyan
    Write-Host "首次启动可能需要几分钟（编译Rust代码）" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        npm run tauri-dev
    } catch {
        Write-Error "启动失败"
        exit 1
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  部署完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
