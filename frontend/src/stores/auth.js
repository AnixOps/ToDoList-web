import { defineStore } from 'pinia'
import { authAPI } from '@/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: localStorage.getItem('token'),
    isAuthenticated: false
  }),
  
  getters: {
    currentUser: (state) => state.user,
    isLoggedIn: (state) => state.isAuthenticated && !!state.token
  },
  
  actions: {
    // 初始化认证状态
    initAuth() {
      const token = localStorage.getItem('token')
      const user = localStorage.getItem('user')
      
      if (token && user) {
        this.token = token
        this.user = JSON.parse(user)
        this.isAuthenticated = true
      }
    },
    
    // 登录
    async login(credentials) {
      try {
        const response = await authAPI.login(credentials)
        
        this.token = response.token
        this.user = response.user
        this.isAuthenticated = true
        
        // 保存到本地存储
        localStorage.setItem('token', response.token)
        localStorage.setItem('user', JSON.stringify(response.user))
        
        return response
      } catch (error) {
        throw error
      }
    },
    
    // 注册
    async register(userData) {
      try {
        const response = await authAPI.register(userData)
        
        this.token = response.token
        this.user = response.user
        this.isAuthenticated = true
        
        // 保存到本地存储
        localStorage.setItem('token', response.token)
        localStorage.setItem('user', JSON.stringify(response.user))
        
        return response
      } catch (error) {
        throw error
      }
    },
    
    // 退出登录
    logout() {
      this.token = null
      this.user = null
      this.isAuthenticated = false
      
      // 清除本地存储
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    }
  }
})