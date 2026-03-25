# CXK运营决策助手 - Windows部署脚本 (UTF-8 with BOM版本)
# 修复中文编码问题
# 使用方法: 右键以管理员身份运行 PowerShell

param(
    [switch]$Dev,
    [switch]$Build,
    [switch]$Check
)

$ErrorActionPreference = "Stop"

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Blue }
function Write-Success($msg) { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Error($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Warning($msg) { Write-Host "[WARNING] $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  CXK Amazon Assistant - Windows Deploy" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check for Chinese characters in path
$currentPath = Get-Location
if ($currentPath.Path -match '[\u4e00-\u9fa5]') {
    Write-Error "Project path contains Chinese characters!"
    Write-Host "Current path: $($currentPath.Path)"
    Write-Host "Please move to an English path, like: C:\projects\cxk-amazon-assistant\" -ForegroundColor Yellow
    exit 1
}

Write-Info "Project path: $($currentPath.Path)"
Write-Host ""

# Check Node.js
Write-Info "Checking Node.js..."
try {
    $nodeVersion = node --version 2>$null
    if ($nodeVersion) {
        $majorVersion = [int]($nodeVersion -replace 'v', '').Split('.')[0]
        if ($majorVersion -ge 18) {
            Write-Success "Node.js $nodeVersion installed"
        } else {
            Write-Error "Node.js version too old: $nodeVersion (need v18+)"
            exit 1
        }
    } else {
        throw "Node.js not installed"
    }
} catch {
    Write-Error "Node.js not installed"
    Write-Host "Please install from https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check Rust
Write-Host ""
Write-Info "Checking Rust..."
try {
    $rustVersion = rustc --version 2>$null
    if ($rustVersion) {
        Write-Success "Rust $rustVersion installed"
    } else {
        throw "Rust not installed"
    }
} catch {
    Write-Error "Rust not installed"
    Write-Host "Installing Rust..." -ForegroundColor Yellow
    Write-Host "Please install from https://rustup.rs/ and restart terminal" -ForegroundColor Yellow
    exit 1
}

# Check project structure
Write-Host ""
Write-Info "Checking project structure..."
if (-not (Test-Path "frontend")) {
    Write-Error "frontend directory not found!"
    exit 1
}

if (-not (Test-Path "src-tauri")) {
    Write-Error "src-tauri directory not found!"
    exit 1
}

Write-Success "Project structure OK"

# Install dependencies
Write-Host ""
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "  Installing Dependencies" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host ""

Write-Info "Installing npm packages..."
Set-Location frontend

try {
    npm install
    if ($LASTEXITCODE -eq 0) {
        Write-Success "npm install completed"
    } else {
        throw "npm install failed"
    }
} catch {
    Write-Error "npm install failed"
    exit 1
}

Set-Location ..

# Run or Build
Write-Host ""
if ($Build) {
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "  Building Production" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Yellow
    Set-Location frontend
    npm run tauri-build
} else {
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "  Starting Development Server" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Starting app... First start may take 5-10 minutes" -ForegroundColor Cyan
    Write-Host ""
    Set-Location frontend
    npm run tauri-dev
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  Done!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
