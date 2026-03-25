import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import 'element-plus/dist/index.css'
import './style.css'
import App from './App.vue'
import router from './router'
import { initGlobalErrorHandler } from './utils/error-handler'

const app = createApp(App)

// 注册所有Element Plus图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

// 初始化全局错误处理
initGlobalErrorHandler()

app.use(createPinia())
app.use(ElementPlus)
app.use(router)
app.mount('#app')
