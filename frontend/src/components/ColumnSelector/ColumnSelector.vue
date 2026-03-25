<template>
  <el-dialog
    v-model="visible"
    title="数据列选择"
    width="800px"
    :close-on-click-modal="false"
  >
    <!-- 模式切换 -->
    <el-tabs v-model="activeMode" type="border-card">
      <!-- 智能搜索模式 -->
      <el-tab-pane label="🔍 智能搜索" name="search">
        <div class="search-mode">
          <el-input
            v-model="searchKeyword"
            placeholder="输入关键词搜索列名，如：ASIN、标题、销量..."
            clearable
            @input="handleSearch"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>

          <div class="search-results" v-if="searchResults.length > 0">
            <p class="result-title">搜索结果：</p>
            <el-checkbox-group v-model="selectedColumns">
              <el-checkbox 
                v-for="col in searchResults" 
                :key="col"
                :label="col"
                class="column-checkbox"
              >
                {{ col }}
              </el-checkbox>
            </el-checkbox-group>
          </div>

          <el-empty v-else-if="searchKeyword" description="未找到匹配的列" />
        </div>
      </el-tab-pane>

      <!-- 自主选择模式 -->
      <el-tab-pane label="☑️ 自主选择" name="manual">
        <div class="manual-mode">
          <div class="column-actions">
            <el-button type="primary" link @click="selectAll">全选</el-button>
            <el-button type="primary" link @click="inverseSelection">反选</el-button>
            <el-button type="primary" link @click="selectRecommended">智能推荐</el-button>
          </div>

          <el-divider />

          <el-checkbox-group v-model="selectedColumns" class="column-list">
            <el-checkbox 
              v-for="col in availableColumns" 
              :key="col"
              :label="col"
              class="column-checkbox"
            >
              <span class="column-name">{{ col }}</span>
              <el-tag v-if="isRecommended(col)" type="success" size="small">推荐</el-tag>
              <el-tag v-if="isAsinColumn(col)" type="warning" size="small">关键</el-tag>
            </el-checkbox>
          </el-checkbox-group>
        </div>
      </el-tab-pane>

      <!-- 模板模式 -->
      <el-tab-pane label="📑 模板模式" name="template">
        <div class="template-mode">
          <p class="template-desc">选择已保存的模板，快速应用列配置：</p>

          <el-empty v-if="templates.length === 0" description="暂无模板，请先保存模板" />

          <el-radio-group v-else v-model="selectedTemplate" class="template-list">
            <el-card 
              v-for="template in templates" 
              :key="template.id"
              class="template-item"
              :class="{ active: selectedTemplate === template.id }"
              shadow="hover"
            >
              <el-radio :label="template.id">
                <div class="template-info">
                  <div class="template-name">{{ template.name }}</div>
                  <div class="template-meta">{{ template.columnCount }} 列 · {{ template.createdAt }}</div>
                  <div class="template-desc-text" v-if="template.description">
                    {{ template.description }}
                  </div>
                </div>
              </el-radio>
            </el-card>
          </el-radio-group>

          <el-divider />

          <el-button type="primary" link @click="showSaveTemplateDialog = true">
            <el-icon><Plus /></el-icon>
            保存当前选择为新模板
          </el-button>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 当前选择预览 -->
    <div class="selected-preview">
      <p class="preview-title">
        已选择 {{ selectedColumns.length }} / {{ availableColumns.length }} 列
        <el-button type="primary" link @click="clearSelection">清空</el-button>
      </p>
      <el-scrollbar height="100px">
        <el-tag 
          v-for="col in selectedColumns" 
          :key="col"
          class="selected-tag"
          closable
          @close="removeColumn(col)"
        >
          {{ col }}
        </el-tag>
      </el-scrollbar>
    </div>

    <!-- 底部按钮 -->
    <template #footer>
      <div class="dialog-footer">
        <span class="token-estimate">预计Token消耗: ~{{ estimatedTokens }}</span>
        <div class="footer-actions">
          <el-button @click="visible = false">取消</el-button>
          <el-button type="primary" @click="confirmSelection" :disabled="selectedColumns.length === 0">
            确认选择
          </el-button>
        </div>
      </div>
    </template>
  </el-dialog>

  <!-- 保存模板对话框 -->
  <el-dialog v-model="showSaveTemplateDialog" title="保存为模板" width="500px">
    <el-form :model="newTemplate" label-width="100px">
      <el-form-item label="模板名称" required>
        <el-input v-model="newTemplate.name" placeholder="输入模板名称" />
      </el-form-item>

      <el-form-item label="模板描述">
        <el-input 
          v-model="newTemplate.description" 
          type="textarea"
          :rows="3"
          placeholder="描述该模板的用途..."
        />
      </el-form-item>

      <el-form-item label="适用文件">
        <el-select v-model="newTemplate.filePattern" placeholder="选择适用的文件类型">
          <el-option label="所有库存报告" value="*库存报告*" />
          <el-option label="AM67销售数据" value="AM67*" />
          <el-option label="Business Report" value="*Business*" />
          <el-option label="广告报告" value="*广告*" />
          <el-option label="竞品数据" value="*卖家精灵*" />
          <el-option label="通用模板" value="*" />
        </el-select>
      </el-form-item>
    </el-form>

    <template #footer>
      <el-button @click="showSaveTemplateDialog = false">取消</el-button>
      <el-button type="primary" @click="saveTemplate">保存</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { ElMessage } from 'element-plus'

interface Template {
  id: string
  name: string
  description?: string
  filePattern: string
  columns: string[]
  columnCount: number
  createdAt: string
}

interface Props {
  modelValue: boolean
  columns: string[]
  initialSelected?: string[]
  fileName?: string
}

const props = defineProps<Props>()
const emit = defineEmits<['update:modelValue', 'confirm']>()

const visible = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val)
})

const activeMode = ref('search')
const selectedColumns = ref<string[]>([])
const searchKeyword = ref('')
const searchResults = ref<string[]>([])

// 推荐列名（核心字段）
const recommendedColumns = [
  'ASIN', 'asin', 'Title', 'title', 'SKU', 'sku',
  '销量', '销售额', 'Orders', 'Sales',
  'Sessions', 'Page Views', 'Clicks',
  'Spend', 'ACOS', '广告花费',
  'Bullet Point 1', 'Bullet Point 2', 'Bullet Point 3', 'Bullet Point 4', 'Bullet Point 5',
  'Search Terms', 'Generic Keyword'
]

// ASIN关联关键列
const asinColumns = ['ASIN', 'asin', 'Asin', '(Child) ASIN', 'Advertised ASIN']

const availableColumns = computed(() => props.columns)

const isRecommended = (col: string) => {
  return recommendedColumns.some(r => col.toLowerCase().includes(r.toLowerCase()))
}

const isAsinColumn = (col: string) => {
  return asinColumns.some(a => col.toLowerCase() === a.toLowerCase())
}

// 搜索功能
const handleSearch = () => {
  if (!searchKeyword.value) {
    searchResults.value = []
    return
  }
  
  const keyword = searchKeyword.value.toLowerCase()
  searchResults.value = availableColumns.value.filter(col => 
    col.toLowerCase().includes(keyword)
  )
}

// 全选
const selectAll = () => {
  selectedColumns.value = [...availableColumns.value]
}

// 反选
const inverseSelection = () => {
  selectedColumns.value = availableColumns.value.filter(
    col => !selectedColumns.value.includes(col)
  )
}

// 智能推荐选择
const selectRecommended = () => {
  selectedColumns.value = availableColumns.value.filter(col => 
    isRecommended(col) || isAsinColumn(col)
  )
  ElMessage.success(`已选择 ${selectedColumns.value.length} 个推荐列`)
}

// 移除单个列
const removeColumn = (col: string) => {
  const index = selectedColumns.value.indexOf(col)
  if (index > -1) {
    selectedColumns.value.splice(index, 1)
  }
}

// 清空选择
const clearSelection = () => {
  selectedColumns.value = []
}

// 估计Token消耗（简化计算）
const estimatedTokens = computed(() => {
  // 大约每列50-100 tokens
  return selectedColumns.value.length * 75
})

// 模板相关
const templates = ref<Template[]>([
  {
    id: '1',
    name: '标准Listing分析模板',
    description: '适用于Listing优化分析',
    filePattern: '*库存报告*',
    columns: ['ASIN', 'Title', 'Bullet Point 1', 'Bullet Point 2', 'Bullet Point 3', 'Bullet Point 4', 'Bullet Point 5', 'Search Terms'],
    columnCount: 8,
    createdAt: '2026-03-24'
  },
  {
    id: '2',
    name: '广告优化专用模板',
    description: '用于广告数据分析和优化',
    filePattern: '*广告*',
    columns: ['ASIN', 'Spend', 'Sales', 'ACOS', 'Impressions', 'Clicks'],
    columnCount: 6,
    createdAt: '2026-03-24'
  }
])

const selectedTemplate = ref('')
const showSaveTemplateDialog = ref(false)
const newTemplate = ref({
  name: '',
  description: '',
  filePattern: '*'
})

// 应用模板
watch(selectedTemplate, (templateId) => {
  if (!templateId) return
  const template = templates.value.find(t => t.id === templateId)
  if (template) {
    selectedColumns.value = template.columns.filter(col => 
      availableColumns.value.includes(col)
    )
    ElMessage.success(`已应用模板：${template.name}`)
  }
})

// 保存模板
const saveTemplate = () => {
  if (!newTemplate.value.name) {
    ElMessage.warning('请输入模板名称')
    return
  }
  
  templates.value.push({
    id: Date.now().toString(),
    name: newTemplate.value.name,
    description: newTemplate.value.description,
    filePattern: newTemplate.value.filePattern,
    columns: [...selectedColumns.value],
    columnCount: selectedColumns.value.length,
    createdAt: new Date().toLocaleDateString()
  })
  
  showSaveTemplateDialog.value = false
  newTemplate.value = { name: '', description: '', filePattern: '*' }
  ElMessage.success('模板保存成功')
}

// 确认选择
const confirmSelection = () => {
  emit('confirm', {
    columns: selectedColumns.value,
    mode: activeMode.value
  })
  visible.value = false
}

// 初始化
watch(() => props.modelValue, (val) => {
  if (val && props.initialSelected) {
    selectedColumns.value = [...props.initialSelected]
  }
})
</script>

<style scoped>
.search-mode,
.manual-mode,
.template-mode {
  padding: 20px;
}

.result-title {
  margin: 16px 0 8px;
  color: #606266;
  font-size: 14px;
}

.column-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.column-checkbox {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.column-checkbox:hover {
  background-color: #f5f7fa;
}

.column-name {
  flex: 1;
}

.column-actions {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
}

.search-results {
  margin-top: 16px;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 8px;
}

.template-desc {
  margin-bottom: 16px;
  color: #606266;
}

.template-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.template-item {
  cursor: pointer;
}

.template-item.active {
  border-color: #FF9900;
  background-color: #fff9f0;
}

.template-item :deep(.el-radio__label) {
  width: 100%;
}

.template-info {
  padding: 8px 0;
}

.template-name {
  font-weight: 500;
  font-size: 16px;
  color: #303133;
  margin-bottom: 4px;
}

.template-meta {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
}

.template-desc-text {
  font-size: 13px;
  color: #606266;
}

.selected-preview {
  margin-top: 20px;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 8px;
}

.preview-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 0 0 12px 0;
  font-size: 14px;
  color: #606266;
}

.selected-tag {
  margin: 4px;
}

.dialog-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.token-estimate {
  color: #909399;
  font-size: 13px;
}

.footer-actions {
  display: flex;
  gap: 12px;
}
</style>
