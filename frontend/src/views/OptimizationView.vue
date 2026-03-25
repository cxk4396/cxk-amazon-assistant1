<template>
  <div class="optimization-view">
    <!-- ASIN选择 -->
    <el-card>
      <template #header>
        <div class="card-header">
          <span>💡 选择ASIN进行分析</span>
          <el-button 
            type="primary" 
            :loading="analyzing"
            :disabled="asinData.length === 0"
            @click="analyzeAll"
          >
            {{ analyzing ? `分析中 ${progress}/${asinData.length}` : '批量分析全部' }}
          </el-button>
        </div>
      </template>

      <div class="asin-selector">
        <el-select v-model="selectedAsin" placeholder="选择要分析的ASIN" style="width: 300px" @change="handleAsinChange">
          <el-option 
            v-for="item in asinData" 
            :key="item.asin" 
            :label="`${item.asin} - ${item.title?.substring(0, 30) || '无标题'}...`" 
            :value="item.asin" 
          />
        </el-select>
        <span v-if="currentResult" class="score-display">
          综合评分: <score-display :score="currentResult.diagnosis.score" />
        </span>
      </div>
    </el-card>

    <!-- 分析中提示 -->
    <el-card v-if="analyzing && !currentResult" class="section-card">
      <div class="analyzing-state">
        <el-icon class="analyzing-icon" :size="48"><Loading /></el-icon>
        <p>正在调用AI分析数据，请稍候...{{ progress > 0 ? `(${progress}/${asinData.length})` : '' }}</p>
        <el-progress :percentage="progressPercent" />
      </div>
    </el-card>

    <!-- 诊断结果 -->
    <el-card v-if="currentResult && !analyzing" class="section-card">
      <template #header>
        <div class="card-header">
          <span>📊 数据诊断结果</span>
          <el-tag :type="healthTagType">{{ currentResult.diagnosis.overallHealth }}</el-tag>
        </div>
      </template>

      <div class="diagnosis-result">
        <div class="diagnosis-item">
          <span class="diagnosis-label">🔍 诊断:</span>
          <span class="diagnosis-value">{{ currentResult.diagnosis.primaryIssue }}</span>
        </div>
        <div class="diagnosis-item">
          <span class="diagnosis-label">📊 数据:</span>
          <div class="metrics-tags">
            <el-tag :type="getStatusType(currentResult.metrics.exposure.status)">
              曝光: {{ currentResult.metrics.exposure.status }}
            </el-tag>
            <el-tag :type="getStatusType(currentResult.metrics.click.status)">
              点击: {{ currentResult.metrics.click.status }}
            </el-tag>
            <el-tag :type="getStatusType(currentResult.metrics.conversion.status)">
              转化: {{ currentResult.metrics.conversion.status }}
            </el-tag>
          </div>
        </div>
        <div class="diagnosis-item">
          <span class="diagnosis-label">🎯 根因:</span>
          <span class="diagnosis-value">{{ currentResult.diagnosis.rootCause }}</span>
        </div>
      </div>
    </el-card>

    <!-- 优化方案Tab -->
    <el-card v-if="currentResult && !analyzing" class="section-card">
      <template #header>
        <div class="card-header">
          <span>✨ AI优化方案</span>
          <div>
            <el-button type="primary" link @click="exportAllListingsHandler">
              <el-icon><Download /></el-icon> 批量导出所有Listing
            </el-button>
            <el-button type="primary" link @click="exportAllAdvertisingHandler">
              <el-icon><Download /></el-icon> 批量导出所有广告
            </el-button>
          </div>
        </div>
      </template>

      <el-tabs v-model="activeTab" type="border-card">
        <!-- 链接优化 -->
        <el-tab-pane label="链接优化" name="listing">
          <div class="optimization-section">
            <h4>📌 关键词优化建议</h4>
            <div class="keyword-suggestions">
              <div class="keyword-group">
                <span class="group-label">新增关键词:</span>
                <el-tag v-for="kw in currentResult.optimization.listing.keywordsToAdd" :key="kw" type="success">
                  {{ kw }}
                </el-tag>
              </div>
              
              <div class="keyword-group" v-if="currentResult.optimization.listing.keywordsToOptimize.length > 0">
                <span class="group-label">优化关键词:</span>
                <el-tag v-for="kw in currentResult.optimization.listing.keywordsToOptimize" :key="kw" type="warning">
                  {{ kw }}
                </el-tag>
              </div>
            </div>
          </div>

          <div class="optimization-section">
            <h4>📝 AI生成完整文案</h4>
            
            <div class="form-item">
              <label>优化后的Title:</label>
              <el-input
                v-model="currentResult.optimization.listing.optimizedTitle"
                type="textarea"
                :rows="2"
                readonly
              />
              <el-button type="primary" link @click="copyText(currentResult.optimization.listing.optimizedTitle)">复制</el-button>
            </div>
            
            <div class="form-item">
              <label>优化后的五点描述:</label>
              <div class="bullet-points">
                <div v-for="(bullet, index) in currentResult.optimization.listing.optimizedBullets" :key="index" class="bullet-item">
                  <el-input
                    v-model="currentResult.optimization.listing.optimizedBullets[index]"
                    type="textarea"
                    :rows="2"
                    readonly
                  />
                  <el-button type="primary" link @click="copyText(bullet)">复制</el-button>
                </div>
              </div>
            </div>
            
            <div class="form-item">
              <label>优化后的Search Terms:</label>
              <el-input
                v-model="currentResult.optimization.listing.optimizedSearchTerms"
                type="textarea"
                :rows="2"
                readonly
              />
              <el-button type="primary" link @click="copyText(currentResult.optimization.listing.optimizedSearchTerms)">复制</el-button>
            </div>

            <div class="rationale">
              <strong>优化理由:</strong> {{ currentResult.optimization.listing.rationale }}
            </div>
          </div>

          <div class="action-buttons">
            <el-button type="primary" @click="exportListingTemplate">导出Listing模板</el-button>
          </div>
        </el-tab-pane>

        <!-- 广告优化 -->
        <el-tab-pane label="广告优化" name="advertising">
          <div class="optimization-section">
            <el-descriptions :column="1" border title="广告优化建议">
              <el-descriptions-item label="竞价调整">
                ${{ currentResult.optimization.advertising.bidAdjustment.current }} → 
                ${{ currentResult.optimization.advertising.bidAdjustment.recommended }}
                <div class="item-desc">{{ currentResult.optimization.advertising.bidAdjustment.rationale }}</div>
              </el-descriptions-item>
              
              <el-descriptions-item label="新增关键词">
                <el-tag v-for="kw in currentResult.optimization.advertising.keywordsToAdd" :key="kw.keyword">
                  {{ kw.keyword }} ({{ kw.matchType }}) ${{ kw.suggestedBid }}
                </el-tag>
              </el-descriptions-item>
              
              <el-descriptions-item label="投放建议">
                <ul>
                  <li v-for="(suggestion, idx) in currentResult.optimization.advertising.campaignSuggestions" :key="idx">
                    {{ suggestion }}
                  </li>
                </ul>
              </el-descriptions-item>
              
              <el-descriptions-item label="预算建议">
                每日预算 ${{ currentResult.optimization.advertising.budgetAdjustment.current }} → 
                ${{ currentResult.optimization.advertising.budgetAdjustment.recommended }}
              </el-descriptions-item>
            </el-descriptions>
          </div>

          <div class="action-buttons">
            <el-button type="primary" @click="exportAdvertisingTemplate">导出广告批量操作模板</el-button>
          </div>
        </el-tab-pane>

        <!-- 评分优化 -->
        <el-tab-pane label="评分优化" name="review">
          <div class="optimization-section">
            <el-descriptions :column="2" border title="评分优化建议">
              <el-descriptions-item label="当前评分">
                {{ currentResult.optimization.review.currentRating }} 
                ({{ currentResult.optimization.review.currentCount }}评)
              </el-descriptions-item>
              
              <el-descriptions-item label="目标">
                {{ currentResult.optimization.review.targetRating }}+ 
                ({{ currentResult.optimization.review.targetCount }}评)
              </el-descriptions-item>
              
            </el-descriptions>

            <div class="review-strategy">
              <h4>📋 送测策略</h4>
              <p>{{ currentResult.optimization.review.strategy }}</p>
            </div>

            <div class="review-warning">
              <h4>⚠️ 注意事项</h4>
              <p>{{ currentResult.optimization.review.warning }}</p>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useDataStore } from '../stores/data'
import { analyzeAsin, type AIAnalysisResult, type AnalysisInput } from '../services/ai-service'
import { useSettingsStore } from '../stores/settings'
import {
  exportListingTemplate as exportListing,
  exportAdvertisingTemplate as exportAdvertising,
  exportAllListings,
  exportAllAdvertising,
  convertAIResultToListingData,
  convertAIResultToAdvertisingData
} from '../services/export-service'
import ScoreDisplay from '../components/Dashboard/ScoreDisplay.vue'

const dataStore = useDataStore()
const settingsStore = useSettingsStore()

const asinData = computed(() => dataStore.asinData)
const selectedAsin = ref('')
const activeTab = ref('listing')
const analyzing = ref(false)
const progress = ref(0)
const currentResult = ref<AIAnalysisResult | null>(null)
const analysisResults = ref<Record<string, AIAnalysisResult>>({})

const progressPercent = computed(() => {
  if (asinData.value.length === 0) return 0
  return Math.round((progress.value / asinData.value.length) * 100)
})

const healthTagType = computed(() => {
  if (!currentResult.value) return 'info'
  const health = currentResult.value.diagnosis.overallHealth
  if (health.includes('健康')) return 'success'
  if (health.includes('亚')) return 'warning'
  return 'danger'
})

onMounted(() => {
  if (dataStore.hasData && dataStore.asinData.length === 0) {
    dataStore.mergeDataByAsin()
  }
  
  // 如果有ASIN数据，默认选中第一个
  if (asinData.value.length > 0) {
    selectedAsin.value = asinData.value[0].asin
    handleAsinChange()
  }
})

const handleAsinChange = () => {
  // 如果已有分析结果，直接显示
  if (analysisResults.value[selectedAsin.value]) {
    currentResult.value = analysisResults.value[selectedAsin.value]
  } else {
    currentResult.value = null
  }
}

const analyzeAll = async () => {
  if (!settingsStore.apiConfig.apiKey) {
    ElMessage.warning('请先在设置中配置AI API')
    return
  }

  analyzing.value = true
  progress.value = 0
  currentResult.value = null

  for (const item of asinData.value) {
    try {
      const input: AnalysisInput = {
        asin: item.asin,
        title: item.title,
        sales: item.sales,
        traffic: item.traffic,
        advertising: item.advertising,
        listing: item.listing,
        competitor: item.competitor,
        params: {
          targetMargin: dataStore.params.targetMargin || undefined,
          targetAcos: dataStore.params.targetAcos || undefined,
          contentStyle: dataStore.params.contentStyle
        }
      }

      const result = await analyzeAsin(settingsStore.apiConfig, input)
      analysisResults.value[item.asin] = result
      
      // 如果是当前选中的ASIN，显示结果
      if (item.asin === selectedAsin.value) {
        currentResult.value = result
      }
    } catch (error) {
      console.error(`分析ASIN ${item.asin} 失败:`, error)
      ElMessage.error(`分析ASIN ${item.asin} 失败`)
    }
    
    progress.value++
  }

  analyzing.value = false
  ElMessage.success(`已完成 ${progress.value} 个ASIN的分析`)
}

const getStatusType = (status: string) => {
  if (status.includes('正常')) return 'success'
  if (status.includes('严重')) return 'danger'
  if (status.includes('低') || status.includes('异常')) return 'warning'
  return 'info'
}

const copyText = (text: string) => {
  navigator.clipboard.writeText(text).then(() => {
    ElMessage.success('已复制到剪贴板')
  }).catch(() => {
    ElMessage.error('复制失败')
  })
}

const exportListingTemplate = async () => {
  if (!currentResult.value || !selectedAsin.value) {
    ElMessage.warning('请选择一个已分析的ASIN')
    return
  }

  const data = convertAIResultToListingData(
    selectedAsin.value,
    selectedAsin.value,
    currentResult.value
  )

  const success = await exportListing([data])
  if (success) {
    ElMessage.success('Listing模板导出成功')
  } else {
    ElMessage.error('导出失败')
  }
}

const exportAdvertisingTemplate = async () => {
  if (!currentResult.value || !selectedAsin.value) {
    ElMessage.warning('请选择一个已分析的ASIN')
    return
  }

  const data = convertAIResultToAdvertisingData(selectedAsin.value, currentResult.value)

  if (data.length === 0) {
    ElMessage.warning('没有可导出的广告关键词')
    return
  }

  const success = await exportAdvertising(data)
  if (success) {
    ElMessage.success('广告批量模板导出成功')
  } else {
    ElMessage.error('导出失败')
  }
}

// 批量导出所有
const exportAllListingsHandler = async () => {
  if (Object.keys(analysisResults.value).length === 0) {
    ElMessage.warning('请先进行分析')
    return
  }

  const success = await exportAllListings(analysisResults.value)
  if (success) {
    ElMessage.success('批量Listing模板导出成功')
  } else {
    ElMessage.error('导出失败')
  }
}

const exportAllAdvertisingHandler = async () => {
  if (Object.keys(analysisResults.value).length === 0) {
    ElMessage.warning('请先进行分析')
    return
  }

  const success = await exportAllAdvertising(analysisResults.value)
  if (success) {
    ElMessage.success('批量广告模板导出成功')
  } else {
    ElMessage.error('导出失败')
  }
}
</script>

<style scoped>
.optimization-view {
  max-width: 1000px;
  margin: 0 auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.asin-selector {
  display: flex;
  align-items: center;
  gap: 20px;
}

.score-display {
  font-size: 14px;
  color: #606266;
}

.section-card {
  margin-top: 20px;
}

.analyzing-state {
  text-align: center;
  padding: 40px;
}

.analyzing-icon {
  color: #FF9900;
  margin-bottom: 16px;
}

.diagnosis-result {
  padding: 16px;
  background: #f5f7fa;
  border-radius: 8px;
}

.diagnosis-item {
  display: flex;
  margin-bottom: 12px;
}

.diagnosis-item:last-child {
  margin-bottom: 0;
}

.diagnosis-label {
  width: 80px;
  flex-shrink: 0;
  font-weight: 500;
  color: #606266;
}

.diagnosis-value {
  color: #303133;
}

.metrics-tags {
  display: flex;
  gap: 8px;
}

.optimization-section {
  margin-bottom: 24px;
}

.optimization-section h4 {
  margin: 0 0 16px 0;
  color: #303133;
}

.keyword-suggestions {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.keyword-group {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.group-label {
  color: #606266;
  font-size: 14px;
}

.form-item {
  margin-bottom: 16px;
}

.form-item label {
  display: block;
  margin-bottom: 8px;
  color: #606266;
  font-size: 14px;
}

.bullet-points {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.bullet-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.bullet-item .el-input {
  flex: 1;
}

.rationale {
  padding: 12px;
  background: #f5f7fa;
  border-radius: 4px;
  margin-top: 16px;
  font-size: 14px;
  color: #606266;
}

.review-strategy {
  margin-top: 20px;
  padding: 16px;
  background: #f0f9ff;
  border-radius: 8px;
}

.review-warning {
  margin-top: 12px;
  padding: 16px;
  background: #fff5f0;
  border-radius: 8px;
}

.review-strategy h4,
.review-warning h4 {
  margin: 0 0 8px 0;
}

.review-strategy p,
.review-warning p {
  margin: 0;
  color: #606266;
}

.item-desc {
  margin-top: 4px;
  color: #909399;
  font-size: 13px;
}

.action-buttons {
  display: flex;
  gap: 12px;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #e4e7ed;
}
</style>
