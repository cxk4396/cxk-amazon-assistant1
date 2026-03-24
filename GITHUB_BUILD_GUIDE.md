# GitHub Actions 自动构建指南

## 快速开始（3步完成）

### 第1步：创建 GitHub 仓库

1. 访问 https://github.com/new
2. 输入仓库名称：`cxk-amazon-assistant`
3. 选择 **Public**（公开）或 **Private**（私有）
4. **不要**勾选 "Add a README file"
5. 点击 **Create repository**

### 第2步：上传代码

在你的项目文件夹中执行以下命令：

```bash
# 进入项目目录
cd cxk-windows-ready

# 初始化 git 仓库
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit"

# 关联远程仓库（将 YOUR_USERNAME 替换为你的 GitHub 用户名）
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/cxk-amazon-assistant.git

# 推送代码
git push -u origin main
```

### 第3步：等待构建完成

1. 打开你的 GitHub 仓库页面
2. 点击顶部的 **"Actions"** 标签
3. 你会看到 "Build Windows Installer" 工作流正在运行（黄色圆点）
4. 等待约 **10-15 分钟**
5. 构建完成后显示绿色勾号 ✅

---

## 下载安装包

### 方法1：从 Artifacts 下载（推荐）

1. 点击 **Actions** → 选择最新完成的 workflow
2. 页面底部找到 **Artifacts** 部分
3. 下载以下任一文件：
   - `cxk-amazon-assistant-windows` （MSI 安装包）
   - `cxk-amazon-assistant-setup` （EXE 安装包）

### 方法2：手动触发构建

如果你修改了代码想重新构建：

1. 点击 **Actions** 标签
2. 点击左侧 **"Build Windows Installer"**
3. 点击右侧 **"Run workflow"** 按钮
4. 点击绿色 **"Run workflow"** 确认

---

## 项目文件说明

```
cxk-windows-ready/
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions 构建配置
├── src-tauri/
│   ├── capabilities/
│   │   └── main-capability.json   # 应用权限配置
│   ├── src/
│   │   ├── main.rs
│   │   ├── lib.rs
│   │   ├── commands.rs
│   │   └── file_parser.rs
│   ├── Cargo.toml
│   ├── tauri.conf.json
│   └── icons/
├── frontend/
│   ├── src/
│   ├── package.json
│   └── ...
└── README.md
```

---

## 常见问题

### Q: 构建失败了怎么办？

A: 点击失败的 workflow，查看日志找到错误原因。常见原因：
- 代码语法错误
- 依赖版本冲突
- 文件缺失

### Q: 构建需要多长时间？

A: 
- 首次构建：**10-15 分钟**（需要下载和编译 Rust 依赖）
- 后续构建：**5-8 分钟**（有缓存）

### Q: 生成的安装包在哪里？

A: 两个地方可以找到：
1. **Actions → 具体运行 → Artifacts**（30天后过期）
2. **Releases** 页面（如果你配置了自动发布）

### Q: 可以构建其他平台的安装包吗？

A: 可以！修改 `.github/workflows/build.yml`：

```yaml
jobs:
  build-windows:
    runs-on: windows-latest    # Windows
  
  build-macos:
    runs-on: macos-latest      # macOS
    
  build-linux:
    runs-on: ubuntu-latest     # Linux
```

---

## 下一步

构建完成后，你可以：

1. **分享安装包** - 将 .msi 文件发送给其他人
2. **创建 Release** - 在 GitHub 上发布正式版本
3. **自动更新** - 配置 Tauri 自动更新功能

---

## 需要帮助？

如果构建过程中遇到问题：
1. 查看 Actions 日志中的错误信息
2. 检查所有文件是否正确上传
3. 确认 `.github/workflows/build.yml` 存在且格式正确
