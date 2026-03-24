<template>
  <div class="dashboard">
    <h2>Dashboard</h2>
    <el-row :gutter="20">
      <el-col :span="6">
        <el-card>
          <template #header>Total Exposure</template>
          <div class="metric">6.8K</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <template #header>Total Clicks</template>
          <div class="metric">12.0K</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <template #header>Total Orders</template>
          <div class="metric">868</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card>
          <template #header>Total Sales</template>
          <div class="metric">$8.2K</div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
.dashboard {
  padding: 40px;
}

.metric {
  font-size: 24px;
  font-weight: bold;
  color: #FF6B35;
}
</style>
