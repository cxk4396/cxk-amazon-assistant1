import { save, open } from '@tauri-apps/plugin-dialog'
import { writeTextFile, BaseDirectory } from '@tauri-apps/plugin-fs'

export interface ListingExportData {
  sellerSku: string
  asin: string
  title: string
  bulletPoints: string[]
  searchTerms: string
  description?: string
}

export interface AdvertisingExportData {
  campaignName: string
  adGroupName: string
  asin: string
  keyword: string
  matchType: string
  bid: number
  operation: string
}

/**
 * 生成Amazon Listing模板内容 (Flat File格式)
 */
export function generateListingTemplate(data: ListingExportData[]): string {
  // Amazon Flat File 头部
  const headers = [
    'TemplateType=Basic',
    'Version=2024.03',
    'Row 1 is the Header Row',
    'seller-sku\tproduct-id\tproduct-id-type\ttitle\tbrand-name\tdescription\tbullet-point-1\tbullet-point-2\tbullet-point-3\tbullet-point-4\tbullet-point-5\tgeneric_keywords-1\tupdate-delete'
  ]
  
  // 数据行
  const rows = data.map(item => {
    const bullets = item.bulletPoints || []
    return [
      item.sellerSku || '',
      item.asin || '',
      '1', // ASIN
      escapeTab(item.title || ''),
      'YOUR_BRAND', // 品牌名占位符
      escapeTab(item.description || ''),
      escapeTab(bullets[0] || ''),
      escapeTab(bullets[1] || ''),
      escapeTab(bullets[2] || ''),
      escapeTab(bullets[3] || ''),
      escapeTab(bullets[4] || ''),
      escapeTab(item.searchTerms || ''),
      'PartialUpdate'
    ].join('\t')
  })
  
  return [...headers, ...rows].join('\n')
}

/**
 * 生成Amazon广告批量操作模板
 */
export function generateAdvertisingTemplate(data: AdvertisingExportData[]): string {
  const headers = [
    'Campaign Name',
    'Ad Group Name',
    'ASIN',
    'Keyword',
    'Match Type',
    'Bid',
    'Operation'
  ]
  
  const rows = data.map(item => [
    item.campaignName,
    item.adGroupName,
    item.asin,
    item.keyword,
    item.matchType,
    item.bid.toFixed(2),
    item.operation
  ])
  
  // 转换为CSV格式
  const csvContent = [headers, ...rows]
    .map(row => row.map(escapeCsv).join(','))
    .join('\n')
  
  return csvContent
}

/**
 * 从AI结果生成Listing导出数据
 */
export function convertAIResultToListingData(
  asin: string,
  sku: string,
  aiResult: any
): ListingExportData {
  const listing = aiResult.optimization?.listing || {}
  
  return {
    sellerSku: sku || asin,
    asin: asin,
    title: listing.optimizedTitle || '',
    bulletPoints: listing.optimizedBullets || [],
    searchTerms: listing.optimizedSearchTerms || '',
    description: ''
  }
}

/**
 * 从AI结果生成广告导出数据
 */
export function convertAIResultToAdvertisingData(
  asin: string,
  aiResult: any
): AdvertisingExportData[] {
  const advertising = aiResult.optimization?.advertising || {}
  const keywords = advertising.keywordsToAdd || []
  
  return keywords.map((kw: any, index: number) => ({
    campaignName: `自动优化_${asin}_${index + 1}`,
    adGroupName: `AdGroup_${asin}`,
    asin: asin,
    keyword: kw.keyword || '',
    matchType: mapMatchType(kw.matchType),
    bid: kw.suggestedBid || 1.0,
    operation: 'create'
  }))
}

/**
 * 导出Listing模板到文件
 */
export async function exportListingTemplate(data: ListingExportData[]): Promise<boolean> {
  try {
    const content = generateListingTemplate(data)
    
    const filePath = await save({
      filters: [
        { name: 'Text Files', extensions: ['txt'] },
        { name: 'All Files', extensions: ['*'] }
      ],
      defaultPath: `amazon_listing_update_${new Date().toISOString().split('T')[0]}.txt`
    })
    
    if (!filePath) return false
    
    await writeTextFile(filePath, content)
    return true
  } catch (error) {
    console.error('Export listing template error:', error)
    return false
  }
}

/**
 * 导出广告模板到文件
 */
export async function exportAdvertisingTemplate(data: AdvertisingExportData[]): Promise<boolean> {
  try {
    const content = generateAdvertisingTemplate(data)
    
    const filePath = await save({
      filters: [
        { name: 'CSV Files', extensions: ['csv'] },
        { name: 'All Files', extensions: ['*'] }
      ],
      defaultPath: `amazon_advertising_bulk_${new Date().toISOString().split('T')[0]}.csv`
    })
    
    if (!filePath) return false
    
    await writeTextFile(filePath, content)
    return true
  } catch (error) {
    console.error('Export advertising template error:', error)
    return false
  }
}

/**
 * 批量导出所有ASIN的Listing
 */
export async function exportAllListings(
  analysisResults: Record<string, any>,
  skuMap?: Record<string, string>
): Promise<boolean> {
  const data: ListingExportData[] = []
  
  Object.entries(analysisResults).forEach(([asin, result]) => {
    const sku = skuMap?.[asin] || asin
    data.push(convertAIResultToListingData(asin, sku, result))
  })
  
  if (data.length === 0) {
    return false
  }
  
  return exportListingTemplate(data)
}

/**
 * 批量导出所有ASIN的广告
 */
export async function exportAllAdvertising(
  analysisResults: Record<string, any>
): Promise<boolean> {
  const allData: AdvertisingExportData[] = []
  
  Object.entries(analysisResults).forEach(([asin, result]) => {
    const data = convertAIResultToAdvertisingData(asin, result)
    allData.push(...data)
  })
  
  if (allData.length === 0) {
    return false
  }
  
  return exportAdvertisingTemplate(allData)
}

// 辅助函数
function escapeTab(text: string): string {
  return text.replace(/\t/g, ' ').replace(/\n/g, ' ')
}

function escapeCsv(text: string): string {
  if (text.includes(',') || text.includes('"') || text.includes('\n')) {
    return `"${text.replace(/"/g, '""')}"`
  }
  return text
}

function mapMatchType(type?: string): string {
  const map: Record<string, string> = {
    '广泛': 'broad',
    'Broad': 'broad',
    '广泛匹配': 'broad',
    '词组': 'phrase',
    'Phrase': 'phrase',
    '词组匹配': 'phrase',
    '精准': 'exact',
    'Exact': 'exact',
    '精准匹配': 'exact'
  }
  return map[type || ''] || 'broad'
}
