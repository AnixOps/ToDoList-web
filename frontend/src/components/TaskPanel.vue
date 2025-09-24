<template>
  <div class="task-panel" :class="{ 'mobile': isMobile }">
    <!-- 头部 -->
    <div class="panel-header">
      <div class="header-content">
        <h2 class="animate-fade-in">{{ event.title }}</h2>
        <p v-if="event.description" class="event-description animate-fade-in-delay">
          {{ event.description }}
        </p>
        <div class="event-stats animate-fade-in-delay">
          <el-tag :type="getStatusType(event.status)" size="small">
            {{ getStatusText(event.status) }}
          </el-tag>
          <el-tag :type="getPriorityType(event.priority)" size="small">
            {{ $t('todo.priority') }}: {{ getPriorityText(event.priority) }}
          </el-tag>
          <span class="task-count">{{ tasks.length }} {{ $t('task.title') }}</span>
        </div>
      </div>
      <el-button
        type="text"
        size="large"
        class="close-btn"
        @click="$emit('close')"
      >
        <el-icon><Close /></el-icon>
      </el-button>
    </div>

    <!-- 进度条 -->
    <div class="progress-section animate-slide-in-up">
      <div class="progress-header">
        <span class="progress-label">{{ $t('todo.progress') }}</span>
        <span class="progress-percentage">{{ progressPercentage }}%</span>
      </div>
      <div class="progress-container">
        <div class="progress-bar">
          <div 
            class="progress-fill" 
            :style="{ width: progressPercentage + '%' }"
          ></div>
        </div>
      </div>
    </div>

    <!-- 创建任务 -->
    <div class="create-task-section animate-slide-in-up">
      <el-button
        type="primary"
        size="large"
        class="create-task-btn"
        @click="showCreateTaskDialog = true"
      >
        <el-icon class="btn-icon"><Plus /></el-icon>
        <span>{{ $t('task.createTask') }}</span>
        <div class="btn-ripple"></div>
      </el-button>
    </div>

    <!-- 任务筛选和排序 -->
    <div class="tasks-controls animate-slide-in-up">
      <div class="filter-section">
        <el-select
          v-model="filterStatus"
          :placeholder="$t('todo.filterByStatus')"
          size="small"
          style="width: 120px"
          @change="filterTasks"
        >
          <el-option :label="$t('todo.allTodos')" value="all" />
          <el-option :label="$t('todo.inProgress')" value="pending" />
          <el-option :label="$t('todo.completed')" value="completed" />
          <el-option :label="$t('todo.cancelled')" value="cancelled" />
        </el-select>
        
        <el-select
          v-model="sortBy"
          :placeholder="$t('todo.sortBy')"
          size="small"
          style="width: 120px"
          @change="sortTasks"
        >
          <el-option :label="$t('todo.sortByCreateTime')" value="created" />
          <el-option :label="$t('todo.sortByPriority')" value="priority" />
          <el-option :label="$t('todo.status')" value="status" />
          <el-option :label="$t('todo.sortByDueDate')" value="dueDate" />
        </el-select>
      </div>
      
      <div class="view-toggle">
        <el-button-group size="small">
          <el-button 
            :type="viewMode === 'list' ? 'primary' : ''"
            @click="viewMode = 'list'"
          >
            <el-icon><List /></el-icon>
          </el-button>
          <el-button 
            :type="viewMode === 'grid' ? 'primary' : ''"
            @click="viewMode = 'grid'"
          >
            <el-icon><Grid /></el-icon>
          </el-button>
        </el-button-group>
      </div>
    </div>

    <!-- 任务列表 -->
    <div class="tasks-section">
      <div class="tasks-header">
        <h3>{{ $t('task.title') }}{{ $t('common.list') || '列表' }}</h3>
        <span class="tasks-count">{{ filteredTasks.length }} / {{ tasks.length }}</span>
      </div>

      <transition-group
        name="task-list"
        tag="div"
        class="tasks-list"
        :class="{ 'grid-view': viewMode === 'grid' }"
      >
        <div
          v-for="task in filteredTasks"
          :key="task.id"
          class="task-item animate-task-enter"
          :class="{ 
            completed: task.status === 'completed',
            cancelled: task.status === 'cancelled',
            overdue: isOverdue(task)
          }"
          @click="selectTask(task)"
        >
          <div class="task-content">
            <div class="task-main">
              <el-checkbox
                :model-value="task.status === 'completed'"
                @change="toggleTaskStatus(task)"
                @click.stop
                class="task-checkbox"
              />
              <div class="task-info">
                <h4 class="task-title">{{ task.title }}</h4>
                <p v-if="task.description" class="task-description">
                  {{ task.description }}
                </p>
                <div class="task-meta">
                  <el-tag
                    :type="getPriorityType(task.priority)"
                    size="small"
                    effect="plain"
                    class="priority-tag"
                  >
                    {{ getPriorityText(task.priority) }}
                  </el-tag>
                  <el-tag
                    :type="getStatusType(task.status)"
                    size="small"
                    class="status-tag"
                  >
                    {{ getStatusText(task.status) }}
                  </el-tag>
                  <span v-if="task.dueDate" class="due-date" :class="{ overdue: isOverdue(task) }">
                    <el-icon><Calendar /></el-icon>
                    {{ formatDate(task.dueDate) }}
                  </span>
                </div>
              </div>
            </div>
            
            <div class="task-actions">
              <el-button
                type="primary"
                text
                size="small"
                @click.stop="editTask(task)"
                class="action-btn"
              >
                <el-icon><Edit /></el-icon>
              </el-button>
              <el-button
                type="danger"
                text
                size="small"
                @click.stop="deleteTaskConfirm(task)"
                class="action-btn"
              >
                <el-icon><Delete /></el-icon>
              </el-button>
            </div>
          </div>
          
          <!-- 任务进度指示器 -->
          <div class="task-progress-indicator" v-if="task.status === 'completed'">
            <el-icon class="check-icon"><Check /></el-icon>
          </div>
        </div>
      </transition-group>

      <!-- 空状态 -->
      <div v-if="filteredTasks.length === 0" class="empty-tasks">
        <div class="empty-icon">
          <el-icon><DocumentChecked /></el-icon>
        </div>
        <h3>{{ tasks.length === 0 ? $t('task.noTasks') : $t('todo.noTodos') }}</h3>
        <p>{{ tasks.length === 0 ? $t('todo.addFirstTodo') : $t('todo.adjustFilters') }}</p>
      </div>
    </div>
    <!-- 创建/编辑任务对话框 -->
    <TaskDialog
      v-model="showCreateTaskDialog"
      :task="editingTask"
      @task-saved="handleTaskSaved"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useI18n } from 'vue-i18n'
import { useTodoStore } from '@/stores/todo'
import { useThemeStore } from '@/stores/theme'
import TaskDialog from './TaskDialog.vue'

const props = defineProps({
  event: Object,
  tasks: Array
})

const emit = defineEmits(['close', 'task-created', 'task-updated', 'task-deleted'])

const todoStore = useTodoStore()
const themeStore = useThemeStore()

// 响应式数据
const showCreateTaskDialog = ref(false)
const editingTask = ref(null)
const filterStatus = ref('all')
const sortBy = ref('created')
const viewMode = ref('list')
const selectedTask = ref(null)
const isMobile = ref(false)

// 计算属性
const progressPercentage = computed(() => {
  if (props.tasks.length === 0) return 0
  const completedTasks = props.tasks.filter(task => task.status === 'completed').length
  return Math.round((completedTasks / props.tasks.length) * 100)
})

const filteredTasks = computed(() => {
  let filtered = props.tasks || []
  
  // 状态筛选
  if (filterStatus.value !== 'all') {
    filtered = filtered.filter(task => task.status === filterStatus.value)
  }
  
  // 排序
  return filtered.sort((a, b) => {
    switch (sortBy.value) {
      case 'priority':
        const priorityOrder = { high: 3, medium: 2, low: 1 }
        return priorityOrder[b.priority] - priorityOrder[a.priority]
      case 'status':
        const statusOrder = { pending: 3, completed: 2, cancelled: 1 }
        return statusOrder[b.status] - statusOrder[a.status]
      case 'dueDate':
        if (!a.dueDate && !b.dueDate) return 0
        if (!a.dueDate) return 1
        if (!b.dueDate) return -1
        return new Date(a.dueDate) - new Date(b.dueDate)
      case 'created':
      default:
        return new Date(b.createdAt) - new Date(a.createdAt)
    }
  })
})

// 响应式检测
const checkMobile = () => {
  isMobile.value = window.innerWidth <= 768
}

// 方法
const selectTask = (task) => {
  selectedTask.value = selectedTask.value?.id === task.id ? null : task
}

const toggleTaskStatus = async (task) => {
  const newStatus = task.status === 'completed' ? 'pending' : 'completed'
  
  try {
    await todoStore.updateTask(task.id, { ...task, status: newStatus })
    emit('task-updated', { ...task, status: newStatus })
    
    // 添加状态切换动画
    const taskElement = document.querySelector(`[data-task-id="${task.id}"]`)
    if (taskElement) {
      taskElement.classList.add('animate-status-change')
      setTimeout(() => {
        taskElement.classList.remove('animate-status-change')
      }, 600)
    }
    
    ElMessage.success(newStatus === 'completed' ? $t('task.taskCompleted') : $t('task.taskRestored'))
  } catch (error) {
    ElMessage.error($t('task.updateTaskFailed'))
  }
}

const editTask = (task) => {
  editingTask.value = task
  showCreateTaskDialog.value = true
}

const deleteTaskConfirm = (task) => {
  ElMessageBox.confirm(
    `确定要删除任务 "${task.title}" 吗？`,
    '删除确认',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).then(async () => {
    try {
      await todoStore.deleteTask(task.id)
      emit('task-deleted', task.id)
      ElMessage.success('任务删除成功')
    } catch (error) {
      ElMessage.error('删除任务失败')
    }
  })
}

const handleTaskSaved = async (taskData) => {
  try {
    if (editingTask.value) {
      await todoStore.updateTask(editingTask.value.id, taskData)
      emit('task-updated', { ...taskData, id: editingTask.value.id })
      ElMessage.success('任务更新成功')
    } else {
      const newTask = await todoStore.createTask(props.event.id, taskData)
      emit('task-created', newTask)
      ElMessage.success('任务创建成功')
    }
    
    showCreateTaskDialog.value = false
    editingTask.value = null
  } catch (error) {
    ElMessage.error(editingTask.value ? '更新任务失败' : '创建任务失败')
  }
}

const filterTasks = () => {
  // 筛选任务的逻辑已在计算属性中处理
}

const sortTasks = () => {
  // 排序任务的逻辑已在计算属性中处理
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
  const { t } = useI18n()
  const texts = {
    pending: t('todo.inProgress'),
    completed: t('todo.completed'),
    cancelled: t('todo.cancelled')
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
  const { t } = useI18n()
  const texts = {
    low: t('todo.low'),
    medium: t('todo.medium'),
    high: t('todo.high')
  }
  return texts[priority] || priority
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN')
}

const isOverdue = (task) => {
  if (!task.dueDate || task.status === 'completed') return false
  return new Date(task.dueDate) < new Date()
}

// 组件挂载
onMounted(() => {
  checkMobile()
  window.addEventListener('resize', checkMobile)
})

</script>

<style scoped>
/* 主容器 */
.task-panel {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: var(--bg-surface);
  color: var(--text-primary);
  transition: all var(--transition-normal);
  border-radius: 12px;
  overflow: hidden;
  box-shadow: var(--shadow-light);
}

.task-panel.mobile {
  border-radius: 0;
  height: 100vh;
}

/* 面板头部 */
.panel-header {
  padding: 24px;
  background: var(--bg-primary);
  border-bottom: 1px solid var(--border-light);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  position: relative;
}

.panel-header::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, var(--border-light), transparent);
}

.header-content {
  flex: 1;
  margin-right: 16px;
}

.header-content h2 {
  margin: 0 0 12px 0;
  color: var(--text-primary);
  font-size: 22px;
  font-weight: 700;
  line-height: 1.3;
}

.event-description {
  margin: 0 0 16px 0;
  color: var(--text-secondary);
  font-size: 15px;
  line-height: 1.6;
  opacity: 0.9;
}

.event-stats {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  align-items: center;
}

.event-stats .el-tag {
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
}

.task-count {
  color: var(--text-secondary);
  font-size: 12px;
  font-weight: 500;
}

.close-btn {
  color: var(--text-secondary);
  transition: all var(--transition-normal);
  border-radius: 8px;
}

.close-btn:hover {
  color: var(--text-primary);
  background: var(--bg-surface);
  transform: scale(1.1);
}

/* 进度条部分 */
.progress-section {
  padding: 20px 24px;
  background: var(--bg-surface);
  border-bottom: 1px solid var(--border-light);
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.progress-label {
  color: var(--text-secondary);
  font-size: 14px;
  font-weight: 500;
}

.progress-percentage {
  color: var(--color-primary);
  font-size: 16px;
  font-weight: 700;
}

.progress-container {
  position: relative;
}

.progress-bar {
  height: 8px;
  background: var(--bg-primary);
  border-radius: 4px;
  overflow: hidden;
  position: relative;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--color-primary), var(--color-secondary));
  border-radius: 4px;
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

/* 创建任务按钮 */
.create-task-section {
  padding: 20px 24px;
  border-bottom: 1px solid var(--border-light);
}

.create-task-btn {
  width: 100%;
  height: 50px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 12px;
  position: relative;
  overflow: hidden;
  transition: all var(--transition-normal);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.create-task-btn:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-medium);
}

.create-task-btn:active {
  transform: translateY(0);
}

.btn-icon {
  font-size: 18px;
  transition: transform var(--transition-normal);
}

.create-task-btn:hover .btn-icon {
  transform: rotate(90deg);
}

.btn-ripple {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.3) 0%, transparent 70%);
  opacity: 0;
  transition: opacity var(--transition-fast);
}

.create-task-btn:active .btn-ripple {
  opacity: 1;
}

/* 任务控制区域 */
.tasks-controls {
  padding: 16px 24px;
  background: var(--bg-primary);
  border-bottom: 1px solid var(--border-light);
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
}

.filter-section {
  display: flex;
  gap: 12px;
  align-items: center;
}

.view-toggle .el-button-group {
  border-radius: 8px;
  overflow: hidden;
}

/* 任务列表部分 */
.tasks-section {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.tasks-header {
  padding: 20px 24px 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.tasks-header h3 {
  margin: 0;
  color: var(--text-primary);
  font-size: 18px;
  font-weight: 600;
}

.tasks-count {
  color: var(--text-secondary);
  font-size: 14px;
  font-weight: 500;
  background: var(--bg-primary);
  padding: 4px 12px;
  border-radius: 12px;
}

.tasks-list {
  flex: 1;
  overflow-y: auto;
  padding: 0 24px 24px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.tasks-list.grid-view {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 16px;
}

/* 自定义滚动条 */
.tasks-list::-webkit-scrollbar {
  width: 6px;
}

.tasks-list::-webkit-scrollbar-track {
  background: var(--bg-surface);
  border-radius: 3px;
}

.tasks-list::-webkit-scrollbar-thumb {
  background: var(--border-primary);
  border-radius: 3px;
  transition: background var(--transition-fast);
}

.tasks-list::-webkit-scrollbar-thumb:hover {
  background: var(--color-primary);
}

/* 任务项 */
.task-item {
  background: var(--bg-surface);
  border: 2px solid var(--border-light);
  border-radius: 12px;
  padding: 20px;
  transition: all var(--transition-normal);
  cursor: pointer;
  position: relative;
  overflow: hidden;
}

.task-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: var(--color-primary);
  transform: scaleX(0);
  transition: transform var(--transition-normal);
}

.task-item:hover {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-medium);
  transform: translateY(-2px);
}

.task-item:hover::before {
  transform: scaleX(1);
}

.task-item.completed {
  opacity: 0.7;
  background: rgba(var(--color-success-rgb), 0.05);
  border-color: var(--color-success);
}

.task-item.completed::before {
  background: var(--color-success);
  transform: scaleX(1);
}

.task-item.cancelled {
  opacity: 0.6;
  background: rgba(var(--color-danger-rgb), 0.05);
  border-color: var(--color-danger);
}

.task-item.overdue {
  border-color: var(--color-warning);
  background: rgba(var(--color-warning-rgb), 0.05);
}

.task-item.overdue::before {
  background: var(--color-warning);
  transform: scaleX(1);
}

.task-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
}

.task-main {
  flex: 1;
  display: flex;
  align-items: flex-start;
  gap: 12px;
}

.task-checkbox {
  margin-top: 2px;
  transition: all var(--transition-normal);
}

.task-checkbox:hover {
  transform: scale(1.1);
}

.task-info {
  flex: 1;
  min-width: 0;
}

.task-title {
  margin: 0 0 8px 0;
  color: var(--text-primary);
  font-size: 16px;
  font-weight: 600;
  line-height: 1.4;
  word-break: break-word;
  transition: all var(--transition-normal);
}

.task-item.completed .task-title {
  text-decoration: line-through;
  color: var(--text-secondary);
}

.task-description {
  margin: 0 0 12px 0;
  color: var(--text-secondary);
  font-size: 14px;
  line-height: 1.5;
  word-break: break-word;
}

.task-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.priority-tag,
.status-tag {
  font-size: 11px;
  border-radius: 4px;
  font-weight: 500;
}

.due-date {
  font-size: 12px;
  color: var(--text-secondary);
  display: flex;
  align-items: center;
  gap: 4px;
  font-weight: 500;
}

.due-date.overdue {
  color: var(--color-warning);
  font-weight: 600;
}

.task-actions {
  display: flex;
  gap: 8px;
  opacity: 0;
  transition: opacity var(--transition-normal);
}

.task-item:hover .task-actions {
  opacity: 1;
}

.action-btn {
  padding: 8px;
  border-radius: 8px;
  transition: all var(--transition-normal);
  min-height: auto;
}

.action-btn:hover {
  transform: scale(1.1);
}

.task-progress-indicator {
  position: absolute;
  top: 12px;
  right: 12px;
  width: 24px;
  height: 24px;
  background: var(--color-success);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: bounceIn 0.6s ease-out;
}

.check-icon {
  color: white;
  font-size: 14px;
  font-weight: bold;
}

/* 空状态 */
.empty-tasks {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  text-align: center;
  color: var(--text-secondary);
  min-height: 200px;
}

.empty-icon {
  font-size: 48px;
  color: var(--border-primary);
  margin-bottom: 16px;
  opacity: 0.6;
}

.empty-tasks h3 {
  margin: 0 0 8px 0;
  color: var(--text-primary);
  font-size: 18px;
  font-weight: 600;
}

.empty-tasks p {
  margin: 0;
  font-size: 14px;
  line-height: 1.5;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .panel-header {
    padding: 16px;
  }
  
  .header-content h2 {
    font-size: 20px;
  }
  
  .progress-section,
  .create-task-section {
    padding: 16px;
  }
  
  .tasks-controls {
    padding: 12px 16px;
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .filter-section {
    justify-content: space-between;
  }
  
  .tasks-header {
    padding: 16px;
  }
  
  .tasks-list {
    padding: 0 16px 16px;
  }
  
  .tasks-list.grid-view {
    grid-template-columns: 1fr;
  }
  
  .task-item {
    padding: 16px;
  }
  
  .task-actions {
    opacity: 1;
  }
}

@media (max-width: 480px) {
  .task-content {
    flex-direction: column;
    gap: 12px;
  }
  
  .task-actions {
    align-self: flex-end;
  }
  
  .task-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 6px;
  }
}

/* 动画效果 */
.animate-fade-in {
  animation: fadeIn 0.6s ease-out;
}

.animate-fade-in-delay {
  animation: fadeIn 0.6s ease-out 0.2s backwards;
}

.animate-slide-in-up {
  animation: slideInUp 0.6s ease-out;
}

.animate-task-enter {
  animation: taskEnter 0.4s ease-out;
}

.animate-status-change {
  animation: statusChange 0.6s ease-out;
}

.task-list-enter-active,
.task-list-leave-active {
  transition: all var(--transition-normal);
}

.task-list-enter-from {
  opacity: 0;
  transform: translateY(-20px);
}

.task-list-leave-to {
  opacity: 0;
  transform: translateY(20px);
}

.task-list-move {
  transition: transform var(--transition-normal);
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes slideInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes taskEnter {
  from {
    opacity: 0;
    transform: scale(0.9) translateY(10px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

@keyframes statusChange {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
}

@keyframes bounceIn {
  0% {
    opacity: 0;
    transform: scale(0.3);
  }
  50% {
    opacity: 1;
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

@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

/* Element Plus 主题覆盖 */
:deep(.el-button) {
  border-radius: 8px;
  transition: all var(--transition-normal);
}

:deep(.el-button:hover) {
  transform: translateY(-1px);
}

:deep(.el-select) {
  border-radius: 8px;
}

:deep(.el-tag) {
  border-radius: 6px;
  transition: all var(--transition-normal);
}

:deep(.el-checkbox) {
  transition: all var(--transition-normal);
}

:deep(.el-checkbox__input.is-checked .el-checkbox__inner) {
  background: var(--color-primary);
  border-color: var(--color-primary);
}
</style>