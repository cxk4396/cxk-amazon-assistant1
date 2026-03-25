# CXK Amazon Assistant - Windows Build Script
# Run: Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

param(
    [switch]$SkipIcon = $false,
    [switch]$SkipBuild = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host "  CXK Amazon Assistant - Build Script  "
Write-Host "========================================"
Write-Host ""

# Get project root
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $projectRoot) { $projectRoot = Get-Location }
Set-Location $projectRoot

Write-Host "Project: $projectRoot"
Write-Host ""

# ========== Step 1: Check Environment ==========
Write-Host "[Step 1/5] Checking environment..."

try {
    $nodeVersion = node -v 2>$null
    Write-Host "  OK - Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "  ERROR - Node.js not installed" -ForegroundColor Red
    Write-Host "  Please install from https://nodejs.org/"
    exit 1
}

try {
    $rustVersion = rustc --version 2>$null
    Write-Host "  OK - Rust: $rustVersion" -ForegroundColor Green
} catch {
    Write-Host "  ERROR - Rust not installed" -ForegroundColor Red
    Write-Host "  Install: winget install Rustlang.Rustup"
    exit 1
}

try {
    $cargoVersion = cargo --version 2>$null
    Write-Host "  OK - Cargo: $cargoVersion" -ForegroundColor Green
} catch {
    Write-Host "  ERROR - Cargo not found" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ========== Step 2: Install Dependencies ==========
Write-Host "[Step 2/5] Installing frontend dependencies..."

if (-not (Test-Path "$projectRoot\frontend\package.json")) {
    Write-Host "  ERROR - frontend/package.json not found" -ForegroundColor Red
    exit 1
}

Set-Location "$projectRoot\frontend"

try {
    npm install 2>&1 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    if ($LASTEXITCODE -ne 0) { throw "npm install failed" }
    Write-Host "  OK - Dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "  ERROR - npm install failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Set-Location $projectRoot

# ========== Step 3: Generate Icons ==========
if (-not $SkipIcon) {
    Write-Host "[Step 3/5] Generating app icons..."
    
    $iconsDir = "$projectRoot\src-tauri\icons"
    if (-not (Test-Path $iconsDir)) {
        New-Item -ItemType Directory -Force -Path $iconsDir | Out-Null
    }
    
    try {
        Write-Host "  Creating 1024x1024 icon..."
        
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        
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
        
        $iconPath = "$iconsDir\icon.png"
        $bmp.Save($iconPath, [System.Drawing.Imaging.ImageFormat]::Png)
        
        $g.Dispose()
        $bmp.Dispose()
        $font.Dispose()
        
        Write-Host "  OK - Icon created: $iconPath" -ForegroundColor Green
        
        # Generate Tauri icons
        Write-Host "  Generating Tauri icon set..."
        $tauriCli = cargo install --list | Select-String "tauri-cli"
        if (-not $tauriCli) {
            Write-Host "  Installing Tauri CLI..."
            cargo install tauri-cli --version "^2.0.0" --locked 2>&1 | Out-Null
        }
        
        Set-Location "$projectRoot\src-tauri"
        cargo tauri icon icons/icon.png 2>&1 | Out-Null
        
        Write-Host "  OK - Icons generated" -ForegroundColor Green
    } catch {
        Write-Host "  WARNING - Icon generation failed: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[Step 3/5] Skipping icon generation (--SkipIcon)"
}

Write-Host ""
Set-Location $projectRoot

# ========== Step 4: Build Application ==========
if (-not $SkipBuild) {
    Write-Host "[Step 4/5] Building Tauri application..."
    Write-Host "  NOTE: First build takes 10-20 minutes, please wait..." -ForegroundColor Magenta
    Write-Host ""
    
    try {
        cargo tauri build 2>&1 | ForEach-Object {
            if ($_ -match "Compiling|Finished|Running|Building|Generating|Complete|bundle|error\[|warning:") {
                if ($_ -match "error\[") {
                    Write-Host "  ERROR: $_" -ForegroundColor Red
                } elseif ($_ -match "warning:") {
                    Write-Host "  WARN: $_" -ForegroundColor Yellow
                } else {
                    Write-Host "  $_" -ForegroundColor Gray
                }
            }
        }
        
        if ($LASTEXITCODE -ne 0) { throw "Build failed" }
        
        Write-Host ""
        Write-Host "  OK - Build successful!" -ForegroundColor Green
    } catch {
        Write-Host ""
        Write-Host "  ERROR - Build failed: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Common solutions:" -ForegroundColor Yellow
        Write-Host "  1. Install Visual Studio Build Tools (C++ Desktop Development)"
        Write-Host "  2. Run: winget install Microsoft.VisualStudio.2022.BuildTools"
        Write-Host "  3. Restart PowerShell and retry"
        exit 1
    }
} else {
    Write-Host "[Step 4/5] Skipping build (--SkipBuild)"
}

Write-Host ""

# ========== Step 5: Show Results ==========
Write-Host "[Step 5/5] Build artifacts..."

$bundleDir = "$projectRoot\src-tauri\target\release\bundle"
$exePath = "$projectRoot\src-tauri\target\release\CXK.exe"

$foundFiles = @()

$msiPath = Get-ChildItem -Path "$bundleDir\msi" -Filter "*.msi" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($msiPath) {
    $foundFiles += @{ Type = "MSI Installer"; Path = $msiPath.FullName; Size = "$([math]::Round($msiPath.Length/1MB, 2)) MB" }
}

$nsisPath = Get-ChildItem -Path "$bundleDir\nsis" -Filter "*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($nsisPath) {
    $foundFiles += @{ Type = "EXE Installer"; Path = $nsisPath.FullName; Size = "$([math]::Round($nsisPath.Length/1MB, 2)) MB" }
}

if (Test-Path $exePath) {
    $exeFile = Get-Item $exePath
    $foundFiles += @{ Type = "Direct EXE"; Path = $exePath; Size = "$([math]::Round($exeFile.Length/1MB, 2)) MB" }
}

if ($foundFiles.Count -eq 0) {
    Write-Host "  WARNING - No build artifacts found" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "  Found build artifacts:" -ForegroundColor Green
    Write-Host ""
    foreach ($file in $foundFiles) {
        Write-Host "  [$($file.Type)]" -ForegroundColor Cyan
        Write-Host "    Path: $($file.Path)"
        Write-Host "    Size: $($file.Size)"
        Write-Host ""
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Build Complete!                      " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

if ($foundFiles.Count -gt 0) {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  - MSI/EXE Installer: Double-click to install"
    Write-Host "  - Direct EXE: Run without installation"
    Write-Host ""
}

Pause
