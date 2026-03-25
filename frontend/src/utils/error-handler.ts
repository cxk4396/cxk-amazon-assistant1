import { ref } from 'vue'
import { ElMessage, ElNotification } from 'element-plus'

export interface AppError {
  code: string
  message: string
  details?: string
  timestamp: number
}

// 错误日志存储
const errorLog = ref<AppError[]>([])

// 最大错误记录数
const MAX_ERROR_LOG = 50

/**
 * 处理应用错误
 */
export function handleError(error: unknown, context?: string): AppError {
  const timestamp = Date.now()
  
  let appError: AppError
  
  if (error instanceof Error) {
    appError = {
      code: 'UNKNOWN_ERROR',
      message: error.message,
      details: error.stack,
      timestamp
    }
  } else if (typeof error === 'string') {
    appError = {
      code: 'STRING_ERROR',
      message: error,
      timestamp
    }
  } else {
    appError = {
      code: 'UNKNOWN_ERROR',
      message: '发生未知错误',
      details: JSON.stringify(error),
      timestamp
    }
  }
  
  // 添加上下文
  if (context) {
    appError.message = `[${context}] ${appError.message}`
  }
  
  // 记录到日志
  errorLog.value.unshift(appError)
  if (errorLog.value.length > MAX_ERROR_LOG) {
    errorLog.value.pop()
  }
  
  // 控制台输出
  console.error('App Error:', appError)
  
  return appError
}

/**
 * 显示错误消息
 */
export function showError(message: string, details?: string) {
  ElNotification({
    title: '错误',
    message: details ? `${message}<br><span style="font-size: 12px; color: #999;">${details}</span>` : message,
    type: 'error',
    duration: 5000,
    dangerouslyUseHTMLString: !!details
  })
}

/**
 * 显示警告消息
 */
export function showWarning(message: string) {
  ElMessage.warning(message)
}

/**
 * 显示成功消息
 */
export function showSuccess(message: string) {
  ElMessage.success(message)
}

/**
 * 显示信息消息
 */
export function showInfo(message: string) {
  ElMessage.info(message)
}

/**
 * 获取错误日志
 */
export function getErrorLog(): AppError[] {
  return [...errorLog.value]
}

/**
 * 清空错误日志
 */
export function clearErrorLog() {
  errorLog.value = []
}

/**
 * 导出错误日志
 */
export function exportErrorLog(): string {
  return JSON.stringify(errorLog.value, null, 2)
}

/**
 * 全局错误处理初始化
 */
export function initGlobalErrorHandler() {
  // 捕获未处理的Promise错误
  window.addEventListener('unhandledrejection', (event) => {
    handleError(event.reason, '未处理的Promise')
    showError('操作失败', event.reason?.message || '未知错误')
  })
  
  // 捕获全局错误
  window.addEventListener('error', (event) => {
    handleError(event.error || event.message, '全局错误')
    showError('应用错误', event.message)
  })
}

/**
 * 包装异步函数，自动处理错误
 */
export function withErrorHandling<T extends (...args: any[]) => Promise<any>>(
  fn: T,
  errorMessage?: string
): (...args: Parameters<T>) => Promise<ReturnType<T> | null> {
  return async (...args: Parameters<T>) => {
    try {
      return await fn(...args)
    } catch (error) {
      const appError = handleError(error, errorMessage)
      showError(errorMessage || '操作失败', appError.message)
      return null
    }
  }
}
