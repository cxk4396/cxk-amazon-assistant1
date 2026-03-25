# Windows部署快速参考

## 常见错误速查表

| 错误信息 | 原因 | 解决方案 |
|---------|------|----------|
| `Rust is not installed` | 未安装Rust | 运行 `winget install Rustlang.Rustup` |
| `link.exe not found` | 缺少Visual Studio Build Tools | 安装 [VS Build Tools](https://aka.ms/vs/17/release/vs_BuildTools.exe) |
| `WebView2 is not installed` | 缺少WebView2 | 安装 [WebView2](https://go.microsoft.com/fwlink/p/?LinkId=2124703) |
| `路径包含中文` | 项目路径有中文字符 | 移动到纯英文路径如 `C:\projects\cxk\` |
| `Port 5173 is already in use` | 端口被占用 | 修改 `vite.config.ts` 中的端口 |
| `Access is denied` | 权限不足 | 以管理员身份运行PowerShell |
| `Windows已保护你的电脑` | 杀毒软件拦截 | 点击"更多信息"→"仍要运行" |
| `ETIMEDOUT` | 网络超时 | 配置国内镜像 |
| `EBADENGINE` | Node版本过低 | 升级Node.js到v18+ |

---

## Windows部署检查清单

```
部署前检查:
□ Node.js v18+    运行: node --version
□ Rust            运行: rustc --version
□ VS Build Tools  检查: 控制面板 → 程序
□ WebView2        检查: 设置 → 应用
□ 英文路径        检查: 当前路径不含中文
□ 管理员权限      检查: PowerShell标题显示"管理员"
```

---

## 一键修复命令

```powershell
# 修复1: 安装/升级 Node.js (使用nvm-windows)
nvm install 20
nvm use 20

# 修复2: 安装 Rust
winget install Rustlang.Rustup
# 安装后重启终端

# 修复3: 安装 VS Build Tools
winget install Microsoft.VisualStudio.2022.BuildTools

# 修复4: 安装 WebView2
winget install Microsoft.EdgeWebView2Runtime

# 修复5: 配置国内镜像
npm config set registry https://registry.npmmirror.com
# Rust镜像写入 %USERPROFILE%\.cargo\config.toml:
# [source.crates-io]
# replace-with = 'ustc'
# [source.ustc]
# registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

# 修复6: 清除缓存重试
Remove-Item -Recurse -Force node_modules
npm cache clean --force
npm install
```

---

## Windows部署流程图

```
开始
 │
 ▼
检查路径不含中文 ──❌──→ 移动到英文路径
 │✅
 ▼
检查Node.js v18+ ──❌──→ 安装Node.js
 │✅
 ▼
检查Rust ──❌──→ 安装Rust
 │✅
 ▼
检查VS Build Tools ──❌──→ 安装VS Build Tools
 │✅
 ▼
检查WebView2 ──❌──→ 安装WebView2
 │✅
 ▼
npm install
 │
 ▼
npm run tauri-dev
 │
 ▼
成功运行 ✅
```

---

## 各Windows版本支持

| Windows版本 | 支持状态 | 备注 |
|------------|---------|------|
| Windows 11 | ✅ 完全支持 | 推荐 |
| Windows 10 21H2+ | ✅ 完全支持 | 需安装WebView2 |
| Windows 10 1809-20H2 | ⚠️ 部分支持 | 需手动安装依赖 |
| Windows 8.1/7 | ❌ 不支持 | 请升级系统 |

---

## 性能建议

```powershell
# 使用SSD加速编译
# 确保C盘（或项目所在盘）有至少10GB空间

# 首次编译较慢（5-10分钟），后续启动仅需几秒
# 如需快速启动，可使用: npm run dev（仅前端，无Rust后端）

# 多核编译加速（Rust会自动使用）
# 如需限制CPU使用，设置环境变量:
$env:CARGO_BUILD_JOBS = "4"
```

---

## 故障排除联系

如果以上方案都无法解决问题：

1. 查看详细日志：`npm run tauri-dev 2>&1 | Tee-Object -FilePath deploy.log`
2. 提交Issue附上 `deploy.log` 文件
3. 或联系技术支持

---

**快速部署命令** (复制粘贴到PowerShell):

```powershell
# 完整部署流程（管理员PowerShell）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\deploy-windows.ps1
```
