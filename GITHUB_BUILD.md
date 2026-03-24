# CXK Amazon Assistant - GitHub Auto Build

This repository is configured with GitHub Actions to automatically build Windows installer (.msi).

## How to Build

### Method 1: Push to GitHub (Recommended)

1. **Create a new repository on GitHub**
2. **Push this code to the repository:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/cxk-amazon-assistant.git
   git push -u origin main
   ```

3. **GitHub Actions will automatically build:**
   - Go to your repository on GitHub
   - Click "Actions" tab
   - The build will start automatically
   - Wait 10-15 minutes for the build to complete

4. **Download the installer:**
   - Go to "Actions" tab → Select the latest workflow run
   - Scroll down to "Artifacts"
   - Download "windows-installer"
   - Or check "Releases" for the built .msi file

### Method 2: Manual Build on Windows

See [BUILD.md](BUILD.md) for local build instructions.

## Download Pre-built Installer

If you don't want to build yourself, check the **Releases** section of this repository for pre-built installers.

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── build.yml       # GitHub Actions workflow
├── frontend/                # Vue 3 frontend
├── src-tauri/              # Rust backend
├── BUILD.md                # Local build guide
└── README.md               # Project documentation
```

## Requirements for Local Build

- Node.js v18+
- Rust
- Visual Studio Build Tools

See [BUILD.md](BUILD.md) for details.
