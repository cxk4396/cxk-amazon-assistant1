# CXK Amazon Assistant - Build Windows Installer

## Requirements

Before building, ensure you have:

1. **Node.js** v18+ - https://nodejs.org/
2. **Rust** - https://rustup.rs/
3. **Visual Studio Build Tools** with C++ support
4. **WebView2 Runtime** - Usually pre-installed on Windows 11

## Build Steps

### Step 1: Prepare Environment

Open **PowerShell as Administrator**:

```powershell
# Install Rust (if not installed)
winget install Rustlang.Rustup
# Restart terminal after installation

# Install Visual Studio Build Tools (if not installed)
winget install Microsoft.VisualStudio.2022.BuildTools
```

### Step 2: Build the Installer

```powershell
# Navigate to frontend folder
cd cxk-windows-ready\frontend

# Install dependencies
npm install

# Build Windows installer (.msi)
npx tauri build
```

### Step 3: Find the Installer

After successful build, find installer at:

```
cxk-windows-ready\
└── src-tauri\
    └── target\
        └── release\
            └── bundle\
                └── msi\
                    └── CXK Amazon Assistant_1.0.0_x64_en-US.msi
```

## Distribute the Software

You can now:

1. **Share the MSI file** - Users double-click to install
2. **Create a ZIP** - Include MSI + README for distribution
3. **Upload to cloud** - Share download link with users

## Silent Installation (for IT admins)

```powershell
# Silent install
msiexec /i "CXK Amazon Assistant_1.0.0_x64_en-US.msi" /qn

# Silent uninstall
msiexec /x "CXK Amazon Assistant_1.0.0_x64_en-US.msi" /qn
```

## Troubleshooting Build Errors

| Error | Solution |
|-------|----------|
| `Rust not installed` | Run `winget install Rustlang.Rustup` |
| `link.exe not found` | Install VS Build Tools with C++ workload |
| `WebView2 not found` | Install from https://go.microsoft.com/fwlink/p/?LinkId=2124703 |
| Build fails | Ensure 10GB+ free disk space |

## Build Time

- First build: **10-15 minutes** (downloads and compiles dependencies)
- Subsequent builds: **2-5 minutes**

## Output Files

The build creates:
- `.msi` - Windows Installer (recommended)
- `.exe` - Portable executable (optional)
