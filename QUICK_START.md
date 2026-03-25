# CXK运营决策助手 - 完整本地部署包

## 📦 部署包内容

```
cxk-amazon-assistant/
├── frontend/              # Vue 3 前端代码
│   ├── src/
│   ├── package.json
│   └── ...
├── src-tauri/             # Rust Tauri 后端
│   ├── src/
│   ├── Cargo.toml
│   ├── tauri.conf.json
│   └── icons/             # 应用图标
├── build-local.ps1        # Windows 一键构建脚本 ⭐
├── DEPLOY.md              # 完整部署文档
└── README.md              # 项目说明
```

## 🚀 快速开始（Windows）

### 方式一：一键脚本（推荐）

```powershell
# 1. 进入项目目录
cd cxk-amazon-assistant

# 2. 运行一键构建脚本（以管理员身份）
.\build-local.ps1
```

脚本会自动：
- 检查 Node.js 和 Rust 环境
- 安装依赖
- 生成图标
- 构建应用
- 输出安装包

### 方式二：手动步骤

#### 步骤 1：安装环境依赖

**1.1 安装 Node.js**
```powershell
# 检查是否已安装
node -v  # 应显示 v20.x.x 或更高

# 未安装请访问：https://nodejs.org/
# 下载 LTS 版本并安装
```

**1.2 安装 Rust**
```powershell
# 使用 winget 安装（推荐）
winget install Rustlang.Rustup

# 安装后重启 PowerShell，验证
rustc --version
cargo --version
```

**1.3 安装 Visual Studio Build Tools（Windows 必需）**
```powershell
# 方式1：winget
winget install Microsoft.VisualStudio.2022.BuildTools

# 方式2：官网下载
# https://visualstudio.microsoft.com/downloads/
# 选择 "工具" → "Visual Studio 2022 生成工具"
# 安装时勾选："使用 C++ 的桌面开发"
```

#### 步骤 2：安装项目依赖

```powershell
# 进入项目根目录
cd cxk-amazon-assistant

# 安装前端依赖
cd frontend
npm install
cd ..
```

#### 步骤 3：生成应用图标

```powershell
# 创建图标目录（如果不存在）
mkdir src-tauri/icons -Force

# 使用 PowerShell 生成图标
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
$bmp.Save("src-tauri/icons/icon.png")
$g.Dispose()
$bmp.Dispose()

# 生成各种尺寸的图标
cargo install tauri-cli --version "^2.0.0"
cd src-tauri
cargo tauri icon icons/icon.png
cd ..
```

#### 步骤 4：构建应用

```powershell
# 在项目根目录执行
cargo tauri build
```

构建完成后，产物在：
```
src-tauri/target/release/bundle/
├── msi/
│   └── CXK运营决策助手_1.0.0_x64_en-US.msi    ← MSI 安装包
├── nsis/
│   └── CXK运营决策助手_1.0.0_x64-setup.exe    ← EXE 安装包
└── CXK运营决策助手.exe                          ← 直接运行
```

## 🔧 开发模式

如需开发调试：

```powershell
# 终端1：启动前端开发服务器
cd frontend
npm run dev

# 终端2：启动 Tauri 应用（在项目根目录）
cargo tauri dev
```

## ⚠️ 常见问题

### 问题 1：构建时报错 "linker `link.exe` not found"
**原因**：缺少 Visual Studio Build Tools
**解决**：安装 "使用 C++ 的桌面开发" 工作负载

### 问题 2：cargo 命令找不到
**原因**：Rust 未安装或环境变量未生效
**解决**：
```powershell
# 重新加载环境变量
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 或重启 PowerShell
```

### 问题 3：npm install 很慢
**解决**：使用国内镜像
```powershell
npm config set registry https://registry.npmmirror.com
```

### 问题 4：图标生成失败
**解决**：手动放置图标文件
将 1024x1024 的 PNG 图片命名为 `icon.png` 放在 `src-tauri/icons/` 目录

### 问题 5：构建成功但无法运行
**检查**：
1. 确保 WebView2 已安装（Windows 10/11 通常自带）
2. 检查杀毒软件是否拦截
3. 尝试以管理员身份运行

## 📋 系统要求

| 项目 | 要求 |
|------|------|
| 操作系统 | Windows 10/11 (64位) |
| 内存 | 4GB+ (推荐 8GB) |
| 磁盘空间 | 2GB+ 可用空间 |
| Node.js | v20+ |
| Rust | v1.77+ |

## 🎯 构建时间参考

| 步骤 | 首次构建 | 后续构建 |
|------|---------|---------|
| 安装依赖 | 2-5 分钟 | 30 秒 |
| Rust 编译 | 10-15 分钟 | 2-5 分钟 |
| 打包 | 1-2 分钟 | 1 分钟 |
| **总计** | **15-25 分钟** | **5-10 分钟** |

## 📞 技术支持

如遇问题：
1. 查看 `DEPLOY.md` 完整文档
2. 检查错误日志
3. 确保所有依赖已正确安装

---
**CXK运营决策助手 v1.0.0**
