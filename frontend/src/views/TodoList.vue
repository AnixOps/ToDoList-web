<template>
  <div class="todo-container">
    <!-- 顶部导航栏 -->
    <div class="header">
      <div class="header-left">
        <div class="logo-section">
          <div class="logo-icon">📝</div>
          <h1 class="logo-text">ToDoList</h1>
        </div>
        <div class="status-indicators">
          <transition name="status-slide">
            <el-tag 
              :type="isOnline ? 'success' : 'info'" 
              size="small"
              class="status-tag"
            >
              <i class="status-dot" :class="{ online: isOnline }"></i>
              {{ isOnline ? '在线模式' : '离线模式' }}
            </el-tag>
          </transition>
        </div>
      </div>
      
      <div class="header-right">
        <!-- 主题切换按钮 -->
        <el-button
          :icon="themeStore.isDark ? 'Sunny' : 'Moon'"
          circle
          size="large"
          class="theme-toggle"
          @click="themeStore.toggleTheme()"
        />
        
        <!-- 离线模式工具 -->
        <transition name="fade">
          <div v-if="!isOnline" class="offline-tools">
            <el-button-group>
              <el-button type="primary" @click="exportData" class="tool-btn">
                <el-icon><Download /></el-icon>
                <span class="btn-text">导出</span>
              </el-button>
              <el-button type="success" @click="importData" class="tool-btn">
                <el-icon><Upload /></el-icon>
                <span class="btn-text">导入</span>
              </el-button>
            </el-button-group>
          </div>
        </transition>
        
        <!-- 用户菜单 -->
        <template v-if="isAuthenticated">
          <transition name="fade">
            <el-dropdown class="user-dropdown">
              <el-button type="primary" class="user-btn">
                <el-icon><User /></el-icon>
                <span class="user-name">{{ user?.username }}</span>
                <el-icon class="el-icon--right"><arrow-down /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item @click="goToProfile">
                    <el-icon><Setting /></el-icon>
                    个人设置
                  </el-dropdown-item>
                  <el-dropdown-item divided @click="logout">
                    <el-icon><SwitchButton /></el-icon>
                    退出登录
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </transition>
        </template>
        
        <el-button v-else type="primary" @click="goToLogin" class="login-btn">
          <el-icon><User /></el-icon>
          登录
        </el-button>
      </div>
    </div>

    <!-- 主要内容区域 - PC端左右分栏布局 -->
    <div class="main-content">
      <!-- 左侧事件列表面板 -->
      <div class="left-panel">
        <div class="panel-header">
          <h2>我的事件</h2>
          <el-button type="primary" @click="showCreateEventDialog = true" class="create-btn">
            <el-icon><Plus /></el-icon>
            创建事件
          </el-button>
        </div>
        
        <div class="events-container" v-loading="loading">
          <transition-group name="event-list" tag="div" class="events-list">
            <div
              v-for="event in events"
              :key="event.id"
              class="event-item"
              :class="{ 
                'selected': selectedEvent?.id === event.id,
                'completed': event.status === 'completed'
              }"
              @click="selectEvent(event)"
            >
              <div class="event-content">
                <div class="event-header">
                  <h3 class="event-title">{{ event.title }}</h3>
                  <div class="event-actions">
                    <el-button type="primary" text size="small" @click.stop="editEvent(event)">
                      <el-icon><Edit /></el-icon>
                    </el-button>
                    <el-button type="danger" text size="small" @click.stop="deleteEventConfirm(event)">
                      <el-icon><Delete /></el-icon>
                    </el-button>
                  </div>
                </div>
                
                <p v-if="event.description" class="event-description">
                  {{ event.description }}
                </p>
                
                <div class="event-meta">
                  <el-tag :type="getStatusType(event.status)" size="small">
                    {{ getStatusText(event.status) }}
                  </el-tag>
                  <el-tag :type="getPriorityType(event.priority)" size="small">
                    {{ getPriorityText(event.priority) }}
                  </el-tag>
                  <span class="event-date">{{ formatDate(event.dueDate) }}</span>
                </div>
                
                <div class="progress-section">
                  <div class="progress-info">
                    <span class="progress-text">{{ getTaskStats(event.id) }}</span>
                    <span class="progress-percentage">
                      {{ Math.round((todoStore.getTasksByEventId(event.id).filter(t => t.status === 'completed').length / (todoStore.getTasksByEventId(event.id).length || 1)) * 100) }}%
                    </span>
                  </div>
                  <div class="progress-bar">
                    <div class="progress-fill" :style="getProgressStyle(event.id)"></div>
                  </div>
                </div>
              </div>
            </div>
          </transition-group>

          <!-- 空状态 -->
          <div v-if="events.length === 0" class="empty-events">
            <el-icon><Document /></el-icon>
            <h3>还没有事件</h3>
            <p>创建你的第一个事件来开始管理任务吧！</p>
            <el-button type="primary" @click="showCreateEventDialog = true">
              <el-icon><Plus /></el-icon>
              创建事件
            </el-button>
          </div>
        </div>
      </div>

      <!-- 右侧任务面板 -->
      <div class="right-panel">
        <transition name="panel-slide" mode="out-in">
          <TaskPanel
            v-if="selectedEvent"
            :key="selectedEvent.id"
            :event="selectedEvent"
            :tasks="currentTasks"
            @close="selectedEvent = null"
            @task-created="handleTaskCreated"
            @task-updated="handleTaskUpdated"
            @task-deleted="handleTaskDeleted"
          />
          <div v-else class="tasks-placeholder">
            <div class="placeholder-content">
              <el-icon><List /></el-icon>
              <h3>选择一个事件</h3>
              <p>点击左侧的事件来查看和管理其中的任务</p>
            </div>
          </div>
        </transition>
      </div>
    </div>

    <!-- 移动端侧边栏背景 -->
    <transition name="overlay-fade">
      <div 
        v-if="selectedEvent && isMobile" 
        class="sidebar-overlay"
        @click="selectedEvent = null"
      ></div>
    </transition>

    <!-- 创建/编辑事件对话框 -->
    <EventDialog
      v-model="showCreateEventDialog"
      :event="editingEvent"
      @event-saved="handleEventSaved"
    />

    <!-- 导入数据对话框 -->
    <el-dialog
      v-model="showImportDialog"
      title="导入数据"
      width="400px"
      class="import-dialog"
    >
      <el-upload
        drag
        :auto-upload="false"
        :limit="1"
        accept=".json"
        @change="handleFileChange"
        class="upload-area"
      >
        <el-icon class="el-icon--upload upload-icon"><upload-filled /></el-icon>
        <div class="el-upload__text">
          将文件拖到此处，或<em>点击选择</em>
        </div>
        <template #tip>
          <div class="el-upload__tip">
            只能上传 JSON 格式的数据文件
          </div>
        </template>
      </el-upload>
      
      <template #footer>
        <el-button @click="showImportDialog = false">取消</el-button>
        <el-button type="primary" @click="confirmImport">确定导入</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import { useTodoStore } from '@/stores/todo'
import { useThemeStore } from '@/stores/theme'
import TaskPanel from '@/components/TaskPanel.vue'
import EventDialog from '@/components/EventDialog.vue'

const router = useRouter()
const authStore = useAuthStore()
const todoStore = useTodoStore()
const themeStore = useThemeStore()

// 响应式数据
const selectedEvent = ref(null)
const showCreateEventDialog = ref(false)
const showImportDialog = ref(false)
const editingEvent = ref(null)
const importFile = ref(null)
const isMobile = ref(false)

// 计算属性
const isAuthenticated = computed(() => authStore.isAuthenticated)
const user = computed(() => authStore.user)
const isOnline = computed(() => todoStore.isOnlineMode)
const events = computed(() => todoStore.events)
const loading = computed(() => todoStore.loading)
const currentTasks = computed(() => {
  return selectedEvent.value ? todoStore.getTasksByEventId(selectedEvent.value.id) : []
})

// 响应式检测
const checkMobile = () => {
  isMobile.value = window.innerWidth <= 768
}

// 方法
const goToLogin = () => {
  router.push('/login')
}

const goToProfile = () => {
  router.push('/profile')
}

const logout = () => {
  authStore.logout()
  todoStore.toggleMode()
  ElMessage.success('已退出登录')
}

const selectEvent = async (event) => {
  // 添加选择动画延迟
  if (selectedEvent.value?.id === event.id) {
    selectedEvent.value = null
    return
  }
  
  selectedEvent.value = event
  
  try {
    await todoStore.fetchTasks(event.id)
  } catch (error) {
    ElMessage.error('获取任务失败')
  }
}

const editEvent = (event) => {
  editingEvent.value = event
  showCreateEventDialog.value = true
}

const deleteEventConfirm = (event) => {
  ElMessageBox.confirm(
    `确定要删除事件 "${event.title}" 吗？这将同时删除所有相关任务。`,
    '删除确认',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).then(async () => {
    try {
      await todoStore.deleteEvent(event.id)
      if (selectedEvent.value?.id === event.id) {
        selectedEvent.value = null
      }
      ElMessage.success('事件删除成功')
    } catch (error) {
      ElMessage.error('删除事件失败')
    }
  })
}

const handleEventSaved = async (eventData) => {
  try {
    if (editingEvent.value) {
      await todoStore.updateEvent(editingEvent.value.id, eventData)
      ElMessage.success('事件更新成功')
    } else {
      const newEvent = await todoStore.createEvent(eventData)
      ElMessage.success('事件创建成功')
      
      // 添加创建成功的动画效果
      setTimeout(() => {
        const newCard = document.querySelector(`[data-event-id="${newEvent.id}"]`)
        if (newCard) {
          newCard.classList.add('animate-bounce-in')
        }
      }, 100)
    }
    
    showCreateEventDialog.value = false
    editingEvent.value = null
  } catch (error) {
    ElMessage.error(editingEvent.value ? '更新事件失败' : '创建事件失败')
  }
}

const handleTaskCreated = (task) => {
  ElMessage.success('任务创建成功')
}

const handleTaskUpdated = (task) => {
  ElMessage.success('任务更新成功')
}

const handleTaskDeleted = (taskId) => {
  ElMessage.success('任务删除成功')
}

// 工具函数
const getStatusType = (status) => {
  const types = {
    pending: '',
    completed: 'success',
    cancelled: 'danger'
  }
  return types[status] || ''
}

const getStatusText = (status) => {
  const texts = {
    pending: '进行中',
    completed: '已完成',
    cancelled: '已取消'
  }
  return texts[status] || status
}

const getPriorityType = (priority) => {
  const types = {
    low: 'info',
    medium: 'warning',
    high: 'danger'
  }
  return types[priority] || 'info'
}

const getPriorityText = (priority) => {
  const texts = {
    low: '低',
    medium: '中',
    high: '高'
  }
  return texts[priority] || priority
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN')
}

const getTaskStats = (eventId) => {
  const tasks = todoStore.getTasksByEventId(eventId)
  if (tasks.length === 0) return ''
  
  const completed = tasks.filter(t => t.status === 'completed').length
  return `${completed}/${tasks.length} 任务完成`
}

const getProgressStyle = (eventId) => {
  const tasks = todoStore.getTasksByEventId(eventId)
  if (tasks.length === 0) return { width: '0%' }
  
  const completed = tasks.filter(t => t.status === 'completed').length
  const percentage = (completed / tasks.length) * 100
  
  return {
    width: `${percentage}%`,
    backgroundColor: percentage === 100 ? 'var(--color-success)' : 'var(--color-primary)'
  }
}

// 数据导入导出
const exportData = async () => {
  try {
    const data = await todoStore.exportOfflineData()
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `todolist-backup-${new Date().toISOString().split('T')[0]}.json`
    a.click()
    URL.revokeObjectURL(url)
    
    ElMessage.success('数据导出成功')
  } catch (error) {
    ElMessage.error('导出数据失败')
  }
}

const importData = () => {
  showImportDialog.value = true
}

const handleFileChange = (uploadFile) => {
  importFile.value = uploadFile
}

const confirmImport = async () => {
  if (!importFile.value) {
    ElMessage.warning('请选择要导入的文件')
    return
  }
  
  try {
    const fileContent = await importFile.value.raw.text()
    const data = JSON.parse(fileContent)
    
    await todoStore.importOfflineData(data)
    showImportDialog.value = false
    importFile.value = null
    selectedEvent.value = null
    
    ElMessage.success('数据导入成功')
  } catch (error) {
    ElMessage.error('导入数据失败：' + error.message)
  }
}

// 监听认证状态变化
watch(() => authStore.isAuthenticated, () => {
  todoStore.toggleMode()
  loadData()
})

// 加载数据
const loadData = async () => {
  try {
    await todoStore.fetchEvents()
  } catch (error) {
    ElMessage.error('加载数据失败')
  }
}

// 组件挂载
onMounted(() => {
  authStore.initAuth()
  todoStore.toggleMode()
  loadData()
  checkMobile()
  window.addEventListener('resize', checkMobile)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
})
</script>

<style scoped>
/* PC端专用样式 */
.todo-container {
  background: var(--bg-primary);
  color: var(--text-primary);
  min-height: 100vh;
  transition: all var(--transition-normal);
}

/* 顶部 header（匹配模板） */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1400px;
  margin: 12px auto;
  padding: 12px 20px;
  box-sizing: border-box;
  gap: 12px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 18px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-icon {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  border-radius: 8px;
  background: rgba(var(--color-primary-rgb), 0.06);
}

.logo-text {
  margin: 0;
  font-size: 18px;
  color: var(--text-primary);
  font-weight: 700;
}

/* 顶部工具栏 */
.toolbar {
  background: var(--bg-surface);
  border-bottom: 1px solid var(--border-light);
  padding: 16px 24px;
  box-shadow: var(--shadow-light);
  position: sticky;
  top: 0;
  z-index: 100;
}

.toolbar-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1400px;
  margin: 0 auto;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-info .el-avatar {
  background: var(--color-primary);
}

.user-details h3 {
  margin: 0;
  color: var(--text-primary);
  font-size: 16px;
  font-weight: 600;
}

.user-details .status {
  color: var(--text-secondary);
  font-size: 12px;
  display: flex;
  align-items: center;
  gap: 6px;
}

.status-indicator {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--color-success);
  animation: pulse 2s infinite;
}

.status-indicator.offline {
  background: var(--color-warning);
}

.toolbar-actions {
  display: flex;
  gap: 12px;
}

/* 主内容区域 - 左右分栏 */
.main-content {
  display: flex;
  max-width: 1400px;
  margin: 0 auto;
  gap: 24px;
  padding: 24px;
  min-height: calc(100vh - 80px);
}

/* 左侧事件面板 */
.left-panel {
  width: 400px;
  flex-shrink: 0;
  background: var(--bg-surface);
  border-radius: 12px;
  box-shadow: var(--shadow-light);
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.panel-header {
  padding: 20px 24px;
  background: var(--bg-primary);
  border-bottom: 1px solid var(--border-light);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.panel-header h2 {
  margin: 0;
  color: var(--text-primary);
  font-size: 20px;
  font-weight: 600;
}

.create-btn {
  border-radius: 8px;
  font-weight: 500;
}

/* 事件容器 */
.events-container {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}

.events-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* 事件项 */
.event-item {
  background: var(--bg-primary);
  border: 2px solid var(--border-light);
  border-radius: 10px;
  padding: 16px;
  cursor: pointer;
  transition: all var(--transition-normal);
  position: relative;
  overflow: hidden;
}

.event-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, var(--color-primary), var(--color-secondary));
  transform: scaleX(0);
  transition: transform var(--transition-normal);
}

.event-item:hover {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-medium);
  transform: translateY(-2px);
}

.event-item:hover::before,
.event-item.selected::before {
  transform: scaleX(1);
}

.event-item.selected {
  border-color: var(--color-primary);
  background: rgba(var(--color-primary-rgb), 0.05);
  box-shadow: 0 4px 20px rgba(var(--color-primary-rgb), 0.2);
}

.event-item.completed {
  opacity: 0.7;
}

.event-content {
  width: 100%;
}

.event-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.event-title {
  margin: 0;
  color: var(--text-primary);
  font-size: 16px;
  font-weight: 600;
  line-height: 1.4;
  flex: 1;
}

.event-actions {
  display: flex;
  gap: 6px;
  opacity: 0;
  transition: opacity var(--transition-normal);
}

.event-item:hover .event-actions {
  opacity: 1;
}

.event-description {
  color: var(--text-secondary);
  font-size: 14px;
  line-height: 1.5;
  margin-bottom: 12px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.event-meta {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.event-meta .el-tag {
  font-size: 11px;
  border-radius: 4px;
}

.event-date {
  color: var(--text-secondary);
  font-size: 12px;
  font-weight: 500;
}

/* 进度条 */
.progress-section {
  margin-top: 12px;
}

.progress-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}

.progress-text {
  font-size: 12px;
  color: var(--text-secondary);
}

.progress-percentage {
  font-size: 12px;
  font-weight: 600;
  color: var(--color-primary);
}

.progress-bar {
  height: 4px;
  background: var(--bg-surface);
  border-radius: 2px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--color-primary), var(--color-secondary));
  border-radius: 2px;
  transition: width var(--transition-slow);
  position: relative;
}

.progress-fill::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  animation: shimmer 2s infinite;
}

/* 右侧任务面板 */
.right-panel {
  flex: 1;
  background: var(--bg-surface);
  border-radius: 12px;
  box-shadow: var(--shadow-light);
  overflow: hidden;
}

/* 任务占位符 */
.tasks-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  min-height: 500px;
  color: var(--text-secondary);
}

.placeholder-content {
  text-align: center;
  padding: 40px;
}

.placeholder-content .el-icon {
  font-size: 64px;
  color: var(--border-primary);
  margin-bottom: 16px;
  opacity: 0.6;
}

.placeholder-content h3 {
  margin: 0 0 8px 0;
  color: var(--text-primary);
  font-size: 20px;
  font-weight: 600;
}

.placeholder-content p {
  margin: 0;
  font-size: 14px;
  color: var(--text-secondary);
}

/* 空状态 */
.empty-events {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  text-align: center;
  min-height: 300px;
}

.empty-events .el-icon {
  font-size: 48px;
  color: var(--border-primary);
  margin-bottom: 16px;
  opacity: 0.6;
}

.empty-events h3 {
  margin: 0 0 8px 0;
  color: var(--text-primary);
  font-size: 18px;
  font-weight: 600;
}

.empty-events p {
  margin: 0 0 20px 0;
  color: var(--text-secondary);
  font-size: 14px;
}

/* 自定义滚动条 */
.events-container::-webkit-scrollbar {
  width: 6px;
}

.events-container::-webkit-scrollbar-track {
  background: var(--bg-surface);
  border-radius: 3px;
}

.events-container::-webkit-scrollbar-thumb {
  background: var(--border-primary);
  border-radius: 3px;
  transition: background var(--transition-fast);
}

.events-container::-webkit-scrollbar-thumb:hover {
  background: var(--color-primary);
}

/* 动画效果 */
.event-list-enter-active,
.event-list-leave-active {
  transition: all var(--transition-normal);
}

.event-list-enter-from {
  opacity: 0;
  transform: translateX(-20px);
}

.event-list-leave-to {
  opacity: 0;
  transform: translateX(20px);
}

.event-list-move {
  transition: transform var(--transition-normal);
}

.panel-slide-enter-active,
.panel-slide-leave-active {
  transition: all var(--transition-normal);
}

.panel-slide-enter-from {
  opacity: 0;
  transform: translateX(20px);
}

.panel-slide-leave-to {
  opacity: 0;
  transform: translateX(-20px);
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

/* Element Plus 组件样式覆盖 */
:deep(.el-button) {
  border-radius: 8px;
  transition: all var(--transition-normal);
}

:deep(.el-button:hover) {
  transform: translateY(-1px);
}

:deep(.el-tag) {
  border-radius: 4px;
  transition: all var(--transition-normal);
}

:deep(.el-loading-mask) {
  background: rgba(var(--bg-primary-rgb), 0.8);
  backdrop-filter: blur(4px);
}

/* 大屏幕优化 */
@media (min-width: 1600px) {
  .main-content {
    max-width: 1600px;
    gap: 32px;
  }
  
  .left-panel {
    width: 450px;
  }
}

/* 适中屏幕 */
@media (max-width: 1200px) {
  .main-content {
    gap: 16px;
    padding: 16px;
  }
  
  .left-panel {
    width: 350px;
  }
}

/* 小屏幕处理 */
@media (max-width: 900px) {
  .main-content {
    flex-direction: column;
    padding: 12px;
  }
  
  .left-panel {
    width: 100%;
    max-height: 40vh;
  }
  
  .right-panel {
    min-height: 50vh;
  }
  
  .toolbar-content {
    padding: 0 12px;
  }
}
</style>