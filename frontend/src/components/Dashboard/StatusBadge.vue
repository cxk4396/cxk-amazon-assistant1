<template>
  <el-tag :type="tagType" size="small">
    {{ statusText }}
  </el-tag>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  status: 'normal' | 'warning' | 'critical'
}>()

const tagType = computed(() => {
  switch (props.status) {
    case 'normal':
      return 'success'
    case 'warning':
      return 'warning'
    case 'critical':
      return 'danger'
    default:
      return 'info'
  }
})

const statusText = computed(() => {
  switch (props.status) {
    case 'normal':
      return '✅ 正常'
    case 'warning':
      return '⚠️ 偏低'
    case 'critical':
      return '❌ 异常'
    default:
      return '-'
  }
})
</script>
