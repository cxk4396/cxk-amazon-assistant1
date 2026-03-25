import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('../views/HomeView.vue')
  },
  {
    path: '/upload',
    name: 'Upload',
    component: () => import('../views/UploadView.vue')
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('../views/DashboardView.vue')
  },
  {
    path: '/optimization',
    name: 'Optimization',
    component: () => import('../views/OptimizationView.vue')
  },
  {
    path: '/templates',
    name: 'Templates',
    component: () => import('../views/TemplatesView.vue')
  },
  {
    path: '/settings',
    name: 'Settings',
    component: () => import('../views/SettingsView.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
