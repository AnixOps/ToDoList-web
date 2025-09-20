<template>
  <div class="login-container">
    <el-card class="login-card">
      <template #header>
        <div class="card-header">
          <h1>登录</h1>
          <p>欢迎回到 ToDoList</p>
        </div>
      </template>
      
      <el-form
        ref="loginFormRef"
        :model="loginForm"
        :rules="loginRules"
        label-width="0"
        size="large"
      >
        <el-form-item prop="username">
          <el-input
            v-model="loginForm.username"
            placeholder="用户名"
            prefix-icon="User"
            clearable
          />
        </el-form-item>
        
        <el-form-item prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            placeholder="密码"
            prefix-icon="Lock"
            show-password
            clearable
            @keyup.enter="handleLogin"
          />
        </el-form-item>
        
        <el-form-item>
          <el-button
            type="primary"
            size="large"
            style="width: 100%"
            :loading="loading"
            @click="handleLogin"
          >
            登录
          </el-button>
        </el-form-item>
      </el-form>
      
      <div class="login-footer">
        <el-divider>或</el-divider>
        <el-button
          type="success"
          size="large"
          style="width: 100%"
          @click="goToRegister"
        >
          注册新账号
        </el-button>
        
        <el-divider />
        
        <el-button
          type="info"
          size="large"
          style="width: 100%"
          @click="useOfflineMode"
        >
          使用离线模式
        </el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const loginFormRef = ref()
const loading = ref(false)

const loginForm = reactive({
  username: '',
  password: ''
})

const loginRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 50, message: '用户名长度在 3 到 50 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于 6 个字符', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  await loginFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    loading.value = true
    try {
      await authStore.login(loginForm)
      ElMessage.success('登录成功')
      router.push('/todo')
    } catch (error) {
      ElMessage.error(error.error || '登录失败')
    } finally {
      loading.value = false
    }
  })
}

const goToRegister = () => {
  router.push('/register')
}

const useOfflineMode = () => {
  ElMessage.info('已切换到离线模式')
  router.push('/todo')
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-card {
  width: 100%;
  max-width: 400px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border-radius: 16px;
}

.card-header {
  text-align: center;
  margin-bottom: 20px;
}

.card-header h1 {
  margin: 0 0 8px 0;
  color: #303133;
  font-size: 28px;
  font-weight: 600;
}

.card-header p {
  margin: 0;
  color: #909399;
  font-size: 14px;
}

.login-footer {
  margin-top: 20px;
}

:deep(.el-divider__text) {
  color: #909399;
  font-size: 12px;
}
</style>