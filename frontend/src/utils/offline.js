import Dexie from 'dexie'

// 创建IndexedDB数据库
export class TodoDatabase extends Dexie {
  constructor() {
    super('TodoDatabase')
    
    this.version(1).stores({
      events: '++id, title, description, status, priority, dueDate, createdAt, updatedAt',
      tasks: '++id, eventId, title, description, status, priority, dueDate, createdAt, updatedAt'
    })
  }
}

// 创建数据库实例
export const db = new TodoDatabase()

// 离线数据管理类
export class OfflineDataManager {
  // 获取所有大事件
  async getEvents() {
    return await db.events.orderBy('createdAt').reverse().toArray()
  }
  
  // 创建大事件
  async createEvent(eventData) {
    const now = new Date()
    const event = {
      ...eventData,
      status: 'pending',
      createdAt: now,
      updatedAt: now
    }
    
    const id = await db.events.add(event)
    return { ...event, id }
  }
  
  // 更新大事件
  async updateEvent(id, eventData) {
    const updates = {
      ...eventData,
      updatedAt: new Date()
    }
    
    await db.events.update(id, updates)
    return await db.events.get(id)
  }
  
  // 删除大事件
  async deleteEvent(id) {
    // 先删除关联的任务
    await db.tasks.where('eventId').equals(id).delete()
    // 再删除事件
    await db.events.delete(id)
  }
  
  // 获取大事件的所有任务
  async getTasks(eventId) {
    return await db.tasks.where('eventId').equals(eventId).toArray()
  }
  
  // 创建任务
  async createTask(eventId, taskData) {
    const now = new Date()
    const task = {
      ...taskData,
      eventId,
      status: 'pending',
      createdAt: now,
      updatedAt: now
    }
    
    const id = await db.tasks.add(task)
    return { ...task, id }
  }
  
  // 更新任务
  async updateTask(id, taskData) {
    const updates = {
      ...taskData,
      updatedAt: new Date()
    }
    
    await db.tasks.update(id, updates)
    return await db.tasks.get(id)
  }
  
  // 删除任务
  async deleteTask(id) {
    await db.tasks.delete(id)
  }
  
  // 清空所有数据
  async clearAll() {
    await db.events.clear()
    await db.tasks.clear()
  }
  
  // 导出数据
  async exportData() {
    const events = await this.getEvents()
    const tasks = await db.tasks.toArray()
    
    return {
      events,
      tasks,
      exportTime: new Date()
    }
  }
  
  // 导入数据
  async importData(data) {
    await this.clearAll()
    
    if (data.events && data.events.length > 0) {
      await db.events.bulkAdd(data.events)
    }
    
    if (data.tasks && data.tasks.length > 0) {
      await db.tasks.bulkAdd(data.tasks)
    }
  }
}

// 创建离线数据管理器实例
export const offlineManager = new OfflineDataManager()