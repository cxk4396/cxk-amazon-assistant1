import { invoke } from '@tauri-apps/api/core'
import { open } from '@tauri-apps/plugin-dialog'

export interface FileInfo {
  name: string
  path: string
  size: number
}

export interface ParseResult {
  success: boolean
  data?: any[]
  errors?: string[]
  row_count: number
}

export interface ApiConfig {
  baseUrl: string
  apiKey: string
  model: string
}

// 选择文件
export async function selectFile(filters?: { name: string; extensions: string[] }[]): Promise<FileInfo | null> {
  const selected = await open({
    multiple: false,
    filters: filters || [
      { name: 'Excel', extensions: ['xlsx', 'xls'] },
      { name: 'CSV', extensions: ['csv'] }
    ]
  })
  
  if (!selected) return null
  
  // 获取文件信息
  const path = selected as string
  const name = path.split('/').pop() || path.split('\\').pop() || ''
  
  // 使用Tauri fs获取文件大小
  const { stat } = await import('@tauri-apps/plugin-fs')
  const fileStat = await stat(path)
  
  return {
    name,
    path,
    size: fileStat.size
  }
}

// 解析Excel文件
export async function parseExcelFile(filePath: string, sheetName?: string): Promise<ParseResult> {
  return invoke('parse_excel_file', { filePath, sheetName })
}

// 解析CSV文件
export async function parseCsvFile(filePath: string): Promise<ParseResult> {
  return invoke('parse_csv_file', { filePath })
}

// 保存API配置
export async function saveApiConfig(config: ApiConfig): Promise<void> {
  return invoke('save_api_config', { config })
}

// 获取API配置
export async function getApiConfig(): Promise<ApiConfig | null> {
  return invoke('get_api_config')
}

// AI分析
export async function analyzeWithAi(request: {
  asin: string
  data: any
  analysisType: string
}): Promise<any> {
  return invoke('analyze_with_ai', { 
    request: {
      asin: request.asin,
      data: request.data,
      analysis_type: request.analysisType
    }
  })
}
