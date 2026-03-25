<template>
  <div class="home-view">
    <!-- 欢迎区域 -->
    <div class="hero-section">
      <div class="hero-content">
        <el-icon class="hero-icon" :size="64"><Shop /></el-icon>
        <h1 class="hero-title">CXK运营决策助手</h1>
        <p class="hero-subtitle">
          基于A9+COSMO算法的智能亚马逊运营决策系统
        </p>
        <el-button type="primary" size="large" @click="$router.push('/upload')"
          class="start-btn"
003e
          <el-icon class="btn-icon"><Rocket /></el-icon>
          开始分析
        </el-button>
      </div>
    </div>

    <!-- 功能特性 -->
    <div class="features-section">
      <h2 class="section-title">核心功能</h2>
      
      <el-row :gutter="20">
        <el-col :span="8">
          <el-card class="feature-card">
            <el-icon class="feature-icon" :size="40"><Upload /></el-icon>
            <h3>批量数据上传</h3>
            <p>支持5种标准格式的Excel/CSV文件批量上传，智能识别数据列</p>
          </el-card>
        </el-col>
        
        <el-col :span="8">
          <el-card class="feature-card">
            <el-icon class="feature-icon" :size="40"><DataAnalysis /></el-icon>
            <h3>AI智能诊断</h3>
            <p>基于A9+COSMO算法，自动诊断各ASIN数据健康度</p>
          </el-card>
        </el-col>
        
        <el-col :span="8">
          <el-card class="feature-card">
            <el-icon class="feature-icon" :size="40"><MagicStick /></el-icon>
            <h3>优化方案生成</h3>
            <p>一键生成链接/广告/评分三维度优化方案，可直接执行</p>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 使用流程 -->
    <div class="workflow-section">
      <h2 class="section-title">使用流程</h2>
      
      <div class="workflow-steps">
        <div class="step">
          <div class="step-number">1</div>
          <div class="step-content">
            <h4>上传数据</h4>
            <p>导出5个平台数据文件 → 批量上传</p>
          </div>
        </div>
        
        <div class="step-arrow"><el-icon><ArrowRight /></el-icon></div>
        
        <div class="step">
          <div class="step-number">2</div>
          <div class="step-content">
            <h4>配置参数</h4>
            <p>补充定价、利润目标、文案偏好</p>
          </div>
        </div>
        
        <div class="step-arrow"><el-icon><ArrowRight /></el-icon></div>
        
        <div class="step">
          <div class="step-number">3</div>
          <div class="step-content">
            <h4>AI分析</h4>
            <p>自动分析数据健康度</p>
          </div>
        </div>
        
        <div class="step-arrow"><el-icon><ArrowRight /></el-icon></div>
        
        <div class="step">
          <div class="step-number">4</div>
          <div class="step-content">
            <h4>获取方案</h4>
            <p>导出优化文案，上传回亚马逊</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// 首页逻辑
</script>

<style scoped>
.home-view {
  max-width: 1200px;
  margin: 0 auto;
}

.hero-section {
  text-align: center;
  padding: 60px 20px;
  background: linear-gradient(135deg, #232F3E 0%, #37475A 100%);
  border-radius: 12px;
  margin-bottom: 40px;
  color: white;
}

.hero-content {
  max-width: 600px;
  margin: 0 auto;
}

.hero-icon {
  color: #FF9900;
  margin-bottom: 20px;
}

.hero-title {
  font-size: 36px;
  margin: 0 0 16px 0;
  color: white;
}

.hero-subtitle {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.8);
  margin-bottom: 30px;
}

.start-btn {
  padding: 16px 40px;
  font-size: 16px;
}

.btn-icon {
  margin-right: 8px;
}

.features-section {
  margin-bottom: 40px;
}

.section-title {
  text-align: center;
  margin-bottom: 30px;
  color: #303133;
}

.feature-card {
  text-align: center;
  height: 100%;
}

.feature-icon {
  color: #FF9900;
  margin-bottom: 16px;
}

.feature-card h3 {
  margin: 0 0 12px 0;
  color: #303133;
}

.feature-card p {
  color: #606266;
  margin: 0;
  font-size: 14px;
  line-height: 1.6;
}

.workflow-section {
  padding: 40px 20px;
  background: #f5f7fa;
  border-radius: 12px;
}

.workflow-steps {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  flex-wrap: wrap;
}

.step {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  max-width: 200px;
}

.step-number {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: #FF9900;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  flex-shrink: 0;
}

.step-content h4 {
  margin: 0 0 4px 0;
  color: #303133;
}

.step-content p {
  margin: 0;
  font-size: 13px;
  color: #606266;
}

.step-arrow {
  color: #909399;
}
</style>
