<template>
  <div class="app-container">
    <el-container>
      <!-- 侧边导航 -->
      <el-aside width="200px" class="sidebar">
        <div class="logo">
          <el-icon class="logo-icon"><Shop /></el-icon>
          <span class="logo-text">CXK助手</span>
        </div>
        <el-menu
          :default-active="$route.path"
          router
          class="nav-menu"
          background-color="#232F3E"
          text-color="#ffffff"
          active-text-color="#FF9900"
        >
          <el-menu-item index="/">
            <el-icon><HomeFilled /></el-icon>
            <span>首页</span>
          </el-menu-item>
          <el-menu-item index="/upload">
            <el-icon><UploadFilled /></el-icon>
            <span>数据上传</span>
          </el-menu-item>
          <el-menu-item index="/dashboard">
            <el-icon><DataAnalysis /></el-icon>
            <span>数据看板</span>
          </el-menu-item>
          <el-menu-item index="/optimization">
            <el-icon><MagicStick /></el-icon>
            <span>优化方案</span>
          </el-menu-item>
          <el-menu-item index="/templates">
            <el-icon><DocumentCopy /></el-icon>
            <span>模板管理</span>
          </el-menu-item>
          <el-menu-item index="/settings">
            <el-icon><Setting /></el-icon>
            <span>系统设置</span>
          </el-menu-item>
        </el-menu>
      </el-aside>

      <!-- 主内容区 -->
      <el-container class="main-container">
        <el-header class="header">
          <div class="header-left">
            <h2 class="page-title">{{ pageTitle }}</h2>
          </div>
          <div class="header-right">
            <el-button type="text" @click="showShortcutsHelp">
              <el-icon><Keyboard /></el-icon> 快捷键
            </el-button>
            <el-button type="text" @click="showHelp">
              <el-icon><QuestionFilled /></el-icon> 帮助
            </el-button>
          </div>
        </el-header>
        
        <el-main class="main-content">
          <router-view />
        </el-main>
      </el-container>
    </el-container>

    <!-- 快捷键帮助对话框 -->
    <el-dialog v-model="shortcutsVisible" title="⌨️ 快捷键" width="500px">
      <el-table :data="shortcutsList" stripe>
        <el-table-column prop="shortcut" label="快捷键" width="150">
          <template #default="{ row }">
            <el-tag size="small">{{ row.shortcut }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="功能" />
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useSettingsStore } from './stores/settings'
import { registerShortcut, initShortcuts } from './utils/shortcuts'

const route = useRoute()
const router = useRouter()
const settingsStore = useSettingsStore()
const shortcutsVisible = ref(false)

const pageTitle = computed(() => {
  const titles: Record<string, string> = {
    '/': '首页',
    '/upload': '数据上传中心',
    '/dashboard': '数据看板',
    '/optimization': 'AI优化方案',
    '/templates': '模板管理',
    '/settings': '系统设置'
  }
  return titles[route.path] || 'CXK运营决策助手'
})

// 快捷键列表
const shortcutsList = [
  { shortcut: 'Ctrl + 1', description: '前往数据上传' },
  { shortcut: 'Ctrl + 2', description: '前往数据看板' },
  { shortcut: 'Ctrl + 3', description: '前往AI优化' },
  { shortcut: 'Ctrl + ,', description: '前往设置' },
  { shortcut: 'Ctrl + R', description: '刷新数据' },
  { shortcut: 'Ctrl + S', description: '保存' },
  { shortcut: 'Ctrl + E', description: '导出' },
  { shortcut: 'Ctrl + F', description: '搜索' },
  { shortcut: '?', description: '显示快捷键帮助' }
]

onMounted(() => {
  // 加载保存的设置
  settingsStore.loadSettings()

  // 注册快捷键
  registerShortcut({
    key: '1',
    ctrl: true,
    handler: () => router.push('/upload'),
    description: '前往数据上传'
  })
  registerShortcut({
    key: '2',
    ctrl: true,
    handler: () => router.push('/dashboard'),
    description: '前往数据看板'
  })
  registerShortcut({
    key: '3',
    ctrl: true,
    handler: () => router.push('/optimization'),
    description: '前往AI优化'
  })
  registerShortcut({
    key: ',',
    ctrl: true,
    handler: () => router.push('/settings'),
    description: '前往设置'
  })
  registerShortcut({
    key: '?',
    handler: () => showShortcutsHelp(),
    description: '显示快捷键帮助'
  })

  initShortcuts()
})

const showHelp = () => {
  ElMessage.info('请查看README.md获取详细帮助')
}

const showShortcutsHelp = () => {
  shortcutsVisible.value = true
}
</script>

<style scoped>
.app-container {
  height: 100vh;
}

.sidebar {
  background: #232F3E;
  color: white;
  display: flex;
  flex-direction: column;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.logo-icon {
  font-size: 24px;
  color: #FF9900;
  margin-right: 8px;
}

.logo-text {
  font-size: 18px;
  font-weight: bold;
  color: white;
}

.nav-menu {
  border-right: none;
  flex: 1;
}

.nav-menu :deep(.el-menu-item.is-active) {
  background-color: rgba(255, 153, 0, 0.15) !important;
}

.main-container {
  background: #f5f7fa;
}

.header {
  background: white;
  border-bottom: 1px solid #e4e7ed;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
}

.page-title {
  margin: 0;
  font-size: 18px;
  color: #303133;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.main-content {
  padding: 20px;
  overflow-y: auto;
}
</style>
