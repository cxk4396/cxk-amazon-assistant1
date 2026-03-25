<template>
  <div class="templates-view">
    <el-card>
      <template #header>
        <div class="card-header">
          <span><</> 列选择模板管理</span>
          <el-button type="primary" @click="showCreateDialog = true">
            <el-icon><Plus /></el-icon>
            新建模板
          </el-button>
        </div>
      </template>

      <el-table :data="templates" style="width: 100%">
        <el-table-column prop="name" label="模板名称" />
        <el-table-column prop="description" label="描述" />
        <el-table-column prop="columnCount" label="列数" width="80" />
        <el-table-column prop="createdAt" label="创建时间" width="180" />
        
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button type="primary" link @click="applyTemplate(row)">
              应用
            </el-button>
            <el-button link @click="editTemplate(row)">
              编辑
            </el-button>
            <el-button type="danger" link @click="deleteTemplate(row)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-empty v-if="templates.length === 0" description="暂无模板，点击上方按钮创建" />
    </el-card>

    <!-- 创建模板对话框 -->
    <el-dialog v-model="showCreateDialog" title="新建模板" width="600px">
      <el-form :model="newTemplate" label-width="100px">
        <el-form-item label="模板名称" required>
          <el-input v-model="newTemplate.name" placeholder="输入模板名称" />
        </el-form-item>
        
        <el-form-item label="模板描述">
          <el-input 
            v-model="newTemplate.description" 
            type="textarea"
            :rows="3"
            placeholder="描述该模板的用途..."
          />
        </el-form-item>
        
        <el-form-item label="适用文件">
          <el-select v-model="newTemplate.filePattern" placeholder="选择适用的文件类型">
            <el-option label="所有库存报告" value="*库存报告*" />
            <el-option label="AM67销售数据" value="AM67*" />
            <el-option label="通用模板" value="*" />
          </el-select>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="createTemplate">创建</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const templates = ref<any[]>([])
const showCreateDialog = ref(false)

const newTemplate = ref({
  name: '',
  description: '',
  filePattern: '*'
})

const applyTemplate = (row: any) => {
  ElMessage.success(`已应用模板: ${row.name}`)
}

const editTemplate = (row: any) => {
  ElMessage.info('编辑功能开发中...')
}

const deleteTemplate = async (row: any) => {
  try {
    await ElMessageBox.confirm(`确定删除模板 "${row.name}" 吗？`, '提示', {
      type: 'warning'
    })
    const index = templates.value.findIndex(t => t.id === row.id)
    if (index > -1) {
      templates.value.splice(index, 1)
    }
    ElMessage.success('删除成功')
  } catch {
    // 取消删除
  }
}

const createTemplate = () => {
  if (!newTemplate.value.name) {
    ElMessage.warning('请输入模板名称')
    return
  }
  
  templates.value.push({
    id: Date.now(),
    ...newTemplate.value,
    columnCount: 0,
    createdAt: new Date().toLocaleString()
  })
  
  showCreateDialog.value = false
  newTemplate.value = { name: '', description: '', filePattern: '*' }
  ElMessage.success('模板创建成功')
}
</script>

<style scoped>
.templates-view {
  max-width: 1000px;
  margin: 0 auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
