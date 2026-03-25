import { ElMessage } from 'element-plus'

export interface FileValidationResult {
  valid: boolean
  message?: string
}

export interface FileValidationOptions {
  maxSize?: number // 最大文件大小（字节）
  allowedExtensions?: string[] // 允许的扩展名
  allowedMimeTypes?: string[] // 允许的MIME类型
  maxRows?: number // 最大行数
  requiredColumns?: string[] // 必需的列
}

// 文件类型映射
const MIME_TYPE_MAP: Record<string, string[]> = {
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': ['.xlsx'],
  'application/vnd.ms-excel': ['.xls'],
  'text/csv': ['.csv'],
  'application/csv': ['.csv']
}

/**
 * 验证文件扩展名
 */
export function validateFileExtension(
  fileName: string,
  allowedExtensions: string[]
): FileValidationResult {
  const ext = fileName.toLowerCase().substring(fileName.lastIndexOf('.'))
  
  if (!allowedExtensions.includes(ext)) {
    return {
      valid: false,
      message: `不支持的文件格式。请上传: ${allowedExtensions.join(', ')}`
    }
  }
  
  return { valid: true }
}

/**
 * 验证文件大小
 */
export function validateFileSize(
  fileSize: number,
  maxSize: number
): FileValidationResult {
  if (fileSize > maxSize) {
    const maxSizeMB = (maxSize / 1024 / 1024).toFixed(2)
    const fileSizeMB = (fileSize / 1024 / 1024).toFixed(2)
    return {
      valid: false,
      message: `文件过大 (${fileSizeMB} MB)。最大允许: ${maxSizeMB} MB`
    }
  }
  
  return { valid: true }
}

/**
 * 验证文件名模式
 */
export function validateFileNamePattern(
  fileName: string,
  expectedPattern?: string
): FileValidationResult {
  if (!expectedPattern) {
    return { valid: true }
  }
  
  // 简单的通配符匹配
  const pattern = expectedPattern.replace(/\*/g, '.*')
  const regex = new RegExp(pattern, 'i')
  
  if (!regex.test(fileName)) {
    return {
      valid: false,
      message: `文件名不符合预期格式。建议包含: ${expectedPattern}`
    }
  }
  
  return { valid: true }
}

/**
 * 验证文件（完整验证）
 */
export function validateFile(
  file: { name: string; size: number },
  options: FileValidationOptions = {}
): FileValidationResult {
  const {
    maxSize = 50 * 1024 * 1024, // 默认50MB
    allowedExtensions = ['.xlsx', '.xls', '.csv']
  } = options
  
  // 验证扩展名
  const extResult = validateFileExtension(file.name, allowedExtensions)
  if (!extResult.valid) return extResult
  
  // 验证大小
  const sizeResult = validateFileSize(file.size, maxSize)
  if (!sizeResult.valid) return sizeResult
  
  return { valid: true }
}

/**
 * 根据文件类型获取验证选项
 */
export function getValidationOptionsForFileType(type: string): FileValidationOptions {
  const options: Record<string, FileValidationOptions> = {
    am67: {
      maxSize: 20 * 1024 * 1024,
      allowedExtensions: ['.xlsx', '.xls', '.csv']
    },
    business: {
      maxSize: 50 * 1024 * 1024,
      allowedExtensions: ['.csv']
    },
    inventory: {
      maxSize: 30 * 1024 * 1024,
      allowedExtensions: ['.xlsx', '.xls']
    },
    competitor: {
      maxSize: 20 * 1024 * 1024,
      allowedExtensions: ['.xlsx', '.xls', '.csv']
    },
    advertising: {
      maxSize: 50 * 1024 * 1024,
      allowedExtensions: ['.xlsx', '.xls', '.csv']
    }
  }
  
  return options[type] || {
    maxSize: 50 * 1024 * 1024,
    allowedExtensions: ['.xlsx', '.xls', '.csv']
  }
}

/**
 * 验证数据行数
 */
export function validateDataRows(data: any[], maxRows: number): FileValidationResult {
  if (data.length > maxRows) {
    return {
      valid: false,
      message: `数据行数过多 (${data.length} 行)。最大允许: ${maxRows} 行`
    }
  }
  
  if (data.length === 0) {
    return {
      valid: false,
      message: '文件不包含任何数据'
    }
  }
  
  return { valid: true }
}

/**
 * 验证必需列
 */
export function validateRequiredColumns(
  headers: string[],
  requiredColumns: string[]
): FileValidationResult {
  const missingColumns = requiredColumns.filter(col => 
    !headers.some(h => h.toLowerCase() === col.toLowerCase())
  )
  
  if (missingColumns.length > 0) {
    return {
      valid: false,
      message: `缺少必需列: ${missingColumns.join(', ')}`
    }
  }
  
  return { valid: true }
}

/**
 * 智能检测文件类型
 */
export function detectFileType(fileName: string): string {
  const lowerName = fileName.toLowerCase()
  
  if (lowerName.includes('am67') || lowerName.includes('销售')) {
    return 'am67'
  }
  if (lowerName.includes('business') || lowerName.includes('report')) {
    return 'business'
  }
  if (lowerName.includes('库存') || lowerName.includes('template')) {
    return 'inventory'
  }
  if (lowerName.includes('竞品') || lowerName.includes('卖家精灵')) {
    return 'competitor'
  }
  if (lowerName.includes('广告') || lowerName.includes('advertising')) {
    return 'advertising'
  }
  
  return 'unknown'
}

/**
 * 获取文件类型显示名称
 */
export function getFileTypeDisplayName(type: string): string {
  const names: Record<string, string> = {
    am67: 'AM67销售数据',
    business: 'Business Report',
    inventory: '库存报告',
    competitor: '竞品数据',
    advertising: '广告报告',
    unknown: '未知类型'
  }
  
  return names[type] || '未知类型'
}

/**
 * 显示验证错误并返回false
 */
export function showValidationError(result: FileValidationResult): boolean {
  if (!result.valid) {
    ElMessage.error(result.message || '文件验证失败')
    return false
  }
  return true
}
