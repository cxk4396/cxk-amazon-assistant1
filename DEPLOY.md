# CXK运营决策助手 - 完整部署指南

## 方案一：本地构建（推荐，最快）

### 环境要求
- **Windows 10/11**
- **Node.js 20+**
- **Rust 1.77+**
- **Visual Studio Build Tools** (Windows必需，安装C++开发工具)

### 步骤

#### 1. 安装依赖

**Node.js**
```powershell
# 检查是否已安装
node -v

# 未安装则从官网下载：https://nodejs.org (选 LTS 版本)
```

**Rust**
```powershell
# 方式1：使用 winget (推荐)
winget install Rustlang.Rustup

# 方式2：官网安装
# https://rustup.rs/ 下载 rustup-init.exe

# 安装后重启 PowerShell，验证
rustc --version
cargo --version
```

**Visual Studio Build Tools** (Windows必需)
```powershell
# 方式1：使用 winget
winget install Microsoft.VisualStudio.2022.BuildTools

# 方式2：官网下载
# https://visualstudio.microsoft.com/downloads/
# 选择 "工具" -> "Visual Studio 2022 生成工具"
# 安装时勾选："使用 C++ 的桌面开发"
```

#### 2. 克隆项目
```powershell
git clone https://github.com/cxk4396/cxk-amazon-assistant1.git
cd cxk-amazon-assistant1
```

#### 3. 构建应用

**方式A：一键脚本（推荐）**
```powershell
# 以管理员身份运行 PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\build-local.ps1
```

**方式B：手动命令**
```powershell
# 进入前端目录
cd frontend

# 安装依赖
npm install

# 构建应用（首次约10-15分钟）
npm run tauri-build
```

#### 4. 获取安装包

构建完成后，产物在：
```
src-tauri/target/release/bundle/
├── msi/
│   └── CXK运营决策助手_1.0.0_x64_en-US.msi    # MSI安装包
├── nsis/
│   └── CXK运营决策助手_1.0.0_x64-setup.exe    # EXE安装包
└── CXK运营决策助手.exe                         # 可直接运行的程序
```

---

## 方案二：GitHub Actions 自动构建

### 前提条件
- GitHub 仓库已配置 `main` 分支（`master` 分支构建有问题）

### 步骤

#### 1. 切换到 main 分支
```powershell
git checkout main
git pull origin main
```

#### 2. 推送代码触发构建
```powershell
git add .
git commit -m "your commit message"
git push origin main
```

#### 3. 等待构建完成
- 访问：https://github.com/cxk4396/cxk-amazon-assistant1/actions
- 构建成功后，安装包会自动上传到 GitHub Releases

---

## 方案三：跨平台构建（高级）

如果需要同时构建 Windows、macOS、Linux 版本，使用以下 workflow：

```yaml
name: Build All Platforms
on:
  push:
    branches: [main]

jobs:
  build:
    strategy:
      fail-fast: false
      matrix:
        platform: [macos-latest, ubuntu-22.04, windows-latest]
    runs-on: ${{ matrix.platform }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 20
      
      - name: Setup Rust
        uses: dtolnay/rust-toolchain@stable
      
      - name: Install dependencies (ubuntu only)
        if: matrix.platform == 'ubuntu-22.04'
        run: |
          sudo apt-get update
          sudo apt-get install -y libgtk-3-dev libwebkit2gtk-4.0-dev libappindicator3-dev librsvg2-dev patchelf
      
      - name: Install frontend dependencies
        working-directory: ./frontend
        run: npm install
      
      - name: Build Tauri
        uses: tauri-apps/tauri-action@v0
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tagName: v__VERSION__
          releaseName: "CXK运营决策助手 v__VERSION__"
          releaseBody: "See the assets to download this version and install."
          releaseDraft: true
          prerelease: false
          projectPath: ./frontend
```

---

## 常见问题

### Q1: 构建时报错 "linker `link.exe` not found"
**原因**：缺少 Visual Studio Build Tools

**解决**：
```powershell
winget install Microsoft.VisualStudio.2022.BuildTools
# 然后打开 Visual Studio Installer，安装 "使用 C++ 的桌面开发"
```

### Q2: 构建时报错 "Could not find webview2loader.dll"
**原因**：缺少 WebView2 运行时

**解决**：
```powershell
# 下载并安装 WebView2 运行时
# https://developer.microsoft.com/en-us/microsoft-edge/webview2/
```

### Q3: npm install 很慢或失败
**解决**：
```powershell
# 使用淘宝镜像
npm config set registry https://registry.npmmirror.com

# 或使用 yarn
npm install -g yarn
yarn install
```

### Q4: 图标生成失败
**解决**：
```powershell
# 手动创建图标目录
mkdir src-tauri/icons

# 使用 PowerShell 生成简单图标
Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap(1024, 1024)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::FromArgb(255, 153, 0))
$font = New-Object System.Drawing.Font("Arial", 300, [System.Drawing.FontStyle]::Bold)
$brush = [System.Drawing.Brushes]::White
$format = New-Object System.Drawing.StringFormat
$format.Alignment = [System.Drawing.StringAlignment]::Center
$format.LineAlignment = [System.Drawing.StringAlignment]::Center
$g.DrawString("CXK", $font, $brush, 512, 512, $format)
$bmp.Save("src-tauri/icons/icon.png")
$g.Dispose()
$bmp.Dispose()
```

### Q5: 构建成功但运行时报错
**检查**：
1. 确保 SQLite 数据库文件有写入权限
2. 检查是否被杀毒软件拦截
3. 尝试以管理员身份运行

---

## 发布流程

### 本地构建后发布
```powershell
# 1. 构建完成后，打包产物
Compress-Archive -Path "src-tauri\target\release\bundle\*" -DestinationPath "CXK运营决策助手-v1.0.0.zip"

# 2. 上传到 GitHub Releases（手动）
# 访问 https://github.com/cxk4396/cxk-amazon-assistant1/releases
# 点击 "Draft a new release"
```

### 自动发布（GitHub Actions）
使用上面的 workflow，推送 tag 会自动创建 release：
```powershell
git tag v1.0.1
git push origin v1.0.1
```

---

## 快速检查清单

构建前确认：
- [ ] Node.js 已安装 (`node -v`)
- [ ] Rust 已安装 (`rustc --version`)
- [ ] Visual Studio Build Tools 已安装（Windows）
- [ ] 项目已克隆 (`git clone ...`)
- [ ] 在前端目录运行 `npm install`
- [ ] 图标文件存在 (`src-tauri/icons/icon.png`)

---

## 推荐方案总结

| 场景 | 推荐方案 | 预计时间 |
|------|---------|---------|
| 快速试用 | 本地一键脚本 | 15-20分钟 |
| 正式发布 | GitHub Actions (main分支) | 自动 |
| 多平台 | GitHub Actions 跨平台 workflow | 自动 |
| 开发调试 | 本地 `npm run tauri-dev` | 即时 |

**最简单的方式**：直接跑 `build-local.ps1`，等 15 分钟，就能拿到安装包。
