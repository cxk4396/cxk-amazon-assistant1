# CXK Amazon Assistant - Windows 安装包构建项目

本项目可以通过 GitHub Actions 自动构建 Windows 安装包（.msi/.exe），无需本地安装开发环境。

## 两种使用方式

### 方式一：GitHub Actions 自动构建（推荐）⭐

**优势：**
- ✅ 无需安装 Node.js、Rust、VS Build Tools
- ✅ 无需配置复杂的开发环境
- ✅ 自动构建，10-15分钟完成
- ✅ 免费使用 GitHub 提供的服务器

**步骤：**

1. **Fork 或创建仓库**
   ```bash
   # 将本项目推送到你的 GitHub
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/cxk-amazon-assistant.git
   git push -u origin main
   ```

2. **等待自动构建**
   - 打开 GitHub 仓库 → Actions 标签
   - 构建自动开始，等待 10-15 分钟

3. **下载安装包**
   - Actions → 最新 workflow → Artifacts
   - 下载 `cxk-amazon-assistant-windows`（MSI 文件）

**详细指南：** [GITHUB_BUILD_GUIDE.md](GITHUB_BUILD_GUIDE.md)

---

### 方式二：本地构建

如果你有 Windows 开发环境，可以在本地构建。

**前置要求：**
- Node.js v18+
- Rust
- Visual Studio Build Tools（约 5GB）

**步骤：**
```powershell
cd frontend
npm install
npm run build
cd ../src-tauri
cargo tauri build
```

**详细指南：** [BUILD.md](BUILD.md)

---

## 项目结构

```
cxk-windows-ready/
├── .github/workflows/build.yml      # GitHub Actions 配置
├── frontend/                         # Vue 3 前端代码
├── src-tauri/                        # Rust 后端代码
│   ├── capabilities/                 # 应用权限
│   ├── src/                          # Rust 源码
│   ├── Cargo.toml                    # Rust 配置
│   └── tauri.conf.json               # Tauri 配置
├── build-installer.bat               # 本地构建脚本
├── GITHUB_BUILD_GUIDE.md             # GitHub 构建详细指南
├── BUILD.md                          # 本地构建指南
└── README.md                         # 本文件
```

---

## 构建输出

构建成功后，会生成以下文件：

| 文件 | 说明 | 大小 |
|------|------|------|
| `CXK Amazon Assistant_1.0.0_x64_en-US.msi` | Windows 安装包 | ~5MB |
| `CXK Amazon Assistant_1.0.0_x64-setup.exe` | 安装程序（可选）| ~5MB |

---

## 快速开始

### 用户安装软件

1. 下载 `.msi` 文件
2. 双击运行
3. 按照安装向导完成安装
4. 从开始菜单启动 "CXK Amazon Assistant"

### 开发者修改代码

1. 修改 `frontend/src/` 下的 Vue 代码
2. 修改 `src-tauri/src/` 下的 Rust 代码
3. 提交到 GitHub
4. GitHub Actions 自动构建新版本

---

## 技术栈

- **前端：** Vue 3 + TypeScript + Element Plus
- **后端：** Rust + Tauri v2
- **构建：** GitHub Actions + Windows Server

---

## 常见问题

**Q: 构建需要多长时间？**
A: 首次约 10-15 分钟，后续约 5-8 分钟（有缓存）。

**Q: 构建是免费的吗？**
A: 是的，GitHub Actions 对公开仓库完全免费，私有仓库每月有 2000 分钟免费额度。

**Q: 可以构建 macOS 或 Linux 版本吗？**
A: 可以，修改 `.github/workflows/build.yml` 中的 `runs-on` 参数即可。

**Q: 如何更新软件版本？**
A: 修改 `src-tauri/tauri.conf.json` 中的 `version` 字段，然后推送代码。

---

## 相关文档

- [GitHub 构建指南](GITHUB_BUILD_GUIDE.md) - 详细步骤说明
- [本地构建指南](BUILD.md) - 本地开发环境搭建
- [Tauri 文档](https://tauri.app/) - 框架官方文档

---

## 许可证

MIT License
