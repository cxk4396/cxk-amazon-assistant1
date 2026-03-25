import { onMounted, onUnmounted } from 'vue'

type KeyHandler = (event: KeyboardEvent) => void

interface ShortcutConfig {
  key: string
  ctrl?: boolean
  alt?: boolean
  shift?: boolean
  meta?: boolean
  handler: KeyHandler
  description?: string
}

const shortcuts: ShortcutConfig[] = []

/**
 * 注册全局快捷键
 */
export function registerShortcut(config: ShortcutConfig) {
  shortcuts.push(config)
}

/**
 * 注销快捷键
 */
export function unregisterShortcut(key: string, ctrl = false, alt = false) {
  const index = shortcuts.findIndex(
    s => s.key === key && s.ctrl === ctrl && s.alt === alt
  )
  if (index > -1) {
    shortcuts.splice(index, 1)
  }
}

/**
 * 匹配快捷键
 */
function matchShortcut(event: KeyboardEvent, config: ShortcutConfig): boolean {
  const keyMatch = event.key.toLowerCase() === config.key.toLowerCase()
  const ctrlMatch = !!config.ctrl === event.ctrlKey
  const altMatch = !!config.alt === event.altKey
  const shiftMatch = !!config.shift === event.shiftKey
  const metaMatch = !!config.meta === event.metaKey

  return keyMatch && ctrlMatch && altMatch && shiftMatch && metaMatch
}

/**
 * 处理键盘事件
 */
function handleKeyDown(event: KeyboardEvent) {
  for (const shortcut of shortcuts) {
    if (matchShortcut(event, shortcut)) {
      event.preventDefault()
      shortcut.handler(event)
      break
    }
  }
}

/**
 * 初始化快捷键系统
 */
export function initShortcuts() {
  onMounted(() => {
    document.addEventListener('keydown', handleKeyDown)
  })

  onUnmounted(() => {
    document.removeEventListener('keydown', handleKeyDown)
  })
}

/**
 * 获取所有快捷键列表
 */
export function getShortcutsList(): ShortcutConfig[] {
  return [...shortcuts]
}

// 常用快捷键预设
export const commonShortcuts = {
  // 导航
  goToUpload: { key: '1', ctrl: true, description: '前往数据上传' },
  goToDashboard: { key: '2', ctrl: true, description: '前往数据看板' },
  goToOptimization: { key: '3', ctrl: true, description: '前往AI优化' },
  goToSettings: { key: ',', ctrl: true, description: '前往设置' },

  // 操作
  refresh: { key: 'r', ctrl: true, description: '刷新数据' },
  save: { key: 's', ctrl: true, description: '保存' },
  export: { key: 'e', ctrl: true, description: '导出' },
  search: { key: 'f', ctrl: true, description: '搜索' },

  // 帮助
  help: { key: '?', description: '显示快捷键帮助' }
}
