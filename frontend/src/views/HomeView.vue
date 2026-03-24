<template>
  <div class="home">
    <h1>CXK Amazon Assistant</h1>
    <p>AI-powered Amazon Operations Decision Support System</p>
    <el-button type="primary" @click="$router.push('/upload')">Start Analysis</el-button>
  </div>
</template>

<style scoped>
.home {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  gap: 20px;
}

h1 {
  font-size: 32px;
  color: #FF6B35;
}

p {
  color: #666;
}
</style>
