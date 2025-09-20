import api from '@/utils/api'

// 认证相关API
export const authAPI = {
  // 登录
  login(data) {
    return api.post('/auth/login', data)
  },
  
  // 注册
  register(data) {
    return api.post('/auth/register', data)
  }
}

// TodoList相关API
export const todoAPI = {
  // 获取所有大事件
  getEvents() {
    return api.get('/events')
  },
  
  // 创建大事件
  createEvent(data) {
    return api.post('/events', data)
  },
  
  // 更新大事件
  updateEvent(id, data) {
    return api.put(`/events/${id}`, data)
  },
  
  // 删除大事件
  deleteEvent(id) {
    return api.delete(`/events/${id}`)
  },
  
  // 获取大事件的所有小事件
  getTasks(eventId) {
    return api.get(`/events/${eventId}/tasks`)
  },
  
  // 创建小事件
  createTask(eventId, data) {
    return api.post(`/events/${eventId}/tasks`, data)
  },
  
  // 更新小事件
  updateTask(id, data) {
    return api.put(`/tasks/${id}`, data)
  },
  
  // 删除小事件
  deleteTask(id) {
    return api.delete(`/tasks/${id}`)
  }
}