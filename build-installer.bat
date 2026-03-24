@echo off
chcp 65001 > nul
title CXK Amazon Assistant - Build Installer
echo ==========================================
echo   Building Windows Installer
echo ==========================================
echo.

cd /d "%~dp0"

echo [Step 1/4] Checking prerequisites...

node --version > nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js not found!
    echo Please install from https://nodejs.org/
    pause
    exit /b 1
)
echo OK: Node.js found

rustc --version > nul 2>&1
if errorlevel 1 (
    echo ERROR: Rust not found!
    echo Please install from https://rustup.rs/
    pause
    exit /b 1
)
echo OK: Rust found
echo.

echo [Step 2/4] Installing npm packages...
cd frontend
if not exist "package.json" (
    echo ERROR: package.json not found in frontend folder
    pause
    exit /b 1
)
call npm install
if errorlevel 1 (
    echo ERROR: npm install failed
    pause
    exit /b 1
)
echo OK: Dependencies installed
echo.

echo [Step 3/4] Building Windows installer...
echo This may take 10-15 minutes on first run...
echo.
npx tauri build

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    echo.
    echo Common issues:
    echo - Visual Studio Build Tools not installed
    echo - Not enough disk space (need 10GB+)
    echo - WebView2 Runtime not installed
    echo.
    pause
    exit /b 1
)

echo.
echo [Step 4/4] Build complete!
echo.
echo Installer location:
echo   src-tauri\target\release\bundle\msi\
echo.

start explorer "..\src-tauri\target\release\bundle\msi"

pause
