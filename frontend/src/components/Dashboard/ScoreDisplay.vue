<template>
  <span class="score-display" :class="scoreClass">
    {{ score }}分
  </span>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  score: number
}>()

const scoreClass = computed(() => {
  if (props.score >= 80) return 'excellent'
  if (props.score >= 60) return 'good'
  if (props.score >= 40) return 'fair'
  return 'poor'
})
</script>

<style scoped>
.score-display {
  font-weight: bold;
  padding: 4px 8px;
  border-radius: 4px;
}

.excellent {
  color: #67c23a;
  background: #f0f9eb;
}

.good {
  color: #409eff;
  background: #ecf5ff;
}

.fair {
  color: #e6a23c;
  background: #fdf6ec;
}

.poor {
  color: #f56c6c;
  background: #fef0f0;
}
</style>
