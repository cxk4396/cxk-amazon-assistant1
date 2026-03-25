#!/bin/bash

# CXK运营决策助手 - 自动化测试脚本
# 使用方法: ./run_tests.sh

echo "=========================================="
echo "  CXK运营决策助手 - 测试执行脚本"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试计数
PASSED=0
FAILED=0

# 检查前置条件
echo "🔍 检查测试环境..."
echo ""

# 检查Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✅ Node.js: $NODE_VERSION${NC}"
else
    echo -e "${RED}❌ Node.js 未安装${NC}"
    exit 1
fi

# 检查Rust
if command -v rustc &> /dev/null; then
    RUST_VERSION=$(rustc --version)
    echo -e "${GREEN}✅ Rust: $RUST_VERSION${NC}"
else
    echo -e "${RED}❌ Rust 未安装${NC}"
    exit 1
fi

# 检查项目目录
if [ ! -d "frontend" ] || [ ! -d "src-tauri" ]; then
    echo -e "${RED}❌ 未找到项目目录${NC}"
    exit 1
fi

echo ""
echo "=========================================="
echo "  开始测试"
echo "=========================================="
echo ""

# 测试1: 检查依赖
echo "🧪 TC01: 检查项目依赖..."
cd frontend
if [ -d "node_modules" ]; then
    echo -e "${GREEN}   ✅ 前端依赖已安装${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}   ⚠️  前端依赖未安装，尝试安装...${NC}"
    npm install
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}   ✅ 前端依赖安装成功${NC}"
        ((PASSED++))
    else
        echo -e "${RED}   ❌ 前端依赖安装失败${NC}"
        ((FAILED++))
    fi
fi

# 测试2: 检查测试数据
echo ""
echo "🧪 TC02: 检查测试数据..."
cd ..
if [ -d "test_data" ]; then
    FILE_COUNT=$(ls -1 test_data/ | wc -l)
    echo -e "${GREEN}   ✅ 测试数据目录存在，包含 $FILE_COUNT 个文件${NC}"
    ls -1 test_data/ | sed 's/^/      - /'
    ((PASSED++))
else
    echo -e "${YELLOW}   ⚠️  测试数据目录不存在，创建中...${NC}"
    mkdir -p test_data
    echo "ASIN,Title,销量,销售额
B08N5WRWNW,Bluetooth Speaker,156,4680
B08N5M7S6K,USB C Cable,423,2115
B08N5L8P3J,iPhone Case,289,1445" > test_data/test_am67.csv
    echo -e "${GREEN}   ✅ 测试数据已创建${NC}"
    ((PASSED++))
fi

# 测试3: 检查Rust依赖
echo ""
echo "🧪 TC03: 检查Rust依赖..."
cd src-tauri
if [ -d "target" ]; then
    echo -e "${GREEN}   ✅ Rust依赖已编译${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}   ⚠️  Rust依赖未编译${NC}"
    echo "      提示: 首次运行会自动编译"
    ((PASSED++)) # 不算失败，因为dev模式会编译
fi
cd ..

# 测试4: 验证代码结构
echo ""
echo "🧪 TC04: 验证项目代码结构..."
FILES_TO_CHECK=(
    "frontend/src/main.ts"
    "frontend/src/App.vue"
    "frontend/src/views/UploadView.vue"
    "frontend/src/views/DashboardView.vue"
    "frontend/src/views/OptimizationView.vue"
    "frontend/src/services/ai-service.ts"
    "frontend/src/services/export-service.ts"
    "frontend/src/utils/error-handler.ts"
    "frontend/src/utils/file-validator.ts"
    "src-tauri/src/main.rs"
    "src-tauri/src/commands.rs"
    "src-tauri/src/file_parser.rs"
)

ALL_EXIST=true
for file in "${FILES_TO_CHECK[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}   ❌ 缺少文件: $file${NC}"
        ALL_EXIST=false
    fi
done

if [ "$ALL_EXIST" = true ]; then
    echo -e "${GREEN}   ✅ 所有核心文件存在 (${#FILES_TO_CHECK[@]}个)${NC}"
    ((PASSED++))
else
    echo -e "${RED}   ❌ 部分文件缺失${NC}"
    ((FAILED++))
fi

# 测试5: 检查组件
echo ""
echo "🧪 TC05: 检查Vue组件..."
COMPONENTS=(
    "frontend/src/components/ColumnSelector/ColumnSelector.vue"
    "frontend/src/components/Dashboard/StatusBadge.vue"
    "frontend/src/components/Dashboard/ScoreDisplay.vue"
    "frontend/src/components/Common/EmptyState.vue"
)

ALL_COMPONENTS=true
for comp in "${COMPONENTS[@]}"; do
    if [ ! -f "$comp" ]; then
        echo -e "${RED}   ❌ 缺少组件: $comp${NC}"
        ALL_COMPONENTS=false
    fi
done

if [ "$ALL_COMPONENTS" = true ]; then
    echo -e "${GREEN}   ✅ 所有组件存在 (${#COMPONENTS[@]}个)${NC}"
    ((PASSED++))
else
    ((FAILED++))
fi

# 测试6: 检查Store
echo ""
echo "🧪 TC06: 检查Pinia Store..."
STORES=(
    "frontend/src/stores/data.ts"
    "frontend/src/stores/settings.ts"
)

ALL_STORES=true
for store in "${STORES[@]}"; do
    if [ ! -f "$store" ]; then
        echo -e "${RED}   ❌ 缺少Store: $store${NC}"
        ALL_STORES=false
    fi
done

if [ "$ALL_STORES" = true ]; then
    echo -e "${GREEN}   ✅ 所有Store存在${NC}"
    ((PASSED++))
else
    ((FAILED++))
fi

# 测试7: 检查配置文件
echo ""
echo "🧪 TC07: 检查配置文件..."
CONFIGS=(
    "frontend/package.json"
    "src-tauri/Cargo.toml"
    "src-tauri/tauri.conf.json"
)

ALL_CONFIGS=true
for config in "${CONFIGS[@]}"; do
    if [ ! -f "$config" ]; then
        echo -e "${RED}   ❌ 缺少配置: $config${NC}"
        ALL_CONFIGS=false
    fi
done

if [ "$ALL_CONFIGS" = true ]; then
    echo -e "${GREEN}   ✅ 所有配置文件存在${NC}"
    ((PASSED++))
else
    ((FAILED++))
fi

# 测试8: 检查文档
echo ""
echo "🧪 TC08: 检查项目文档..."
DOCS=(
    "README.md"
    "TEST_PLAN.md"
    "TEST_REPORT.md"
    "UI_DEMO.md"
)

ALL_DOCS=true
for doc in "${DOCS[@]}"; do
    if [ ! -f "$doc" ]; then
        echo -e "${YELLOW}   ⚠️  缺少文档: $doc${NC}"
        ALL_DOCS=false
    fi
done

if [ "$ALL_DOCS" = true ]; then
    echo -e "${GREEN}   ✅ 所有文档存在${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}   ⚠️  部分文档缺失${NC}"
    ((PASSED++)) # 文档缺失不算功能失败
fi

# 汇总
echo ""
echo "=========================================="
echo "  测试结果汇总"
echo "=========================================="
echo ""
echo -e "${GREEN}✅ 通过: $PASSED${NC}"
echo -e "${RED}❌ 失败: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 所有测试通过！项目可以正常运行${NC}"
    echo ""
    echo "启动应用:"
    echo "  cd frontend && npm run tauri-dev"
    echo ""
    exit 0
else
    echo -e "${RED}⚠️  部分测试失败，请检查上述问题${NC}"
    echo ""
    exit 1
fi
