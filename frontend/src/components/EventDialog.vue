<template>
  <el-dialog
    :model-value="modelValue"
    :title="event ? $t('event.editEvent') : $t('event.createEvent')"
    width="500px"
    @update:model-value="$emit('update:modelValue', $event)"
  >
    <el-form
      ref="formRef"
      :model="form"
      :rules="rules"
      label-width="80px"
    >
      <el-form-item :label="$t('event.eventName')" prop="title">
        <el-input
          v-model="form.title"
          :placeholder="$t('event.eventName')"
          clearable
        />
      </el-form-item>
      
      <el-form-item :label="$t('event.eventDescription')">
        <el-input
          v-model="form.description"
          type="textarea"
          :rows="3"
          :placeholder="$t('event.eventDescription')"
        />
      </el-form-item>
      
      <el-form-item :label="$t('todo.priority')">
        <el-select v-model="form.priority" :placeholder="$t('todo.priority')">
          <el-option :label="$t('todo.low')" value="low" />
          <el-option :label="$t('todo.medium')" value="medium" />
          <el-option :label="$t('todo.high')" value="high" />
        </el-select>
      </el-form-item>
      
      <el-form-item v-if="event" :label="$t('todo.status')">
        <el-select v-model="form.status" :placeholder="$t('todo.status')">
          <el-option :label="$t('todo.inProgress')" value="pending" />
          <el-option :label="$t('todo.completed')" value="completed" />
          <el-option :label="$t('todo.cancelled')" value="cancelled" />
        </el-select>
      </el-form-item>
      
      <el-form-item :label="$t('todo.dueDate')">
        <el-date-picker
          v-model="form.dueDate"
          type="datetime"
          :placeholder="$t('todo.dueDate')"
          format="YYYY-MM-DD HH:mm"
          value-format="YYYY-MM-DDTHH:mm:ss.sssZ"
          clearable
        />
      </el-form-item>
    </el-form>
    
    <template #footer>
      <el-button @click="$emit('update:modelValue', false)">
        {{ $t('common.cancel') }}
      </el-button>
      <el-button type="primary" @click="handleSave" :loading="saving">
        {{ event ? $t('common.edit') : $t('common.add') }}
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, watch, computed } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const props = defineProps({
  modelValue: Boolean,
  event: Object
})

const emit = defineEmits(['update:modelValue', 'event-saved'])

const formRef = ref()
const saving = ref(false)

const form = reactive({
  title: '',
  description: '',
  priority: 'medium',
  status: 'pending',
  dueDate: null
})

const rules = computed(() => ({
  title: [
    { required: true, message: t('event.eventName'), trigger: 'blur' },
    { max: 200, message: '标题长度不能超过200个字符', trigger: 'blur' }
  ]
}))

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
      const eventData = { ...form }
      
      // 处理日期格式
      if (eventData.dueDate) {
        eventData.dueDate = new Date(eventData.dueDate).toISOString()
      }
      
      emit('event-saved', eventData)
    } finally {
      saving.value = false
    }
  })
}

// 监听事件变化，填充表单
watch(() => props.event, (newEvent) => {
  if (newEvent) {
    Object.assign(form, {
      title: newEvent.title || '',
      description: newEvent.description || '',
      priority: newEvent.priority || 'medium',
      status: newEvent.status || 'pending',
      dueDate: newEvent.dueDate ? new Date(newEvent.dueDate).toISOString() : null
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