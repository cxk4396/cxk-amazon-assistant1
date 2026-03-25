<template>
  <div class="empty-state" :class="{ inline: inline }">
    <div class="empty-icon">
      <slot name="icon">
        <el-icon :size="iconSize" :color="iconColor">
          <component :is="icon" />
        </el-icon>
      </slot>
    </div>
    
    <h3 v-if="title" class="empty-title">{{ title }}</h3>
    
    <p v-if="description" class="empty-description">{{ description }}</p>
    
    <div v-if="$slots.action || actionText" class="empty-action">
      <slot name="action">
        <el-button v-if="actionText" :type="actionType" @click="$emit('action')">
          {{ actionText }}
        </el-button>
      </slot>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Box, Document, DataLine, InfoFilled } from '@element-plus/icons-vue'

interface Props {
  icon?: string
  iconSize?: number
  iconColor?: string
  title?: string
  description?: string
  actionText?: string
  actionType?: 'primary' | 'success' | 'warning' | 'danger' | 'default'
  inline?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  icon: 'Box',
  iconSize: 64,
  iconColor: '#dcdfe6',
  actionType: 'primary'
})

defineEmits<['action']>()

const icon = computed(() => {
  const iconMap: Record<string, any> = {
    Box,
    Document,
    DataLine,
    InfoFilled
  }
  return iconMap[props.icon] || Box
})
</script>

<style scoped>
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  text-align: center;
}

.empty-state.inline {
  padding: 30px 20px;
}

.empty-icon {
  margin-bottom: 20px;
}

.empty-state.inline .empty-icon {
  margin-bottom: 12px;
}

.empty-title {
  margin: 0 0 12px 0;
  font-size: 18px;
  font-weight: 500;
  color: #606266;
}

.empty-description {
  margin: 0 0 20px 0;
  font-size: 14px;
  color: #909399;
  max-width: 400px;
  line-height: 1.6;
}

.empty-state.inline .empty-description {
  margin-bottom: 12px;
}

.empty-action {
  margin-top: 8px;
}
</style>
