<template>
  <div class="upload">
    <h2>Upload Data Files</h2>
    <el-upload
      drag
      action="#"
      :auto-upload="false"
      :on-change="handleFileChange"
    >
      <el-icon class="el-icon--upload"><upload-filled /></el-icon>
      <div class="el-upload__text">
        Drop file here or <em>click to upload</em>
      </div>
    </el-upload>
    <el-button type="primary" @click="$router.push('/dashboard')">View Dashboard</el-button>
  </div>
</template>

<script setup lang="ts">
import { UploadFilled } from '@element-plus/icons-vue'

const handleFileChange = (file: any) => {
  console.log('File selected:', file.name)
}
</script>

<style scoped>
.upload {
  padding: 40px;
  max-width: 800px;
  margin: 0 auto;
}

h2 {
  margin-bottom: 20px;
}
</style>
