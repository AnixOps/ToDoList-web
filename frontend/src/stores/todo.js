import { defineStore } from 'pinia'
import { todoAPI } from '@/api'
import { offlineManager } from '@/utils/offline'
import { useAuthStore } from './auth'

export const useTodoStore = defineStore('todo', {
  state: () => ({
    events: [],
    tasks: {},
    isOnlineMode: false,
    loading: false
  }),
  
  getters: {
    // 获取事件按状态分组
    eventsByStatus: (state) => {
      return state.events.reduce((acc, event) => {
        if (!acc[event.status]) {
          acc[event.status] = []
        }
        acc[event.status].push(event)
        return acc
      }, {})
    },
    
    // 获取指定事件的任务
    getTasksByEventId: (state) => (eventId) => {
      return state.tasks[eventId] || []
    }
  },
  
  actions: {
    // 切换在线/离线模式
    toggleMode() {
      const authStore = useAuthStore()
      this.isOnlineMode = authStore.isAuthenticated
    },
    
    // 获取所有事件
    async fetchEvents() {
      this.loading = true
      try {
        if (this.isOnlineMode) {
          const response = await todoAPI.getEvents()
          this.events = response.events || []
        } else {
          this.events = await offlineManager.getEvents()
        }
      } catch (error) {
        console.error('获取事件失败:', error)
        throw error
      } finally {
        this.loading = false
      }
    },
    
    // 创建事件
    async createEvent(eventData) {
      try {
        let newEvent
        if (this.isOnlineMode) {
          const response = await todoAPI.createEvent(eventData)
          newEvent = response.event
        } else {
          newEvent = await offlineManager.createEvent(eventData)
        }
        
        this.events.unshift(newEvent)
        return newEvent
      } catch (error) {
        console.error('创建事件失败:', error)
        throw error
      }
    },
    
    // 更新事件
    async updateEvent(id, eventData) {
      try {
        let updatedEvent
        if (this.isOnlineMode) {
          const response = await todoAPI.updateEvent(id, eventData)
          updatedEvent = response.event
        } else {
          updatedEvent = await offlineManager.updateEvent(id, eventData)
        }
        
        const index = this.events.findIndex(e => e.id === id)
        if (index !== -1) {
          this.events[index] = updatedEvent
        }
        
        return updatedEvent
      } catch (error) {
        console.error('更新事件失败:', error)
        throw error
      }
    },
    
    // 删除事件
    async deleteEvent(id) {
      try {
        if (this.isOnlineMode) {
          await todoAPI.deleteEvent(id)
        } else {
          await offlineManager.deleteEvent(id)
        }
        
        this.events = this.events.filter(e => e.id !== id)
        delete this.tasks[id]
      } catch (error) {
        console.error('删除事件失败:', error)
        throw error
      }
    },
    
    // 获取事件的任务
    async fetchTasks(eventId) {
      try {
        let tasks
        if (this.isOnlineMode) {
          const response = await todoAPI.getTasks(eventId)
          tasks = response.tasks || []
        } else {
          tasks = await offlineManager.getTasks(eventId)
        }
        
        this.tasks[eventId] = tasks
        return tasks
      } catch (error) {
        console.error('获取任务失败:', error)
        throw error
      }
    },
    
    // 创建任务
    async createTask(eventId, taskData) {
      try {
        let newTask
        if (this.isOnlineMode) {
          const response = await todoAPI.createTask(eventId, taskData)
          newTask = response.task
        } else {
          newTask = await offlineManager.createTask(eventId, taskData)
        }
        
        if (!this.tasks[eventId]) {
          this.tasks[eventId] = []
        }
        this.tasks[eventId].unshift(newTask)
        
        return newTask
      } catch (error) {
        console.error('创建任务失败:', error)
        throw error
      }
    },
    
    // 更新任务
    async updateTask(taskId, taskData) {
      try {
        let updatedTask
        if (this.isOnlineMode) {
          const response = await todoAPI.updateTask(taskId, taskData)
          updatedTask = response.task
        } else {
          updatedTask = await offlineManager.updateTask(taskId, taskData)
        }
        
        // 找到任务并更新
        for (const eventId in this.tasks) {
          const taskIndex = this.tasks[eventId].findIndex(t => t.id === taskId)
          if (taskIndex !== -1) {
            this.tasks[eventId][taskIndex] = updatedTask
            break
          }
        }
        
        return updatedTask
      } catch (error) {
        console.error('更新任务失败:', error)
        throw error
      }
    },
    
    // 删除任务
    async deleteTask(taskId, eventId) {
      try {
        if (this.isOnlineMode) {
          await todoAPI.deleteTask(taskId)
        } else {
          await offlineManager.deleteTask(taskId)
        }
        
        if (this.tasks[eventId]) {
          this.tasks[eventId] = this.tasks[eventId].filter(t => t.id !== taskId)
        }
      } catch (error) {
        console.error('删除任务失败:', error)
        throw error
      }
    },
    
    // 导出离线数据
    async exportOfflineData() {
      return await offlineManager.exportData()
    },
    
    // 导入离线数据
    async importOfflineData(data) {
      await offlineManager.importData(data)
      await this.fetchEvents()
    }
  }
})