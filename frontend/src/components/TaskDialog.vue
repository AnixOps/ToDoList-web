<template>
  <el-dialog
    :model-value="modelValue"
    :title="task ? '编辑任务' : '创建新任务'"
    width="500px"
    @update:model-value="$emit('update:modelValue', $event)"
  >
    <el-form
      ref="formRef"
      :model="form"
      :rules="rules"
      label-width="80px"
    >
      <el-form-item label="标题" prop="title">
        <el-input
          v-model="form.title"
          placeholder="请输入任务标题"
          clearable
        />
      </el-form-item>
      
      <el-form-item label="描述">
        <el-input
          v-model="form.description"
          type="textarea"
          :rows="3"
          placeholder="请输入任务描述（可选）"
        />
      </el-form-item>
      
      <el-form-item label="优先级">
        <el-select v-model="form.priority" placeholder="选择优先级">
          <el-option label="低" value="low" />
          <el-option label="中" value="medium" />
          <el-option label="高" value="high" />
        </el-select>
      </el-form-item>
      
      <el-form-item v-if="task" label="状态">
        <el-select v-model="form.status" placeholder="选择状态">
          <el-option label="待完成" value="pending" />
          <el-option label="已完成" value="completed" />
          <el-option label="已取消" value="cancelled" />
        </el-select>
      </el-form-item>
      
      <el-form-item label="截止日期">
        <el-date-picker
          v-model="form.dueDate"
          type="datetime"
          placeholder="选择截止日期（可选）"
          format="YYYY-MM-DD HH:mm"
          value-format="YYYY-MM-DDTHH:mm:ss.sssZ"
          clearable
        />
      </el-form-item>
    </el-form>
    
    <template #footer>
      <el-button @click="$emit('update:modelValue', false)">
        取消
      </el-button>
      <el-button type="primary" @click="handleSave" :loading="saving">
        {{ task ? '更新' : '创建' }}
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, watch } from 'vue'

const props = defineProps({
  modelValue: Boolean,
  task: Object
})

const emit = defineEmits(['update:modelValue', 'task-saved'])

const formRef = ref()
const saving = ref(false)

const form = reactive({
  title: '',
  description: '',
  priority: 'medium',
  status: 'pending',
  dueDate: null
})

const rules = {
  title: [
    { required: true, message: '请输入任务标题', trigger: 'blur' },
    { max: 200, message: '标题长度不能超过200个字符', trigger: 'blur' }
  ]
}

const resetForm = () => {
  Object.assign(form, {
    title: '',
    description: '',
    priority: 'medium',
    status: 'pending',
    dueDate: null
  })
  
  if (formRef.value) {
    formRef.value.clearValidate()
  }
}

const handleSave = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    
    saving.value = true
    try {
      const taskData = { ...form }
      
      // 处理日期格式
      if (taskData.dueDate) {
        taskData.dueDate = new Date(taskData.dueDate).toISOString()
      }
      
      emit('task-saved', taskData)
    } finally {
      saving.value = false
    }
  })
}

// 监听任务变化，填充表单
watch(() => props.task, (newTask) => {
  if (newTask) {
    Object.assign(form, {
      title: newTask.title || '',
      description: newTask.description || '',
      priority: newTask.priority || 'medium',
      status: newTask.status || 'pending',
      dueDate: newTask.dueDate ? new Date(newTask.dueDate).toISOString() : null
    })
  } else {
    resetForm()
  }
}, { immediate: true })

// 监听对话框显示/隐藏
watch(() => props.modelValue, (show) => {
  if (!show) {
    resetForm()
  }
})
</script>