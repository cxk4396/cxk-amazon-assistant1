@echo off
chcp 65001 > nul
echo ==========================================
echo   CXK Amazon Assistant - Windows Setup
echo ==========================================
echo.

echo [Step 1/3] Installing npm packages...
cd frontend
call npm install
if errorlevel 1 (
    echo ERROR: npm install failed
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)
echo OK: npm packages installed
echo.

echo [Step 2/3] Checking Rust...
rustc --version > nul 2>&1
if errorlevel 1 (
    echo ERROR: Rust not found
    echo Please install Rust from https://rustup.rs/
    pause
    exit /b 1
)
echo OK: Rust is installed
echo.

echo [Step 3/3] Starting development server...
echo First run will take 5-10 minutes to compile...
echo.
npx tauri dev

pause
