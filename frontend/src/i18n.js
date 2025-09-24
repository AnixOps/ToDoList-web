import { createI18n } from 'vue-i18n'
import en from './locales/en.js'
import zhCN from './locales/zh-cn.js'  
import zhTW from './locales/zh-tw.js'

// 支持的语言列表
export const SUPPORTED_LOCALES = {
  'en': { name: 'English', nativeName: 'English' },
  'zh-cn': { name: 'Simplified Chinese', nativeName: '简体中文' },
  'zh-tw': { name: 'Traditional Chinese', nativeName: '繁體中文' }
}

// 语言检测函数
function detectBrowserLanguage() {
  // 获取浏览器语言设置
  const browserLang = navigator.language || navigator.userLanguage
  const langCode = browserLang.toLowerCase()
  
  console.log('Browser language detected:', browserLang)
  
  // 检测简体中文
  if (langCode.includes('zh-cn') || 
      langCode.includes('zh-hans') || 
      langCode === 'zh' || 
      langCode === 'cn') {
    return 'zh-cn'
  }
  
  // 检测繁体中文
  if (langCode.includes('zh-tw') || 
      langCode.includes('zh-hk') || 
      langCode.includes('zh-mo') || 
      langCode.includes('zh-hant')) {
    return 'zh-tw'
  }
  
  // 检测中文但无法确定简繁，查看更详细的navigator.languages
  if (langCode.startsWith('zh')) {
    const languages = navigator.languages || [browserLang]
    for (const lang of languages) {
      const code = lang.toLowerCase()
      if (code.includes('cn') || code.includes('hans')) {
        return 'zh-cn'
      }
      if (code.includes('tw') || code.includes('hk') || code.includes('mo') || code.includes('hant')) {
        return 'zh-tw'
      }
    }
    // 默认简体中文
    return 'zh-cn'
  }
  
  // 其他语言默认英文
  return 'en'
}

// 获取用户设置的语言或自动检测
function getInitialLocale() {
  // 先检查本地存储
  const savedLocale = localStorage.getItem('user-locale')
  if (savedLocale && SUPPORTED_LOCALES[savedLocale]) {
    console.log('Using saved locale:', savedLocale)
    return savedLocale
  }
  
  // 自动检测浏览器语言
  const detectedLocale = detectBrowserLanguage()
  console.log('Auto-detected locale:', detectedLocale)
  
  // 保存检测到的语言
  localStorage.setItem('user-locale', detectedLocale)
  
  return detectedLocale
}

// 消息对象
const messages = {
  en,
  'zh-cn': zhCN,
  'zh-tw': zhTW
}

// 创建i18n实例
const i18n = createI18n({
  legacy: false, // 使用Composition API模式
  locale: getInitialLocale(),
  fallbackLocale: 'en',
  messages,
  globalInjection: true, // 全局注入$t
  silentTranslationWarn: true, // 静默翻译警告
})

// 切换语言函数
export function setLocale(locale) {
  if (SUPPORTED_LOCALES[locale]) {
    i18n.global.locale.value = locale
    localStorage.setItem('user-locale', locale)
    console.log('Locale changed to:', locale)
    
    // 更新HTML lang属性
    document.querySelector('html').setAttribute('lang', locale)
    
    return locale
  }
  return i18n.global.locale.value
}

// 获取当前语言
export function getCurrentLocale() {
  return i18n.global.locale.value
}

// 获取语言显示名称
export function getLocaleDisplayName(locale) {
  return SUPPORTED_LOCALES[locale]?.nativeName || locale
}

// 初始化HTML lang属性
document.querySelector('html').setAttribute('lang', getInitialLocale())

export default i18n