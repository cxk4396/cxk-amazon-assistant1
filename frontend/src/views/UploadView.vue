<template>
  <div class="upload-view">
    <!-- 文件上传区 -->
    <el-card class="upload-section">
      <template #header>
        <div class="card-header">
          <span>📤 批量数据上传</span>
          <el-tag type="info">支持 Excel/CSV 格式</el-tag>
        </div>
      </template>

      <div class="file-cards">
        <!-- AM67销售数据 -->
        <div class="file-card" :class="{ uploaded: files.am67.file }">
          <div class="file-icon"><el-icon size="32"><DataLine /></el-icon></div>
          <div class="file-name">AM67 销售数据</div>
          <div class="file-status">
            <el-tag v-if="files.am67.file" type="success">已上传 {{ files.am67.data?.length || 0 }} 条</el-tag>
            <el-tag v-else type="info">未上传</el-tag>
          </div>
          <div class="file-size" v-if="files.am67.file">{{ formatFileSize(files.am67.file.size) }}</div>
          <div class="file-actions">
            <el-button type="primary" size="small" @click="selectFileHandler('am67')">
              {{ files.am67.file ? '重新选择' : '选择文件' }}
            </el-button>
            <el-button v-if="files.am67.file" type="danger" link size="small" @click="clearFile('am67')">
              清除
            </el-button>
            <el-button v-if="files.am67.file" type="primary" link size="small" @click="openColumnSelector('am67')">
              选择列
            </el-button>
          </div>
        </div>

        <!-- Business Report -->
        <div class="file-card" :class="{ uploaded: files.business.file }">
          <div class="file-icon"><el-icon size="32"><TrendCharts /></el-icon></div>
          <div class="file-name">Business Report</div>
          <div class="file-status">
            <el-tag v-if="files.business.file" type="success">已上传 {{ files.business.data?.length || 0 }} 条</el-tag>
            <el-tag v-else type="info">未上传</el-tag>
          </div>
          <div class="file-size" v-if="files.business.file">{{ formatFileSize(files.business.file.size) }}</div>
          <div class="file-actions">
            <el-button type="primary" size="small" @click="selectFileHandler('business')">
              {{ files.business.file ? '重新选择' : '选择文件' }}
            </el-button>
            <el-button v-if="files.business.file" type="danger" link size="small" @click="clearFile('business')">
              清除
            </el-button>
            <el-button v-if="files.business.file" type="primary" link size="small" @click="openColumnSelector('business')">
              选择列
            </el-button>
          </div>
        </div>

        <!-- 库存报告 -->
        <div class="file-card" :class="{ uploaded: files.inventory.file }">
          <div class="file-icon"><el-icon size="32"><Box /></el-icon></div>
          <div class="file-name">库存报告 (Template)</div>
          <div class="file-status">
            <el-tag v-if="files.inventory.file" type="success">已上传 {{ files.inventory.data?.length || 0 }} 条</el-tag>
            <el-tag v-else type="info">未上传</el-tag>
          </div>
          <div class="file-size" v-if="files.inventory.file">{{ formatFileSize(files.inventory.file.size) }}</div>
          <div class="file-actions">
            <el-button type="primary" size="small" @click="selectFileHandler('inventory')">
              {{ files.inventory.file ? '重新选择' : '选择文件' }}
            </el-button>
            <el-button v-if="files.inventory.file" type="danger" link size="small" @click="clearFile('inventory')">
              清除
            </el-button>
            <el-button v-if="files.inventory.file" type="primary" link size="small" @click="openColumnSelector('inventory')">
              选择列
            </el-button>
          </div>
        </div>

        <!-- 竞品数据 -->
        <div class="file-card" :class="{ uploaded: files.competitor.file }">
          <div class="file-icon"><el-icon size="32"><Aim /></el-icon></div>
          <div class="file-name">竞品数据 (卖家精灵)</div>
          <div class="file-status">
            <el-tag v-if="files.competitor.file" type="success">已上传 {{ files.competitor.data?.length || 0 }} 条</el-tag>
            <el-tag v-else type="info">未上传</el-tag>
          </div>
          <div class="file-size" v-if="files.competitor.file">{{ formatFileSize(files.competitor.file.size) }}</div>
          <div class="file-actions">
            <el-button type="primary" size="small" @click="selectFileHandler('competitor')">
              {{ files.competitor.file ? '重新选择' : '选择文件' }}
            </el-button>
            <el-button v-if="files.competitor.file" type="danger" link size="small" @click="clearFile('competitor')">
              清除
            </el-button>
            <el-button v-if="files.competitor.file" type="primary" link size="small" @click="openColumnSelector('competitor')">
              选择列
            </el-button>
          </div>
        </div>

        <!-- 广告报告 -->
        <div class="file-card" :class="{ uploaded: files.advertising.file }">
          <div class="file-icon"><el-icon size="32"><Promotion /></el-icon></div>
          <div class="file-name">广告推广商品报告</div>
          <div class="file-status">
            <el-tag v-if="files.advertising.file" type="success">已上传 {{ files.advertising.data?.length || 0 }} 条</el-tag>
            <el-tag v-else type="info">未上传</el-tag>
          </div>
          <div class="file-size" v-if="files.advertising.file">{{ formatFileSize(files.advertising.file.size) }}</div>
          <div class="file-actions">
            <el-button type="primary" size="small" @click="selectFileHandler('advertising')">
              {{ files.advertising.file ? '重新选择' : '选择文件' }}
            </el-button>
            <el-button v-if="files.advertising.file" type="danger" link size="small" @click="clearFile('advertising')">
              清除
            </el-button>
            <el-button v-if="files.advertising.file" type="primary" link size="small" @click="openColumnSelector('advertising')">
              选择列
            </el-button>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 列选择器 -->
    <column-selector
      v-model="showColumnSelector"
      :columns="currentFileColumns"
      :initial-selected="currentFileSelectedColumns"
      :file-name="currentFileName"
      @confirm="handleColumnSelection"
    />

        <!-- 库存报告 -->
        <div class="file-card" :class="{ uploaded: files.inventory.file }">
          <div class="file-icon"><el-icon size="32"><Box /></el-icon></div>
          <div class="file-name">库存报告 (Template)</div>
          <div class="file-status">
            <el-tag v-if="files.inventory.file" type="success">已上传 {{ files.inventory.data?.length || 0 }} 条</el-tag>
            <el-tag v-else type="info">未上传</el-tag>
          </div>
          <div class="file-size" v-if="files.inventory.file">{{ formatFileSize(files.inventory.file.size) }}</div>
          <div class="file-actions">
            <el-button type="primary" size="small" @click="selectFileHandler('inventory')">
              {{ files.inventory.file ? '重新选择' : '选择文件' }}
            </el-button>
            <el-button v-if="files.inventory.file" type="danger" link size="small" @click="clearFile('inventory')">
              清除
            </el-button>
          </div>
        </div>

        <!-- 竞品数据 -->
        <div class="file-card" :class="{ uploaded: files.competitor.file }">
          <div class="file-icon"><el-icon size="32"><Aim /></el-icon></div>
          <div class="file-name">竞品数据 (卖家精灵)</div>
          <div class="file-status">
            <el-tag v-if="files.competitor.file" type="success">已上传 {{ files.competitor.data?.length || 0 }} 条</el-tag>
            <el-tag v-else type="info">未上传</el-tag>
          </div>
          <div class="file-size" v-if="files.competitor.file">{{ formatFileSize(files.competitor.file.size) }}</div>
          <div class="file-actions">
            <el-button type="primary" size="small" @click="selectFileHandler('competitor')">
              {{ files.competitor.file ? '重新选择' : '选择文件' }}
            </el-button>
            <el-button v-if="files.competitor.file" type="danger" link size="small" @click="clearFile('competitor')">
              清除
            </el-button>
          </div>
        </div>

        <!-- 广告报告 -->
        <div class="file-card" :class="{ uploaded: files.advertising.file }">
          <div class="file-icon"><el-icon size="32"><Promotion /></el-icon></div>
          <div class="file-name">广告推广商品报告</div>
          <div class="file-status">
            <el-tag v-if="files.advertising.file" type="success">已上传 {{ files.advertising.data?.length || 0 }} 条</el-tag>
            <el-tag v-else type="info">未上传</el-tag>
          </div>
          <div class="file-size" v-if="files.advertising.file">{{ formatFileSize(files.advertising.file.size) }}</div>
          <div class="file-actions">
            <el-button type="primary" size="small" @click="selectFileHandler('advertising')">
              {{ files.advertising.file ? '重新选择' : '选择文件' }}
            </el-button>
            <el-button v-if="files.advertising.file" type="danger" link size="small" @click="clearFile('advertising')">
              清除
            </el-button>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 手动参数填写区 -->
    <el-card class="params-section">
      <template #header>
        <div class="card-header">
          <span><</> 手动参数配置</span>
          <el-tag type="warning">用于AI分析的补充参数</el-tag>
        </div>
      </template>

      <el-form :model="params" label-width="140px" class="params-form">
        <div class="form-row">
          <el-form-item label="目标利润率">
            <el-input-number v-model="params.targetMargin" :min="0" :max="100" :precision="2" 
              placeholder="例如: 30" />
            <span class="unit">%</span>
          </el-form-item>
          
          <el-form-item label="目标ACoS">
            <el-input-number v-model="params.targetAcos" :min="0" :max="100" :precision="2"
              placeholder="例如: 25" />
            <span class="unit">%</span>
          </el-form-item>
        </div>

        <div class="form-row">
          <el-form-item label="竞品价格区间">
            <el-input-number v-model="params.competitorMinPrice" :min="0" :precision="2"
              placeholder="最低价" />
            <span class="separator">-</span>
            <el-input-number v-model="params.competitorMaxPrice" :min="0" :precision="2"
              placeholder="最高价" />
            <span class="unit">USD</span>
          </el-form-item>
        </div>

        <el-form-item label="文案风格偏好">
          <el-radio-group v-model="params.contentStyle">
            <el-radio label="professional">专业严谨</el-radio>
            <el-radio label="friendly">亲和易懂</el-radio>
            <el-radio label="promotional">促销感</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 开始分析按钮 -->
    <div class="action-section">
      <el-button type="primary" size="large" :disabled="!canStartAnalysis" @click="startAnalysis"
        class="start-btn">
        <el-icon class="btn-icon"><Rocket /></el-icon>
        开始AI分析
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { ElMessage, ElLoading } from 'element-plus'
import { useRouter } from 'vue-router'
import { useDataStore } from '../stores/data'
import { selectFile, parseExcelFile, parseCsvFile } from '../utils/tauri'
import { 
  validateFile, 
  getValidationOptionsForFileType, 
  validateDataRows,
  detectFileType,
  getFileTypeDisplayName
} from '../utils/file-validator'
import { showError } from '../utils/error-handler'
import ColumnSelector from '../components/ColumnSelector/ColumnSelector.vue'

const router = useRouter()
const dataStore = useDataStore()

interface FileInfo {
  name: string
  path: string
  size: number
}

interface FileData {
  file: FileInfo | null
  data: any[] | null
  headers: string[]
  selectedColumns: string[]
  sheetName?: string
}

const files = ref<Record<string, FileData>>({
  am67: { file: null, data: null, headers: [], selectedColumns: [] },
  business: { file: null, data: null, headers: [], selectedColumns: [] },
  inventory: { file: null, data: null, headers: [], selectedColumns: [], sheetName: 'Template' },
  competitor: { file: null, data: null, headers: [], selectedColumns: [] },
  advertising: { file: null, data: null, headers: [], selectedColumns: [] }
})

const params = ref({
  targetMargin: null as number | null,
  targetAcos: null as number | null,
  competitorMinPrice: null as number | null,
  competitorMaxPrice: null as number | null,
  contentStyle: 'professional'
})

// 列选择器相关
const showColumnSelector = ref(false)
const currentFileType = ref('')
const currentFileColumns = ref<string[]>([])
const currentFileSelectedColumns = ref<string[]>([])
const currentFileName = ref('')

const canStartAnalysis = computed(() => {
  return Object.values(files.value).some(f => f.file !== null)
})

const formatFileSize = (bytes: number) => {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

const selectFileHandler = async (type: string) => {
  const loading = ElLoading.service({
    lock: true,
    text: '正在选择文件...',
    background: 'rgba(0, 0, 0, 0.7)'
  })

  try {
    const fileInfo = await selectFile()
    if (!fileInfo) {
      loading.close()
      return
    }

    // 文件验证
    const validationOptions = getValidationOptionsForFileType(type)
    const validationResult = validateFile(fileInfo, validationOptions)
    
    if (!validationResult.valid) {
      showError(validationResult.message || '文件验证失败')
      loading.close()
      return
    }

    // 智能检测文件类型
    const detectedType = detectFileType(fileInfo.name)
    if (detectedType !== type && detectedType !== 'unknown') {
      const expectedName = getFileTypeDisplayName(type)
      const detectedName = getFileTypeDisplayName(detectedType)
      ElMessage.warning(`检测到这可能是 ${detectedName}，但你选择上传为 ${expectedName}`)
    }

    files.value[type].file = fileInfo

    // 解析文件
    loading.setText('正在解析文件...')
    let result
    if (fileInfo.name.endsWith('.csv')) {
      result = await parseCsvFile(fileInfo.path)
    } else {
      result = await parseExcelFile(fileInfo.path, files.value[type].sheetName)
    }

    if (result.success && result.data) {
      // 验证数据行数
      const rowValidation = validateDataRows(result.data, 100000)
      if (!rowValidation.valid) {
        showError(rowValidation.message || '数据验证失败')
        files.value[type].file = null
        loading.close()
        return
      }

      files.value[type].data = result.data
      // 提取表头
      if (result.data.length > 0) {
        files.value[type].headers = Object.keys(result.data[0])
        // 默认全选
        files.value[type].selectedColumns = [...files.value[type].headers]
      }

      // 保存到store
      dataStore.setFileData(type, files.value[type])

      ElMessage.success(`成功解析 ${result.row_count} 条数据`)
    } else {
      showError(result.errors?.[0] || '文件解析失败')
      files.value[type].file = null
    }
  } catch (error) {
    showError('文件选择或解析失败', (error as Error).message)
    files.value[type].file = null
  } finally {
    loading.close()
  }
}

const clearFile = (type: string) => {
  files.value[type] = {
    file: null,
    data: null,
    headers: [],
    selectedColumns: [],
    sheetName: type === 'inventory' ? 'Template' : undefined
  }
  dataStore.clearFileData(type)
  ElMessage.success('已清除文件')
}

// 打开列选择器
const openColumnSelector = (type: string) => {
  currentFileType.value = type
  currentFileColumns.value = files.value[type].headers
  currentFileSelectedColumns.value = [...files.value[type].selectedColumns]
  currentFileName.value = files.value[type].file?.name || ''
  showColumnSelector.value = true
}

// 处理列选择结果
const handleColumnSelection = (result: { columns: string[]; mode: string }) => {
  const type = currentFileType.value
  files.value[type].selectedColumns = result.columns
  dataStore.setFileData(type, files.value[type])
  ElMessage.success(`已为 ${type} 选择 ${result.columns.length} 列`)
}

const startAnalysis = () => {
  // 保存参数
  dataStore.setParams(params.value)

  // 跳转到数据看板
  ElMessage.success('数据加载完成！')
  router.push('/dashboard')
}
</script>

<style scoped>
.upload-view {
  max-width: 1200px;
  margin: 0 auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.file-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 20px;
}

.file-card {
  border: 2px dashed #dcdfe6;
  border-radius: 8px;
  padding: 20px;
  text-align: center;
  transition: all 0.3s;
  background: #fafafa;
}

.file-card.uploaded {
  border-color: #67c23a;
  background: #f0f9ff;
}

.file-icon {
  color: #909399;
  margin-bottom: 12px;
}

.file-card.uploaded .file-icon {
  color: #67c23a;
}

.file-name {
  font-weight: 500;
  color: #303133;
  margin-bottom: 8px;
}

.file-status {
  margin-bottom: 8px;
}

.file-size {
  font-size: 12px;
  color: #909399;
  margin-bottom: 12px;
}

.file-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.params-section {
  margin-top: 20px;
}

.params-form {
  max-width: 800px;
}

.form-row {
  display: flex;
  gap: 40px;
}

.unit {
  margin-left: 8px;
  color: #909399;
}

.separator {
  margin: 0 12px;
  color: #909399;
}

.action-section {
  margin-top: 30px;
  text-align: center;
}

.start-btn {
  padding: 16px 40px;
  font-size: 16px;
}

.btn-icon {
  margin-right: 8px;
}
</style>
