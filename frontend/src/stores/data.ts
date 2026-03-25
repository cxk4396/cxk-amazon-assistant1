import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface FileData {
  file: { name: string; path: string; size: number } | null
  data: any[] | null
  headers: string[]
  selectedColumns: string[]
  sheetName?: string
}

export interface AnalysisParams {
  targetMargin: number | null
  targetAcos: number | null
  competitorMinPrice: number | null
  competitorMaxPrice: number | null
  contentStyle: 'professional' | 'friendly' | 'promotional'
}

export interface AsinData {
  asin: string
  title?: string
  sales?: any
  traffic?: any
  advertising?: any
  listing?: any
  competitor?: any
  healthScore?: number
  exposureStatus?: 'normal' | 'warning' | 'critical'
  clickStatus?: 'normal' | 'warning' | 'critical'
  conversionStatus?: 'normal' | 'warning' | 'critical'
}

export const useDataStore = defineStore('data', () => {
  // 文件数据
  const fileData = ref<Record<string, FileData>>({
    am67: { file: null, data: null, headers: [], selectedColumns: [] },
    business: { file: null, data: null, headers: [], selectedColumns: [] },
    inventory: { file: null, data: null, headers: [], selectedColumns: [], sheetName: 'Template' },
    competitor: { file: null, data: null, headers: [], selectedColumns: [] },
    advertising: { file: null, data: null, headers: [], selectedColumns: [] }
  })

  // 分析参数
  const params = ref<AnalysisParams>({
    targetMargin: null,
    targetAcos: null,
    competitorMinPrice: null,
    competitorMaxPrice: null,
    contentStyle: 'professional'
  })

  // ASIN合并数据
  const asinData = ref<AsinData[]>([])

  // 是否有数据
  const hasData = computed(() => {
    return Object.values(fileData.value).some(f => f.file !== null)
  })

  // 获取已上传文件数
  const uploadedFileCount = computed(() => {
    return Object.values(fileData.value).filter(f => f.file !== null).length
  })

  // 设置文件数据
  const setFileData = (type: string, data: FileData) => {
    fileData.value[type] = data
  }

  // 清除文件数据
  const clearFileData = (type: string) => {
    fileData.value[type] = { 
      file: null, 
      data: null, 
      headers: [], 
      selectedColumns: [],
      sheetName: type === 'inventory' ? 'Template' : undefined
    }
  }

  // 设置分析参数
  const setParams = (p: AnalysisParams) => {
    params.value = p
  }

  // 设置ASIN数据
  const setAsinData = (data: AsinData[]) => {
    asinData.value = data
  }

  // 合并数据（按ASIN关联）
  const mergeDataByAsin = () => {
    const asinMap = new Map<string, AsinData>()

    // 从库存报告获取基础ASIN列表（包含文案信息）
    const inventoryData = fileData.value.inventory.data || []
    for (const row of inventoryData) {
      const asin = row.ASIN || row.asin
      if (asin) {
        asinMap.set(asin, {
          asin,
          title: row.Title || row.title,
          listing: row
        })
      }
    }

    // 合并AM67销售数据
    const am67Data = fileData.value.am67.data || []
    for (const row of am67Data) {
      const asin = row.ASIN || row.asin
      if (asin && asinMap.has(asin)) {
        const data = asinMap.get(asin)!
        data.sales = row
      }
    }

    // 合并Business Report流量数据
    const businessData = fileData.value.business.data || []
    for (const row of businessData) {
      const asin = row.ASIN || row.asin || row['(Child) ASIN']
      if (asin && asinMap.has(asin)) {
        const data = asinMap.get(asin)!
        data.traffic = row
      }
    }

    // 合并广告数据
    const adData = fileData.value.advertising.data || []
    for (const row of adData) {
      const asin = row.ASIN || row.asin || row['Advertised ASIN']
      if (asin && asinMap.has(asin)) {
        const data = asinMap.get(asin)!
        data.advertising = row
      }
    }

    // 合并竞品数据
    const competitorData = fileData.value.competitor.data || []
    for (const row of competitorData) {
      const asin = row.ASIN || row.asin
      if (asin && asinMap.has(asin)) {
        const data = asinMap.get(asin)!
        data.competitor = row
      }
    }

    // 计算健康度评分
    asinData.value = Array.from(asinMap.values()).map(data => {
      return calculateHealthScore(data)
    })

    return asinData.value
  }

  // 计算健康度评分
  const calculateHealthScore = (data: AsinData): AsinData => {
    // 简化版评分逻辑
    let score = 70
    
    // 根据流量数据计算
    if (data.traffic) {
      const impressions = parseInt(data.traffic['Sessions'] || data.traffic['Sessions - Total'] || 0)
      const clicks = parseInt(data.traffic['Page Views'] || data.traffic['Page Views - Total'] || 0)
      
      if (impressions < 1000) {
        data.exposureStatus = 'critical'
        score -= 15
      } else if (impressions < 5000) {
        data.exposureStatus = 'warning'
        score -= 5
      } else {
        data.exposureStatus = 'normal'
      }
      
      const ctr = clicks / impressions
      if (ctr < 0.01) {
        data.clickStatus = 'critical'
        score -= 15
      } else if (ctr < 0.02) {
        data.clickStatus = 'warning'
        score -= 5
      } else {
        data.clickStatus = 'normal'
      }
    }
    
    // 根据转化率计算
    if (data.traffic && data.sales) {
      const orders = parseInt(data.sales['Ordered Units'] || data.sales['销量'] || 0)
      const sessions = parseInt(data.traffic['Sessions'] || 0)
      const conversionRate = sessions > 0 ? orders / sessions : 0
      
      if (conversionRate < 0.05) {
        data.conversionStatus = 'critical'
        score -= 15
      } else if (conversionRate < 0.10) {
        data.conversionStatus = 'warning'
        score -= 5
      } else {
        data.conversionStatus = 'normal'
      }
    }
    
    data.healthScore = Math.max(0, Math.min(100, score))
    return data
  }

  return {
    fileData,
    params,
    asinData,
    hasData,
    uploadedFileCount,
    setFileData,
    clearFileData,
    setParams,
    setAsinData,
    mergeDataByAsin
  }
})
