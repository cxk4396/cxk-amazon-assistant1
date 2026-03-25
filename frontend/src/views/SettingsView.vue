<template>
  <div class="settings-view">
    <!-- AI API 配置 -->
    <el-card>
      <template #header>
        <div class="card-header">
          <span>🔑 AI API 配置</span>
        </div>
      </template>

      <el-form :model="settingsStore.apiConfig" label-width="140px" class="settings-form"
      >
        <el-form-item label="API Base URL">
          <el-input v-model="settingsStore.apiConfig.baseUrl" placeholder="https://api.timebackward.com/v1" />
        </el-form-item>

        <el-form-item label="API Key">
          <el-input 
            v-model="settingsStore.apiConfig.apiKey" 
            type="password" 
            show-password
            placeholder="输入您的API密钥"
          />
        </el-form-item>

        <el-form-item label="默认模型">
          <el-select v-model="settingsStore.apiConfig.model" placeholder="选择模型" style="width: 100%">
            <el-option label="Claude Sonnet 4.6 (推荐)" value="claude-sonnet-4-6-thinking" />
            <el-option label="GPT-4o" value="gpt-4o" />
            <el-option label="GPT-4o Mini" value="gpt-4o-mini" />
            <el-option label="DeepSeek Chat" value="deepseek-chat" />
          </el-select>
        </el-form-item>

        <el-form-item label="Temperature">
          <el-slider v-model="settingsStore.apiConfig.temperature" :min="0" :max="1" :step="0.1" show-input />
          <div class="form-tip">较低的值使输出更确定，较高的值使输出更创意</div>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="testConnection" :loading="testing">
            <el-icon><Connection /></el-icon>
            测试连接
          </el-button>
          <el-tag v-if="connectionStatus" :type="connectionStatus.type" style="margin-left: 12px">
            {{ connectionStatus.message }}
          </el-tag>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 分析参数配置 -->
    <el-card class="section-card">
      <template #header>
        <div class="card-header">
          <span>📊 分析参数配置</span>
        </div>
      </template>

      <el-form :model="settingsStore.analysisParams" label-width="200px" class="settings-form"
      >
        <el-form-item label="曝光健康阈值">
          <el-input-number v-model="settingsStore.analysisParams.exposureWarning" :min="0" :max="100" :precision="0" />
          <span class="unit">% 低于类目均值标记为异常</span>
        </el-form-item>

        <el-form-item label="点击健康阈值 (CTR)">
          <el-input-number v-model="settingsStore.analysisParams.ctrWarning" :min="0" :max="100" :precision="2" />
          <span class="unit">% 低于此值标记为异常</span>
        </el-form-item>

        <el-form-item label="转化健康阈值">
          <el-input-number v-model="settingsStore.analysisParams.conversionWarning" :min="0" :max="100" :precision="2" />
          <span class="unit">% 低于此值标记为异常</span>
        </el-form-item>

        <el-form-item label="ACoS预警线">
          <el-input-number v-model="settingsStore.analysisParams.acosWarning" :min="0" :max="100" :precision="2" />
          <span class="unit">% 高于此值标记为异常</span>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 操作按钮 -->
    <div class="action-buttons">
      <el-button type="primary" size="large" @click="saveSettings">保存设置</el-button>
      <el-button size="large" @click="resetSettings">恢复默认</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useSettingsStore } from '../stores/settings'
import { testAIConnection } from '../services/ai-service'

const settingsStore = useSettingsStore()
const testing = ref(false)
const connectionStatus = ref<{ type: 'success' | 'error'; message: string } | null>(null)

onMounted(() => {
  settingsStore.loadSettings()
})

const testConnection = async () => {
  if (!settingsStore.apiConfig.apiKey) {
    ElMessage.warning('请先输入API Key')
    return
  }

  testing.value = true
  connectionStatus.value = null

  try {
    const success = await testAIConnection(settingsStore.apiConfig)
    if (success) {
      connectionStatus.value = { type: 'success', message: '✅ 连接成功' }
      ElMessage.success('API连接测试成功')
    } else {
      connectionStatus.value = { type: 'error', message: '❌ 连接失败' }
      ElMessage.error('API连接测试失败')
    }
  } catch (error) {
    connectionStatus.value = { type: 'error', message: '❌ 连接错误' }
    ElMessage.error('API连接测试失败: ' + (error as Error).message)
  } finally {
    testing.value = false
  }
}

const saveSettings = () => {
  settingsStore.saveApiConfig(settingsStore.apiConfig)
  settingsStore.saveAnalysisParams(settingsStore.analysisParams)
  ElMessage.success('设置已保存')
}

const resetSettings = () => {
  settingsStore.resetToDefault()
  ElMessage.success('已恢复默认设置')
}
</script>

<style scoped>
.settings-view {
  max-width: 800px;
  margin: 0 auto;
}

.card-header {
  font-weight: bold;
  font-size: 16px;
}

.section-card {
  margin-top: 20px;
}

.settings-form {
  max-width: 600px;
}

.unit {
  margin-left: 12px;
  color: #909399;
  font-size: 13px;
}

.form-tip {
  margin-top: 4px;
  color: #909399;
  font-size: 12px;
}

.action-buttons {
  margin-top: 30px;
  text-align: center;
}
</style>
