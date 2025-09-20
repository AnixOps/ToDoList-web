<template>
  <div id="app" :class="themeClass">
    <transition name="page" mode="out-in">
      <router-view />
    </transition>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useThemeStore } from '@/stores/theme'

const themeStore = useThemeStore()

const themeClass = computed(() => themeStore.themeClass)

onMounted(() => {
  themeStore.initTheme()
})
</script>

<style>
/* CSS Variables for theming */
:root {
  /* These will be set by theme store */
}

#app {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  min-height: 100vh;
  background-color: var(--color-bg-primary);
  color: var(--color-text-primary);
  transition: background-color 0.3s ease, color 0.3s ease;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  margin: 0;
  background-color: var(--color-bg-primary);
  transition: background-color 0.3s ease;
}

/* Page transition animations */
.page-enter-active,
.page-leave-active {
  transition: all 0.3s ease;
}

.page-enter-from {
  opacity: 0;
  transform: translateX(30px);
}

.page-leave-to {
  opacity: 0;
  transform: translateX(-30px);
}

/* Dark theme styles */
.theme-dark {
  --el-color-primary: var(--color-primary);
  --el-bg-color: var(--color-bg-primary);
  --el-bg-color-page: var(--color-bg-primary);
  --el-text-color-primary: var(--color-text-primary);
  --el-text-color-regular: var(--color-text-secondary);
  --el-border-color: var(--color-border-primary);
  --el-fill-color-blank: var(--color-bg-card);
}

.theme-dark .el-card {
  background-color: var(--color-bg-card) !important;
  border-color: var(--color-border-primary) !important;
}

.theme-dark .el-dialog {
  background-color: var(--color-bg-card) !important;
}

.theme-dark .el-input__wrapper {
  background-color: var(--color-bg-tertiary) !important;
  border-color: var(--color-border-primary) !important;
}

.theme-dark .el-select .el-input__wrapper {
  background-color: var(--color-bg-tertiary) !important;
}

.theme-dark .el-textarea__inner {
  background-color: var(--color-bg-tertiary) !important;
  border-color: var(--color-border-primary) !important;
  color: var(--color-text-primary) !important;
}

/* Scrollbar styling for dark theme */
.theme-dark ::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

.theme-dark ::-webkit-scrollbar-track {
  background: var(--color-bg-secondary);
}

.theme-dark ::-webkit-scrollbar-thumb {
  background: var(--color-border-primary);
  border-radius: 3px;
}

.theme-dark ::-webkit-scrollbar-thumb:hover {
  background: var(--color-border-hover);
}

/* Light theme styles */
.theme-light {
  --el-color-primary: var(--color-primary);
  --el-bg-color: var(--color-bg-primary);
  --el-bg-color-page: var(--color-bg-primary);
  --el-text-color-primary: var(--color-text-primary);
  --el-text-color-regular: var(--color-text-secondary);
  --el-border-color: var(--color-border-primary);
}

/* Global animation utilities */
@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(30px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slideInLeft {
  from {
    opacity: 0;
    transform: translateX(-30px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slideInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes scaleIn {
  from {
    opacity: 0;
    transform: scale(0.9);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

@keyframes bounceIn {
  0% {
    opacity: 0;
    transform: scale(0.3);
  }
  50% {
    transform: scale(1.05);
  }
  70% {
    transform: scale(0.9);
  }
  100% {
    opacity: 1;
    transform: scale(1);
  }
}

/* Utility classes for animations */
.animate-slide-in-right {
  animation: slideInRight 0.3s ease-out forwards;
}

.animate-slide-in-left {
  animation: slideInLeft 0.3s ease-out forwards;
}

.animate-slide-in-up {
  animation: slideInUp 0.3s ease-out forwards;
}

.animate-fade-in {
  animation: fadeIn 0.3s ease-out forwards;
}

.animate-scale-in {
  animation: scaleIn 0.3s ease-out forwards;
}

.animate-bounce-in {
  animation: bounceIn 0.5s ease-out forwards;
}

/* Responsive design */
@media (max-width: 768px) {
  #app {
    font-size: 14px;
  }
}

@media (max-width: 480px) {
  #app {
    font-size: 13px;
  }
}
</style>