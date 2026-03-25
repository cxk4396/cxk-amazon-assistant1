<template>
  <div class="dashboard-view">
    <!-- 核心指标概览 -->
    <el-card>
      <template #header>
        <div class="card-header">
          <span><</> 核心指标概览</span>
          <el-tag type="info">共分析 {{ asinCount }} 个ASIN</el-tag>
        </div>
      </template>

      <div class="metrics-grid">
        <div class="metric-card">
          <div class="metric-label">总曝光量</div>
          <div class="metric-value">{{ formatNumber(totalImpressions) }}</div>
        </div>
        <div class="metric-card">
          <div class="metric-label">总点击量</div>
          <div class="metric-value">{{ formatNumber(totalClicks) }}</div>
        </div>
        <div class="metric-card">
          <div class="metric-label">总订单量</div>
          <div class="metric-value">{{ formatNumber(totalOrders) }}</div>
        </div>
        <div class="metric-card">
          <div class="metric-label">总销售额</div>
          <div class="metric-value">${{ formatNumber(totalSales) }}</div>
        </div>
      </div>
    </el-card>

    <!-- ASIN健康度矩阵 -->
    <el-card class="section-card">
      <template #header>
        <div class="card-header">
          <span><</> ASIN健康度矩阵</span>
          <div class="header-actions">
            <el-button type="primary" @click="generateOptimization" :disabled="asinData.length === 0">
              批量生成优化方案
            </el-button>
            <el-button @click="exportReport" :disabled="asinData.length === 0">
              导出完整报告
            </el-button>
          </div>
        </div>
      </template>

      <el-table :data="asinData" style="width: 100%" v-loading="loading">
        <el-table-column prop="asin" label="ASIN" width="140" >
          <template #default="{ row }">
            <span class="asin-code">{{ row.asin }}</span>
          </template>
        </el-table-column>
        
        <el-table-column label="标题" min-width="200" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.title || '-' }}
          </template>
        </el-table-column>
        
        <el-table-column label="曝光状态" width="100" align="center">
          <template #default="{ row }">
            <status-badge :status="row.exposureStatus" />
          </template>
        </el-table-column>
        
        <el-table-column label="点击状态" width="100" align="center">
          <template #default="{ row }">
            <status-badge :status="row.clickStatus" />
          </template>
        </el-table-column>
        
        <el-table-column label="转化状态" width="100" align="center">
          <template #default="{ row }">
            <status-badge :status="row.conversionStatus" />
          </template>
        </el-table-column>
        
        <el-table-column label="综合评分" width="100" align="center">
          <template #default="{ row }">
            <score-display :score="row.healthScore || 0" />
          </template>
        </el-table-column>
        
        <el-table-column label="操作" width="100" align="center">
          <template #default="{ row }">
            <el-button type="primary" link @click="diagnose(row)">
              [诊断]
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-empty v-if="asinData.length === 0 && !loading" description="暂无数据，请先上传数据文件" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'
import { useDataStore } from '../stores/data'
import StatusBadge from '../components/Dashboard/StatusBadge.vue'
import ScoreDisplay from '../components/Dashboard/ScoreDisplay.vue'

const router = useRouter()
const dataStore = useDataStore()
const loading = ref(false)

const asinData = computed(() => dataStore.asinData)
const asinCount = computed(() => asinData.value.length)

// 计算核心指标
const totalImpressions = computed(() => {
  return asinData.value.reduce((sum, item) => {
    const sessions = parseInt(item.traffic?.['Sessions'] || item.traffic?.['Sessions - Total'] || 0)
    return sum + sessions
  }, 0)
})

const totalClicks = computed(() => {
  return asinData.value.reduce((sum, item) => {
    const views = parseInt(item.traffic?.['Page Views'] || item.traffic?.['Page Views - Total'] || 0)
    return sum + views
  }, 0)
})

const totalOrders = computed(() => {
  return asinData.value.reduce((sum, item) => {
    const orders = parseInt(item.sales?.['Ordered Units'] || item.sales?.['销量'] || 0)
    return sum + orders
  }, 0)
})

const totalSales = computed(() => {
  return asinData.value.reduce((sum, item) => {
    const sales = parseFloat(item.sales?.['Ordered Revenue'] || item.sales?.['销售额'] || 0)
    return sum + sales
  }, 0)
})

const formatNumber = (num: number) => {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + 'M'
  } else if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'K'
  }
  return num.toString()
}

onMounted(() => {
  if (dataStore.hasData && dataStore.asinData.length === 0) {
    loading.value = true
    // 合并数据
    dataStore.mergeDataByAsin()
    loading.value = false
  }
})

const generateOptimization = () => {
  if (asinData.value.length === 0) {
    ElMessage.warning('暂无数据可分析')
    return
  }
  router.push('/optimization')
}

const exportReport = () => {
  ElMessage.info('导出功能开发中...')
}

const diagnose = (row: any) => {
  router.push({
    path: '/optimization',
    query: { asin: row.asin }
  })
}
</script>

<style scoped>
.dashboard-view {
  max-width: 1200px;
  margin: 0 auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.section-card {
  margin-top: 20px;
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.metric-card {
  padding: 24px;
  background: linear-gradient(135deg, #f5f7fa 0%, #ffffff 100%);
  border-radius: 8px;
  text-align: center;
  border: 1px solid #ebeef5;
}

.metric-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 12px;
}

.metric-value {
  font-size: 32px;
  font-weight: bold;
  color: #303133;
}

.asin-code {
  font-family: 'Courier New', monospace;
  font-weight: 500;
  color: #409eff;
}

@media (max-width: 1200px) {
  .metrics-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
