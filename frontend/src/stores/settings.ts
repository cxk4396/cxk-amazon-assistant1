import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { AIConfig } from '../services/ai-service'

export const useSettingsStore = defineStore('settings', () => {
  // API配置
  const apiConfig = ref<AIConfig>({
    baseUrl: 'https://api.timebackward.com/v1',
    apiKey: '',
    model: 'claude-sonnet-4-6-thinking',
    temperature: 0.3
  })

  // 分析参数
  const analysisParams = ref({
    exposureWarning: 30,      // 低于类目均值30%标记为异常
    ctrWarning: 2.5,          // CTR低于2.5%标记为异常
    conversionWarning: 10,    // 转化率低于10%标记为异常
    acosWarning: 30           // ACoS高于30%标记为异常
  })

  // 加载设置（从localStorage）
  const loadSettings = () => {
    const savedApiConfig = localStorage.getItem('cxk_api_config')
    if (savedApiConfig) {
      apiConfig.value = JSON.parse(savedApiConfig)
    }

    const savedAnalysisParams = localStorage.getItem('cxk_analysis_params')
    if (savedAnalysisParams) {
      analysisParams.value = JSON.parse(savedAnalysisParams)
    }
  }

  // 保存API配置
  const saveApiConfig = (config: AIConfig) => {
    apiConfig.value = config
    localStorage.setItem('cxk_api_config', JSON.stringify(config))
  }

  // 保存分析参数
  const saveAnalysisParams = (params: typeof analysisParams.value) => {
    analysisParams.value = params
    localStorage.setItem('cxk_analysis_params', JSON.stringify(params))
  }

  // 重置为默认
  const resetToDefault = () => {
    apiConfig.value = {
      baseUrl: 'https://api.timebackward.com/v1',
      apiKey: '',
      model: 'claude-sonnet-4-6-thinking',
      temperature: 0.3
    }
    analysisParams.value = {
      exposureWarning: 30,
      ctrWarning: 2.5,
      conversionWarning: 10,
      acosWarning: 30
    }
    localStorage.removeItem('cxk_api_config')
    localStorage.removeItem('cxk_analysis_params')
  }

  return {
    apiConfig,
    analysisParams,
    loadSettings,
    saveApiConfig,
    saveAnalysisParams,
    resetToDefault
  }
})
