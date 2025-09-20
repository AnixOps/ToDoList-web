import { defineStore } from 'pinia'

export const useThemeStore = defineStore('theme', {
  state: () => ({
    isDark: true, // 默认暗色模式
    themes: {
      dark: {
        // 主要颜色
        primary: '#00d4ff',
        primaryHover: '#00b8e6',
        primaryActive: '#009fcc',
        
        // 背景颜色
        bgPrimary: '#0f1419',
        bgSecondary: '#1a1f29',
        bgTertiary: '#252b3b',
        bgCard: '#1e2329',
        bgHover: '#2a3441',
        
        // 文字颜色
        textPrimary: '#ffffff',
        textSecondary: '#b3b9c6',
        textTertiary: '#8a919e',
        textPlaceholder: '#6b7280',
        
        // 边框颜色
        borderPrimary: '#3a4553',
        borderSecondary: '#2a3441',
        borderHover: '#4a5568',
        
        // 状态颜色
        success: '#10b981',
        warning: '#f59e0b',
        error: '#ef4444',
        info: '#3b82f6',
        
        // 优先级颜色
        priorityHigh: '#ff4757',
        priorityMedium: '#ffa726',
        priorityLow: '#66bb6a',
        
        // 阴影
        shadowPrimary: 'rgba(0, 0, 0, 0.4)',
        shadowSecondary: 'rgba(0, 0, 0, 0.2)',
        shadowHover: 'rgba(0, 212, 255, 0.2)',
      },
      light: {
        // 主要颜色
        primary: '#409eff',
        primaryHover: '#66b1ff',
        primaryActive: '#3a8ee6',
        
        // 背景颜色
        bgPrimary: '#ffffff',
        bgSecondary: '#f8f9fa',
        bgTertiary: '#f1f3f4',
        bgCard: '#ffffff',
        bgHover: '#f0f2f5',
        
        // 文字颜色
        textPrimary: '#1f2937',
        textSecondary: '#6b7280',
        textTertiary: '#9ca3af',
        textPlaceholder: '#d1d5db',
        
        // 边框颜色
        borderPrimary: '#e5e7eb',
        borderSecondary: '#f3f4f6',
        borderHover: '#d1d5db',
        
        // 状态颜色
        success: '#10b981',
        warning: '#f59e0b',
        error: '#ef4444',
        info: '#3b82f6',
        
        // 优先级颜色
        priorityHigh: '#ef4444',
        priorityMedium: '#f59e0b',
        priorityLow: '#10b981',
        
        // 阴影
        shadowPrimary: 'rgba(0, 0, 0, 0.1)',
        shadowSecondary: 'rgba(0, 0, 0, 0.05)',
        shadowHover: 'rgba(64, 158, 255, 0.2)',
      }
    }
  }),
  
  getters: {
    currentTheme: (state) => state.themes[state.isDark ? 'dark' : 'light'],
    themeClass: (state) => state.isDark ? 'theme-dark' : 'theme-light'
  },
  
  actions: {
    toggleTheme() {
      this.isDark = !this.isDark
      this.applyTheme()
      localStorage.setItem('theme', this.isDark ? 'dark' : 'light')
    },
    
    setTheme(theme) {
      this.isDark = theme === 'dark'
      this.applyTheme()
      localStorage.setItem('theme', theme)
    },
    
    initTheme() {
      const savedTheme = localStorage.getItem('theme')
      if (savedTheme) {
        this.isDark = savedTheme === 'dark'
      }
      this.applyTheme()
    },
    
    applyTheme() {
      const theme = this.currentTheme
      const root = document.documentElement
      
      // 应用CSS变量
      Object.entries(theme).forEach(([key, value]) => {
        root.style.setProperty(`--color-${key.replace(/([A-Z])/g, '-$1').toLowerCase()}`, value)
      })
      
      // 添加主题类
      document.body.className = this.themeClass
      
      // 更新Element Plus主题
      if (this.isDark) {
        document.documentElement.classList.add('dark')
      } else {
        document.documentElement.classList.remove('dark')
      }
    }
  }
})