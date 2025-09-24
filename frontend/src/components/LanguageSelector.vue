<template>
  <el-dropdown @command="changeLanguage" trigger="hover">
    <span class="language-selector">
      <el-icon class="language-icon"><Setting /></el-icon>
      {{ currentLanguageName }}
      <el-icon class="arrow-icon"><ArrowDown /></el-icon>
    </span>
    <template #dropdown>
      <el-dropdown-menu>
        <el-dropdown-item
          v-for="(info, locale) in SUPPORTED_LOCALES"
          :key="locale"
          :command="locale"
          :class="{ 'is-active': locale === currentLocale }"
        >
          <span class="locale-option">
            <span class="locale-name">{{ info.nativeName }}</span>
            <span class="locale-check" v-if="locale === currentLocale">
              <el-icon><Check /></el-icon>
            </span>
          </span>
        </el-dropdown-item>
      </el-dropdown-menu>
    </template>
  </el-dropdown>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Setting, ArrowDown, Check } from '@element-plus/icons-vue'
import { 
  SUPPORTED_LOCALES, 
  setLocale, 
  getCurrentLocale, 
  getLocaleDisplayName 
} from '@/i18n'

// 响应式数据
const currentLocale = ref(getCurrentLocale())

// 计算属性
const currentLanguageName = computed(() => {
  return getLocaleDisplayName(currentLocale.value)
})

// 切换语言
const changeLanguage = (locale) => {
  const newLocale = setLocale(locale)
  currentLocale.value = newLocale
  
  // 触发自定义事件，让父组件知道语言已更改
  window.dispatchEvent(new CustomEvent('language-changed', { 
    detail: { locale: newLocale } 
  }))
  
  // 可选：刷新Element Plus的语言
  window.location.reload()
}

// 组件挂载时更新当前语言
onMounted(() => {
  currentLocale.value = getCurrentLocale()
})
</script>

<style scoped>
.language-selector {
  display: flex;
  align-items: center;
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 6px;
  transition: all 0.3s ease;
  color: var(--el-text-color-regular);
  font-size: 14px;
  user-select: none;
}

.language-selector:hover {
  background-color: var(--el-fill-color-light);
  color: var(--el-color-primary);
}

.language-icon {
  margin-right: 6px;
  font-size: 16px;
}

.arrow-icon {
  margin-left: 4px;
  font-size: 12px;
  transition: transform 0.3s ease;
}

.language-selector:hover .arrow-icon {
  transform: rotate(180deg);
}

.locale-option {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  min-width: 140px;
}

.locale-name {
  flex: 1;
}

.locale-check {
  margin-left: 8px;
  color: var(--el-color-primary);
}

.is-active {
  background-color: var(--el-color-primary-light-9);
  color: var(--el-color-primary);
}

/* 深色主题适配 */
.dark .language-selector {
  color: var(--el-text-color-primary);
}

.dark .language-selector:hover {
  background-color: var(--el-fill-color-dark);
}

/* 移动端适配 */
@media (max-width: 768px) {
  .language-selector {
    padding: 6px 8px;
    font-size: 12px;
  }
  
  .locale-option {
    min-width: 120px;
  }
}
</style>