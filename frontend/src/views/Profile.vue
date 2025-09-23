<template>
  <div class="profile-container">
    <div class="profile-header">
      <el-button
        type="text"
        @click="$router.back()"
      >
        <el-icon><ArrowLeft /></el-icon>
        返回
      </el-button>
      <h1>{{ $t('user.personalSettings') }}</h1>
    </div>

    <div class="profile-content">
      <el-card>
        <template #header>
          <div class="card-header">
            <span>用户信息</span>
          </div>
        </template>
        
        <el-descriptions :column="1" border>
          <el-descriptions-item label="用户名">
            {{ user?.username }}
          </el-descriptions-item>
          <el-descriptions-item label="邮箱">
            {{ user?.email }}
          </el-descriptions-item>
          <el-descriptions-item label="注册时间">
            {{ formatDate(user?.created_at) }}
          </el-descriptions-item>
        </el-descriptions>
      </el-card>

      <el-card style="margin-top: 20px;">
        <template #header>
          <div class="card-header">
            <span>数据管理</span>
          </div>
        </template>
        
        <div class="data-actions">
          <el-button
            type="primary"
            @click="exportData"
          >
            <el-icon><Download /></el-icon>
            导出数据
          </el-button>
          
          <el-button
            type="success"
            @click="importData"
          >
            <el-icon><Upload /></el-icon>
            导入数据
          </el-button>
          
          <el-button
            type="danger"
            @click="clearDataConfirm"
          >
            <el-icon><Delete /></el-icon>
            清空数据
          </el-button>
        </div>
      </el-card>

      <el-card style="margin-top: 20px;">
        <template #header>
          <div class="card-header">
            <span>账号操作</span>
          </div>
        </template>
        
        <div class="account-actions">
          <el-button
            type="warning"
            @click="logout"
          >
            <el-icon><SwitchButton /></el-icon>
            {{ $t('user.logout') }}
          </el-button>
        </div>
      </el-card>
    </div>

    <!-- 导入数据对话框 -->
    <el-dialog
      v-model="showImportDialog"
      title="导入数据"
      width="400px"
    >
      <el-upload
        drag
        :auto-upload="false"
        :limit="1"
        accept=".json"
        @change="handleFileChange"
      >
        <el-icon class="el-icon--upload"><upload-filled /></el-icon>
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
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '@/stores/auth'
import { useTodoStore } from '@/stores/todo'

const { t } = useI18n()

const router = useRouter()
const authStore = useAuthStore()
const todoStore = useTodoStore()

const showImportDialog = ref(false)
const importFile = ref(null)

const user = computed(() => authStore.user)

const logout = () => {
  authStore.logout()
  todoStore.toggleMode()
  ElMessage.success(t('user.logoutSuccess'))
  router.push('/login')
}

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
    
    ElMessage.success('数据导入成功')
  } catch (error) {
    ElMessage.error('导入数据失败：' + error.message)
  }
}

const clearDataConfirm = () => {
  ElMessageBox.confirm(
    '确定要清空所有数据吗？此操作不可恢复！',
    '清空数据确认',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).then(async () => {
    try {
      await todoStore.importOfflineData({ events: [], tasks: [] })
      ElMessage.success('数据清空成功')
    } catch (error) {
      ElMessage.error('清空数据失败')
    }
  })
}

const formatDate = (dateString) => {
  if (!dateString) return '未知'
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN')
}
</script>

<style scoped>
.profile-container {
  min-height: 100vh;
  background: #f5f5f5;
}

.profile-header {
  background: white;
  padding: 16px 24px;
  border-bottom: 1px solid #ebeef5;
  display: flex;
  align-items: center;
  gap: 16px;
}

.profile-header h1 {
  margin: 0;
  color: #303133;
  font-size: 20px;
  font-weight: 600;
}

.profile-content {
  max-width: 800px;
  margin: 0 auto;
  padding: 24px;
}

.card-header {
  font-weight: 600;
}

.data-actions,
.account-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

@media (max-width: 768px) {
  .profile-content {
    padding: 16px;
  }
  
  .data-actions,
  .account-actions {
    flex-direction: column;
  }
  
  .data-actions .el-button,
  .account-actions .el-button {
    width: 100%;
  }
}
</style>