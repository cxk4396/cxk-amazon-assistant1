import { invoke } from '@tauri-apps/api/core'

export interface AIConfig {
  baseUrl: string
  apiKey: string
  model: string
  temperature?: number
}

export interface AnalysisInput {
  asin: string
  title?: string
  sales?: any
  traffic?: any
  advertising?: any
  listing?: any
  competitor?: any
  params?: {
    targetMargin?: number
    targetAcos?: number
    contentStyle?: string
  }
}

export interface DiagnosisResult {
  overallHealth: string
  score: number
  primaryIssue: string
  rootCause: string
}

export interface MetricsResult {
  exposure: { status: string; suggestion: string }
  click: { status: string; suggestion: string }
  conversion: { status: string; suggestion: string }
}

export interface ListingOptimization {
  keywordsToAdd: string[]
  keywordsToOptimize: string[]
  optimizedTitle: string
  optimizedBullets: string[]
  optimizedSearchTerms: string
  rationale: string
}

export interface AdvertisingOptimization {
  bidAdjustment: { current: number; recommended: number; rationale: string }
  keywordsToAdd: Array<{ keyword: string; matchType: string; suggestedBid: number }>
  campaignSuggestions: string[]
  budgetAdjustment: { current: number; recommended: number }
}

export interface ReviewOptimization {
  currentRating: number
  currentCount: number
  targetRating: number
  targetCount: number
  strategy: string
  warning: string
}

export interface AIAnalysisResult {
  diagnosis: DiagnosisResult
  metrics: MetricsResult
  optimization: {
    listing: ListingOptimization
    advertising: AdvertisingOptimization
    review: ReviewOptimization
  }
}

// 获取系统Prompt
function getSystemPrompt(): string {
  return `你是亚马逊A9+COSMO算法专家，拥有10年亚马逊运营经验。
你的任务是分析运营数据，诊断问题，并输出可直接执行的优化方案。

# Principles
1. 数据驱动：所有结论必须基于提供的数据
2. 可执行性：建议必须具体，包含数值和操作方法
3. 合规意识：所有建议必须符合亚马逊平台规则
4. 算法适配：优化策略需考虑A9（搜索排名）和COSMO（个性化推荐）双算法

# A9算法核心因素
- 相关性：标题、Bullet、Search Terms中的关键词匹配度
- 绩效：销量、转化率、评价、退货率
- 广告：广告销量占比、ACoS、广告排名

# COSMO算法核心因素
- 用户意图理解：基于购物行为的个性化推荐
- 多轮会话：关联购买、互补推荐
- 上下文感知：季节、趋势、用户画像

# Output Rules
1. 必须严格按要求的JSON格式输出
2. 所有数值保留2位小数
3. 文案输出必须符合亚马逊字符限制
4. 不要输出JSON之外的任何内容`
}

// 构建诊断Prompt
function buildDiagnosisPrompt(input: AnalysisInput): string {
  return `## 任务
分析ASIN运营数据，诊断核心问题，输出结构化优化方案。

## 输入数据
### 基础信息
- ASIN: ${input.asin}
- Title: ${input.title || '未提供'}

### 流量数据（近30天）
- 曝光量(Sessions): ${input.traffic?.['Sessions'] || input.traffic?.['Sessions - Total'] || '未提供'}
- 点击量(Page Views): ${input.traffic?.['Page Views'] || input.traffic?.['Page Views - Total'] || '未提供'}
- 订单量: ${input.sales?.['Ordered Units'] || input.sales?.['销量'] || '未提供'}
- 销售额: ${input.sales?.['Ordered Revenue'] || input.sales?.['销售额'] || '未提供'}

### 广告数据
- 广告花费: ${input.advertising?.['Spend'] || input.advertising?.['广告花费'] || '未提供'}
- 广告销售额: ${input.advertising?.['Sales'] || input.advertising?.['广告销售额'] || '未提供'}
- ACOS: ${input.advertising?.['ACOS'] || input.advertising?.['acos'] || '未提供'}

### 当前文案
- Title: ${input.listing?.['Title'] || '未提供'}
- Bullet 1: ${input.listing?.['Bullet Point 1'] || '未提供'}

## 诊断规则（A9+COSMO）
1. 曝光评估: 
   - Sessions < 1000: 严重偏低 → 关键词/竞价问题
   - Sessions 1000-5000: 偏低 → 优化空间
   - Sessions > 5000: 正常

2. 点击评估(CTR):
   - CTR < 1%: 严重偏低 → 主图/价格/标题问题
   - CTR 1%-2%: 偏低
   - CTR > 2%: 正常

3. 转化评估:
   - 转化率 < 5%: 偏低 → 详情页/评价/价格问题
   - 转化率 5%-15%: 正常
   - 转化率 > 15%: 优秀

## 输出格式（必须严格JSON）
{
  "diagnosis": {
    "overallHealth": "健康/亚健康/需优化/紧急优化",
    "score": 0-100,
    "primaryIssue": "最主要的问题",
    "rootCause": "根因分析"
  },
  "metrics": {
    "exposure": {"status": "正常/偏低/严重偏低", "suggestion": "..."},
    "click": {"status": "...", "suggestion": "..."},
    "conversion": {"status": "...", "suggestion": "..."}
  },
  "optimization": {
    "listing": {
      "keywordsToAdd": ["词1", "词2"],
      "keywordsToOptimize": ["词3"],
      "optimizedTitle": "优化后的完整Title（≤200字符）",
      "optimizedBullets": ["优化后的Bullet1", "..."],
      "optimizedSearchTerms": "优化后的后台搜索词（≤249字节）",
      "rationale": "优化理由"
    },
    "advertising": {
      "bidAdjustment": {"current": 0.8, "recommended": 1.2, "rationale": "..."},
      "keywordsToAdd": [{"keyword": "...", "matchType": "广泛/词组/精准", "suggestedBid": 1.0}],
      "campaignSuggestions": ["投放建议1"],
      "budgetAdjustment": {"current": 25, "recommended": 35}
    },
    "review": {
      "currentRating": 4.2,
      "currentCount": 127,
      "targetRating": 4.5,
      "targetCount": 200,
      "strategy": "送测策略建议",
      "warning": "注意事项"
    }
  }
}`
}

// AI分析主函数
export async function analyzeAsin(
  config: AIConfig,
  input: AnalysisInput
): Promise<AIAnalysisResult> {
  const messages = [
    { role: 'system', content: getSystemPrompt() },
    { role: 'user', content: buildDiagnosisPrompt(input) }
  ]

  try {
    const response = await fetch(`${config.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${config.apiKey}`
      },
      body: JSON.stringify({
        model: config.model,
        messages,
        temperature: config.temperature ?? 0.3,
        response_format: { type: 'json_object' }
      })
    })

    if (!response.ok) {
      const error = await response.text()
      throw new Error(`API请求失败: ${error}`)
    }

    const data = await response.json()
    const content = data.choices?.[0]?.message?.content

    if (!content) {
      throw new Error('API返回数据格式错误')
    }

    // 解析JSON结果
    const result: AIAnalysisResult = JSON.parse(content)
    return result
  } catch (error) {
    console.error('AI分析错误:', error)
    throw error
  }
}

// 批量分析
export async function analyzeAsinBatch(
  config: AIConfig,
  inputs: AnalysisInput[],
  onProgress?: (current: number, total: number) => void
): Promise<AIAnalysisResult[]> {
  const results: AIAnalysisResult[] = []
  
  for (let i = 0; i < inputs.length; i++) {
    try {
      const result = await analyzeAsin(config, inputs[i])
      results.push(result)
      onProgress?.(i + 1, inputs.length)
    } catch (error) {
      console.error(`分析ASIN ${inputs[i].asin} 失败:`, error)
      // 返回默认结果
      results.push(getDefaultResult())
    }
  }
  
  return results
}

// 默认结果（当API调用失败时）
function getDefaultResult(): AIAnalysisResult {
  return {
    diagnosis: {
      overallHealth: '需优化',
      score: 60,
      primaryIssue: '数据不足，无法准确诊断',
      rootCause: '请检查数据文件是否包含完整信息'
    },
    metrics: {
      exposure: { status: '未知', suggestion: '请补充流量数据' },
      click: { status: '未知', suggestion: '请补充流量数据' },
      conversion: { status: '未知', suggestion: '请补充销售数据' }
    },
    optimization: {
      listing: {
        keywordsToAdd: [],
        keywordsToOptimize: [],
        optimizedTitle: '',
        optimizedBullets: ['', '', '', '', ''],
        optimizedSearchTerms: '',
        rationale: '数据不足'
      },
      advertising: {
        bidAdjustment: { current: 0, recommended: 0, rationale: '数据不足' },
        keywordsToAdd: [],
        campaignSuggestions: [],
        budgetAdjustment: { current: 0, recommended: 0 }
      },
      review: {
        currentRating: 0,
        currentCount: 0,
        targetRating: 0,
        targetCount: 0,
        strategy: '数据不足',
        warning: '暂无'
      }
    }
  }
}

// 测试API连接
export async function testAIConnection(config: AIConfig): Promise<boolean> {
  try {
    const response = await fetch(`${config.baseUrl}/models`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${config.apiKey}`
      }
    })
    return response.ok
  } catch {
    return false
  }
}
