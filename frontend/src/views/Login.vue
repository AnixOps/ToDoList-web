<template>
  <div class="login-container">
    <!-- 语言选择器 -->
    <div class="language-selector-container">
      <LanguageSelector />
    </div>
    
    <el-card class="login-card">
      <template #header>
        <div class="card-header">
          <h1>{{ $t('auth.login') }}</h1>
          <p>{{ $t('common.login') }} ToDoList</p>
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
            :placeholder="$t('auth.username')"
            prefix-icon="User"
            clearable
          />
        </el-form-item>
        
        <el-form-item prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            :placeholder="$t('auth.password')"
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
            {{ $t('auth.loginBtn') }}
          </el-button>
        </el-form-item>
      </el-form>
      
      <div class="login-footer">
        <el-divider>{{ $t('common.or') || '或' }}</el-divider>
        <el-button
          type="success"
          size="large"
          style="width: 100%"
          @click="goToRegister"
        >
          {{ $t('auth.registerBtn') }}
        </el-button>
        
        <el-divider />
        
        <el-button
          type="info"
          size="large"
          style="width: 100%"
          @click="useOfflineMode"
        >
          {{ $t('common.offlineMode') || '使用离线模式' }}
        </el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import LanguageSelector from '@/components/LanguageSelector.vue'

const { t } = useI18n()
const router = useRouter()
const authStore = useAuthStore()

const loginFormRef = ref()
const loading = ref(false)

const loginForm = reactive({
  username: '',
  password: ''
})

const loginRules = computed(() => ({
  username: [
    { required: true, message: t('auth.usernameRequired'), trigger: 'blur' },
    { min: 3, max: 50, message: t('auth.usernameLengthError') || '用户名长度在 3 到 50 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: t('auth.passwordRequired'), trigger: 'blur' },
    { min: 6, message: t('auth.passwordLengthError') || '密码长度不能少于 6 个字符', trigger: 'blur' }
  ]
}))

const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  await loginFormRef.value.validate(async (valid) => {
    if (!valid) return
    
    loading.value = true
    try {
      await authStore.login(loginForm)
      ElMessage.success(t('auth.loginSuccess'))
      router.push('/todo')
    } catch (error) {
      ElMessage.error(error.error || t('auth.loginFailed'))
    } finally {
      loading.value = false
    }
  })
}

const goToRegister = () => {
  router.push('/register')
}

const useOfflineMode = () => {
  ElMessage.info(t('common.offlineModeEnabled') || '已切换到离线模式')
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
  position: relative;
}

.language-selector-container {
  position: absolute;
  top: 20px;
  right: 20px;
  z-index: 10;
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