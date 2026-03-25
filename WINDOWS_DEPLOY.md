# CXK运营决策助手 - Windows部署模拟与故障排除

## 模拟环境

- **操作系统**: Windows 11 Pro 23H2
- **架构**: x64
- **用户权限**: 普通用户（非管理员）
- **安装路径**: `C:\Users\Administrator\projects\cxk-amazon-assistant`

---

## 部署场景模拟

### 场景1: 首次部署（理想情况）

```powershell
# 步骤1: 克隆项目
git clone https://github.com/cxk-team/cxk-amazon-assistant.git
cd cxk-amazon-assistant

# 步骤2: 检查环境
cd frontend
npm install

# 步骤3: 运行开发服务器
npm run tauri-dev
```

**预期结果**: ✅ 应用正常启动

---

### 场景2: Rust未安装 ❌

```powershell
PS C:\Users\Administrator\projects\cxk-amazon-assistant\frontend> npm run tauri-dev

> cxk-amazon-assistant@1.0.0 tauri-dev
> tauri dev

Error: Rust is not installed or not in PATH.
Please install Rust from https://rustup.rs/

    at runDev (C:\Users\Administrator\projects\cxk-amazon-assistant\frontend\node_modules\@tauri-apps\cli\tauri.js:123:15)
    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
npm ERR! code ELIFECYCLE
npm ERR! errno 1
```

**错误原因**: Windows系统未安装Rust工具链

**解决方案**:
```powershell
# 以管理员身份运行PowerShell
# 安装Rust
winget install Rustlang.Rustup
# 或访问 https://rustup.rs/ 下载安装程序

# 安装完成后重启终端
rustup default stable
rustc --version  # 验证安装
```

---

### 场景3: Visual Studio Build Tools 缺失 ❌

```powershell
PS C:\Users\Administrator\projects\cxk-amazon-assistant\frontend> npm run tauri-dev

   Compiling cxk-amazon-assistant v1.0.0 (C:\Users\Administrator\projects\cxk-amazon-assistant\src-tauri)
error: linker `link.exe` not found
  |
  = note: program not found

note: the msvc targets depend on the msvc linker but `link.exe` was not found

note: please ensure that Visual Studio 2019 or later, or Build Tools for Visual Studio were installed with the Visual C++ option.

error: could not compile `cxk-amazon-assistant` due to previous error
```

**错误原因**: Windows缺少C++构建工具链

**解决方案**:
```powershell
# 方法1: 使用Visual Studio Installer安装Build Tools
# 下载: https://visualstudio.microsoft.com/visual-cpp-build-tools/
# 安装时勾选:
#   - 使用C++的桌面开发
#   - MSVC v143 - VS 2022 C++ x64/x86 生成工具
#   - Windows 11 SDK

# 方法2: 使用Chocolatey
choco install visualstudio2022buildtools
choco install visualstudio2022-workload-vctools
```

---

### 场景4: WebView2 Runtime 缺失 ❌

```powershell
PS C:\Users\Administrator\projects\cxk-amazon-assistant\frontend> npm run tauri-dev

Running BeforeDevCommand (`npm run dev`)

  vite v5.0.0 dev server running at:

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose

     Running DevCommand (`cargo run`)
error: WebView2 is not installed. Please install it from:
https://developer.microsoft.com/en-us/microsoft-edge/webview2/

App panicked: WebView2 initialization failed
```

**错误原因**: Windows 10/11 缺少 WebView2 运行时

**解决方案**:
```powershell
# 方法1: 下载独立安装程序
# https://developer.microsoft.com/en-us/microsoft-edge/webview2/
# 选择 "Evergreen Standalone Installer"

# 方法2: 使用Winget
winget install Microsoft.EdgeWebView2Runtime

# 方法3: 运行系统更新（Windows 11通常已预装）
Windows Update > 检查更新
```

---

### 场景5: 中文路径问题 ❌

```powershell
# 用户将项目放在中文路径下
PS C:\用户\管理员\项目\运营助手\frontend> npm run tauri-dev

   Compiling cxk-amazon-assistant v1.0.0 (C:\用户\管理员\项目\运营助手\src-tauri)
warning: path contains non-UTF-8 characters
error: failed to run custom build command for `cxk-amazon-assistant v1.0.0`

Caused by:
  process didn't exit successfully: `C:\用户\管理员\项目\运营助手\src-tauri\target\release\build\...`
  系统找不到指定的路径。
```

**错误原因**: 路径中包含中文字符，某些Rust工具链处理有问题

**解决方案**:
```powershell
# 将项目移动到纯英文路径
# ❌ 不推荐
C:\用户\管理员\项目\运营助手\

# ✅ 推荐
C:\projects\cxk-amazon-assistant\
D:\dev\cxk-amazon-assistant\
```

---

### 场景6: 权限不足（写入Program Files）❌

```powershell
PS C:\Users\Administrator\projects\cxk-amazon-assistant\frontend> npm run tauri-build

   Compiling cxk-amazon-assistant v1.0.0
    Finished release [optimized] target(s) in 45.23s
    Bundling cxk-amazon-assistant_1.0.0_x64_en-US.msi
    Bundling cxk-amazon-assistant_1.0.0_x64-setup.exe
       Error: failed to bundle project

Caused by:
    0: failed to build msi
    1: Access is denied. (os error 5)
       path: C:\Program Files\cxk-amazon-assistant\
```

**错误原因**: 构建时尝试写入受保护的系统目录

**解决方案**:
```powershell
# 方法1: 以管理员身份运行PowerShell/终端
# 右键 -> 以管理员身份运行

# 方法2: 修改输出目录（tauri.conf.json）
{
  "bundle": {
    "active": true,
    "targets": ["msi", "exe"],
    "windows": {
      "wix": {
        "template": null,
        "fragmentPaths": [],
        "componentGroupRefs": [],
        "componentRefs": [],
        "featureGroupRefs": [],
        "featureRefs": [],
        "mergeRefs": []
      }
    }
  }
}

# 方法3: 修改默认安装路径为当前用户目录
# 在tauri.conf.json中添加:
"bundle": {
  "windows": {
    "installMode": "currentUser"  // 而不是 perMachine
  }
}
```

---

### 场景7: 端口被占用 ❌

```powershell
PS C:\Users\Administrator\projects\cxk-amazon-assistant\frontend> npm run tauri-dev

> cxk-amazon-assistant@1.0.0 dev
> vite

error when starting dev server:
Error: Port 5173 is already in use
    at Server.onError (C:\Users\Administrator\projects\cxk-amazon-assistant\frontend\node_modules\vite\dist\node\chunks\dep-...
```

**错误原因**: Vite默认端口5173被其他程序占用

**解决方案**:
```powershell
# 方法1: 查找并关闭占用端口的程序
netstat -ano | findstr :5173
taskkill /PID <PID> /F

# 方法2: 修改Vite端口
# vite.config.ts
export default defineConfig({
  server: {
    port: 3000,  // 改为其他端口
  }
})

# 方法3: 使用随机可用端口
npm run dev -- --port 0
```

---

### 场景8: Node.js版本不兼容 ❌

```powershell
PS C:\Users\Administrator\projects\cxk-amazon-assistant\frontend> npm install

npm ERR! code EBADENGINE
npm ERR! engine Unsupported engine
npm ERR! engine Not compatible with your version of node/npm: @tauri-apps/cli@2.0.0
npm ERR! notsup Required: {"node":">=18.0.0"}
npm ERR! notsup Actual:   {"npm":"8.5.0","node":"v16.14.0"}
```

**错误原因**: Node.js版本过低（需要v18+）

**解决方案**:
```powershell
# 检查当前版本
node --version  # v16.14.0 ❌

# 使用nvm-windows升级Node.js
nvm install 20
nvm use 20

# 或使用fnm
fnm install 20
fnm use 20

# 验证
node --version  # v20.x.x ✅
```

---

### 场景9: 杀毒软件拦截 ❌

```powershell
PS C:\Users\Administrator\projects\cxk-amazon-assistant\frontend> npm run tauri-dev

   Compiling cxk-amazon-assistant v1.0.0
    Finished dev [unoptimized + debuginfo] target(s) in 23.45s
     Running `target\debug\cxk-amazon-assistant.exe`

Windows Defender SmartScreen: 
"Windows已保护你的电脑"
"Windows Defender SmartScreen阻止了无法识别的应用启动..."
```

**错误原因**: Windows Defender或其他杀毒软件拦截未签名的应用

**解决方案**:
```powershell
# 方法1: 开发阶段点击"更多信息" -> "仍要运行"

# 方法2: 将项目目录添加到Windows Defender排除项
# Windows安全中心 > 病毒和威胁防护 > 排除项 > 添加排除项 > 文件夹
# C:\projects\cxk-amazon-assistant\

# 方法3: 代码签名（生产环境）
# 需要购买代码签名证书，在tauri.conf.json中配置:
"bundle": {
  "windows": {
    "certificateThumbprint": "YOUR_CERT_THUMBPRINT",
    "digestAlgorithm": "sha256",
    "timestampUrl": "http://timestamp.digicert.com"
  }
}
```

---

### 场景10: 依赖下载失败（网络问题）❌

```powershell
PS C:\Users\Administrator\projects\cxk-amazon-assistant\frontend> npm install

npm ERR! code ETIMEDOUT
npm ERR! syscall connect
npm ERR! errno ETIMEDOUT
npm ERR! network request to https://registry.npmjs.org/@tauri-apps%2fapi failed

# 或Rust crate下载失败
error: failed to download from `https://crates.io/api/v1/crates/...
Caused by:
  [28] Timeout was reached (download timed out)
```

**错误原因**: 国内网络访问npm/crates.io受限

**解决方案**:
```powershell
# 配置npm国内镜像
npm config set registry https://registry.npmmirror.com

# 配置Rust国内镜像
# 在 %USERPROFILE%\.cargo\config.toml 添加:
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

# 或使用清华镜像
[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
```

---

## Windows部署检查清单

部署前请确认：

```
□ Node.js v18+ 已安装
  └─ node --version

□ Rust 已安装
  └─ rustc --version

□ Visual Studio Build Tools 已安装
  └─ 包含"使用C++的桌面开发"工作负载

□ WebView2 Runtime 已安装
  └─ 检查: Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'

□ 项目路径为纯英文
  └─ C:\projects\cxk-assistant\ ✓
  └─ C:\我的项目\助手\ ✗

□ 有足够的磁盘空间（至少2GB）

□ 网络连接正常（或使用镜像）

□ 以管理员身份运行终端（可选但推荐）
```

---

## Windows部署成功输出

```powershell
PS C:\Users\Administrator\projects\cxk-amazon-assistant\frontend> npm run tauri-dev

> cxk-amazon-assistant@1.0.0 tauri-dev
> tauri dev

     Running BeforeDevCommand (`npm run dev`)

  VITE v5.0.12  ready in 285 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help

     Running DevCommand (`cargo run`)
     Finished dev [unoptimized + debuginfo] target(s) in 12.34s
      Running `target\debug\cxk-amazon-assistant.exe`

# [应用程序窗口弹出]
# 标题: CXK运营决策助手
# 尺寸: 1400x900
# 状态: ✅ 正常运行
```

---

## Windows生产构建

```powershell
# 构建Windows安装包
cd frontend
npm run tauri-build

# 输出文件位置:
# src-tauri/target/release/bundle/msi/CXK运营决策助手_1.0.0_x64_en-US.msi
# src-tauri/target/release/bundle/nsis/CXK运营决策助手_1.0.0_x64-setup.exe
```

---

## 故障排除流程图

```
开始部署
    │
    ▼
运行 npm install
    │
    ├─ ❌ 报错 EBADENGINE → 升级Node.js到v18+
    │
    ├─ ❌ 报错 ETIMEDOUT → 配置国内npm镜像
    │
    └─ ✅ 成功
         │
         ▼
运行 npm run tauri-dev
    │
    ├─ ❌ "Rust is not installed" → 安装Rust
    │
    ├─ ❌ "link.exe not found" → 安装VS Build Tools
    │
    ├─ ❌ "WebView2 is not installed" → 安装WebView2
    │
    ├─ ❌ 路径包含中文 → 移动到英文路径
    │
    ├─ ❌ 端口被占用 → 修改端口或关闭占用程序
    │
    └─ ✅ 应用启动成功!
```

---

**总结**: Windows部署最常见的问题是 **Rust未安装**、**VS Build Tools缺失**、**WebView2缺失** 这三项。按上述检查清单准备环境，99%的部署都能成功。
