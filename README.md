# CXK运营决策助手

基于Tauri + Vue 3 + Rust的亚马逊运营决策桌面应用。

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## 功能特性

- 📁 **批量上传** - 支持5种标准格式的Excel/CSV文件
- 🔍 **智能列选择** - 搜索/选择/模板三种模式，灵活配置数据列
- 🤖 **AI智能诊断** - 基于A9+COSMO算法的深度数据分析
- 💡 **三维度优化** - 自动生成链接/广告/评分优化方案
- 📊 **数据可视化** - 核心指标看板，ASIN健康度矩阵
- 📝 **一键导出** - Amazon Listing/广告批量操作模板

## 技术栈

- **前端**: Vue 3 + TypeScript + Element Plus
- **后端**: Rust + Tauri
- **数据库**: SQLite
- **AI API**: OpenAI兼容接口 (推荐 timebackward.com)

## 安装

### 前置要求

1. **Node.js** (v18+)
2. **Rust** (v1.77+)
3. **Visual Studio Build Tools** (Windows必需)

### Windows一键部署

在Windows上推荐使用一键部署脚本：

```powershell
# 1. 以管理员身份打开 PowerShell
# 2. 进入项目目录
cd cxk-amazon-assistant

# 3. 运行部署脚本（首次运行可能需要设置执行策略）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\deploy-windows.ps1
```

脚本会自动检查并安装缺失的依赖（Rust、WebView2等）。

**Windows部署常见问题**：
- 详细Windows部署指南: [WINDOWS_DEPLOY.md](WINDOWS_DEPLOY.md)
- 常见错误及解决方案: [WINDOWS_DEPLOY.md#部署场景模拟](WINDOWS_DEPLOY.md)

### macOS/Linux 开发环境搭建

```bash
# 1. 克隆项目
git clone <repository-url>
cd cxk-amazon-assistant

# 2. 安装前端依赖
cd frontend
npm install

# 3. 安装Rust依赖
cd ../src-tauri
cargo fetch
```

### 运行开发服务器

```bash
cd frontend
npm run tauri-dev
```

### 构建生产版本

```bash
cd frontend
npm run tauri-build
```

构建产物将位于 `src-tauri/target/release/bundle/` 目录。

## 使用指南

### 第一步：配置AI API

1. 打开「系统设置」页面
2. 配置API信息：
   - **Base URL**: `https://api.timebackward.com/v1` (推荐)
   - **API Key**: 您的API密钥
   - **模型**: 推荐 Claude Sonnet 4.6
3. 点击「测试连接」验证配置

### 第二步：上传数据文件

支持以下5种文件格式：

| 文件类型 | 格式 | 说明 |
|---------|------|------|
| AM67销售数据 | .xlsx/.csv | 基础销售数据 |
| Business Report | .csv | 流量转化数据 |
| 库存报告 | .xlsx (Template工作表) | 文案与价格 |
| 竞品数据 | .xlsx/.csv | 卖家精灵竞品数据 |
| 广告报告 | .xlsx/.csv | 广告效果数据 |

上传后可使用「选择列」功能筛选需要的列，减少Token消耗。

### 第三步：查看数据看板

上传完成后点击「开始AI分析」，进入数据看板查看：
- 核心指标概览（曝光/点击/订单/销售额）
- ASIN健康度矩阵
- 各维度状态评估

### 第四步：生成优化方案

在「AI优化方案」页面：
1. 选择要分析的ASIN（支持批量分析）
2. 等待AI生成诊断结果
3. 查看三维度优化建议：
   - **链接优化**: Title、Bullet、关键词、Search Terms
   - **广告优化**: 竞价调整、关键词建议、预算建议
   - **评分优化**: 评分目标、送测策略

### 第五步：导出Amazon模板

优化方案确认后，可导出：
- **Listing模板**: Amazon Flat File格式，直接批量上传
- **广告模板**: CSV格式，批量操作广告

支持单ASIN导出或批量导出所有ASIN。

## 项目结构

```
cxk-amazon-assistant/
├── frontend/                  # Vue 3前端
│   ├── src/
│   │   ├── components/        # UI组件
│   │   │   ├── ColumnSelector/   # 列选择器
│   │   │   ├── Dashboard/        # 数据看板组件
│   │   │   └── Common/           # 通用组件
│   │   ├── views/             # 页面视图
│   │   ├── stores/            # Pinia状态管理
│   │   ├── services/          # 业务服务
│   │   │   ├── ai-service.ts   # AI分析服务
│   │   │   └── export-service.ts # 导出服务
│   │   ├── utils/             # 工具函数
│   │   │   ├── tauri.ts        # Tauri调用
│   │   │   ├── file-validator.ts # 文件验证
│   │   │   └── error-handler.ts  # 错误处理
│   │   └── router/            # 路由配置
│   └── package.json
├── src-tauri/                 # Rust后端
│   ├── src/
│   │   ├── main.rs            # 应用入口
│   │   ├── commands.rs        # Tauri命令
│   │   ├── file_parser.rs     # 文件解析引擎
│   │   └── database.rs        # 数据库Schema
│   ├── icons/                 # 应用图标
│   └── Cargo.toml
└── README.md
```

## 数据安全

- 所有数据处理均在本地完成，不上传至云端
- API仅用于AI分析，仅传输必要的文本数据
- 文件解析使用本地Rust引擎，无需网络

## 支持的Amazon市场

- 美国站 (US)
- 欧洲站 (EU) - 即将支持
- 日本站 (JP) - 即将支持

## 故障排除

### 文件上传失败

1. 检查文件格式是否为 .xlsx/.xls/.csv
2. 确保文件大小不超过50MB
3. 检查文件是否被其他程序占用

### AI分析失败

1. 检查API配置是否正确
2. 点击「测试连接」验证API可用性
3. 检查网络连接
4. 查看错误日志（控制台）

### 导出失败

1. 确保已选择导出路径
2. 检查磁盘空间
3. 确保有写入权限

## 开发计划

- [x] 项目框架搭建
- [x] 前端UI界面
- [x] 后端Rust核心模块
- [x] 文件解析引擎
- [x] 数据列选择器
- [x] AI分析服务
- [x] 优化方案展示
- [x] Amazon模板导出
- [x] 全局错误处理
- [x] 文件验证
- [ ] 多语言支持
- [ ] 数据缓存优化
- [ ] 更多Amazon市场支持

## 贡献

欢迎提交Issue和Pull Request！

## License

MIT License - 详见 [LICENSE](LICENSE) 文件

## 联系方式

如有问题或建议，请通过以下方式联系：
- 邮箱: support@cxk-team.com
- 微信: CXK_Assistant

---

**CXK运营决策助手** - 让亚马逊运营更智能
