# 📦 构建系统文档索引

## 🎯 快速导航

### 新用户（5分钟快速开始）
👉 **[BUILD_QUICK_START.md](BUILD_QUICK_START.md)**
- 最简洁的构建指南
- 三步完成构建
- 适合快速上手

### 发布到 Google Play（完整流程）
👉 **[GOOGLE_PLAY_RELEASE.md](GOOGLE_PLAY_RELEASE.md)**
- 从零到发布的完整指南
- 包含密钥生成、签名配置、测试、上传等所有步骤
- 包含常见问题解答
- 适合首次发布应用

### 环境变量配置
👉 **[ENV_CONFIG.md](ENV_CONFIG.md)**
- .env 文件使用说明
- 环境变量完整列表
- 多环境配置方法

---

## 🛠️ 构建脚本

### 1. `check_build_env.ps1` - 环境检查
```powershell
.\check_build_env.ps1
```
**功能**：
- 检查 Flutter、Java、Android SDK 是否安装
- 验证项目配置文件
- 检查签名配置
- 提供问题解决建议

**使用场景**：
- 首次构建前检查环境
- 构建失败时排查问题
- 验证配置是否正确

---

### 2. `generate_keystore.ps1` - 密钥生成
```powershell
.\generate_keystore.ps1
```
**功能**：
- 交互式生成 Android 签名密钥库
- 自动创建 key.properties 配置文件
- 提供密钥信息和备份提醒

**使用场景**：
- 首次构建发布版本
- 密钥丢失需要重新生成（注意：会导致无法更新已发布的应用）

**生成文件**：
- `android/upload-keystore.jks` - 密钥库文件
- `android/key.properties` - 签名配置

⚠️ **重要**：这两个文件需要妥善备份，不要提交到 Git！

---

### 3. `build_android.ps1` - Android 构建
```powershell
# 基本用法
.\build_android.ps1

# 高级用法
.\build_android.ps1 -Type apk          # 构建 APK
.\build_android.ps1 -Type both         # 同时构建 APK 和 AAB
.\build_android.ps1 -Clean             # 构建前清理
.\build_android.ps1 -Flavor development # 构建开发版本
.\build_android.ps1 -Help              # 显示帮助
```

**功能**：
- 自动化 Android 应用构建流程
- 支持 APK 和 AAB 格式
- 支持多产品风味（production/development）
- 自动检查环境和配置
- 显示详细的构建进度和结果

**输出位置**：
- AAB: `build/app/outputs/bundle/[flavor]Release/`
- APK: `build/app/outputs/flutter-apk/`

**使用场景**：
- 构建 Google Play 发布包（AAB）
- 构建测试用 APK
- 构建不同环境的版本

---

### 4. `run_dev.ps1` - 开发环境运行
```powershell
.\run_dev.ps1
```

**功能**：
- 检查 .env 配置
- 在 Chrome 浏览器中运行开发版本

**使用场景**：
- 日常开发和测试
- 快速验证功能

---

### 5. `run_prod.ps1` - 生产环境运行
```powershell
.\run_prod.ps1
```

**功能**：
- 自动切换到生产环境配置
- 在 Chrome 浏览器中运行生产版本
- 运行后自动恢复之前的配置

**使用场景**：
- 测试生产环境配置
- 验证生产环境 API 连接

---

## 📁 配置文件

### 1. `.env` - 环境变量配置
```env
ENVIRONMENT=development
DEV_API_URL=http://localhost:8080/api/v1
PROD_API_URL=https://api.todolist.com/api/v1
...
```

**说明**：
- 实际使用的配置文件
- **已添加到 .gitignore**，不会被提交
- 从 `.env.example` 复制并修改

---

### 2. `.env.example` - 配置模板
**说明**：
- 配置文件模板
- **应该提交到 Git**
- 新成员根据此文件创建自己的 .env

---

### 3. `.env.production` - 生产环境配置示例
**说明**：
- 生产环境配置示例
- 可以复制为 .env 使用

---

### 4. `android/key.properties` - Android 签名配置
```properties
storeFile=upload-keystore.jks
storePassword=your_password
keyAlias=upload
keyPassword=your_password
```

**说明**：
- Android 应用签名配置
- **已添加到 .gitignore**
- 由 `generate_keystore.ps1` 自动生成
- 从 `key.properties.example` 复制并修改

---

### 5. `android/key.properties.example` - 签名配置模板
**说明**：
- 签名配置模板文件
- 说明各配置项的含义

---

### 6. `android/upload-keystore.jks` - 密钥库文件
**说明**：
- Android 应用签名密钥
- **已添加到 .gitignore**
- 由 `generate_keystore.ps1` 生成
- ⚠️ **必须妥善备份，丢失将无法更新应用！**

---

### 7. `android/app/proguard-rules.pro` - 代码混淆规则
**说明**：
- ProGuard 代码混淆和优化规则
- 用于发布版本，减小应用体积
- 保护代码不被反编译

---

## 📊 构建流程图

```
开始
  ↓
[检查环境] ← check_build_env.ps1
  ↓
[是否有密钥?] → 否 → [生成密钥] ← generate_keystore.ps1
  ↓ 是
[配置 .env]
  ↓
[构建应用] ← build_android.ps1
  ↓
[生成 AAB/APK]
  ↓
[本地测试]
  ↓
[上传 Google Play] ← GOOGLE_PLAY_RELEASE.md
  ↓
完成
```

---

## 🎯 常见任务快速参考

### 首次构建
```powershell
# 1. 检查环境
.\check_build_env.ps1

# 2. 生成密钥
.\generate_keystore.ps1

# 3. 配置环境变量
Copy-Item .env.example .env
# 编辑 .env 文件

# 4. 构建
.\build_android.ps1
```

---

### 日常开发
```powershell
# 运行开发版本
.\run_dev.ps1

# 或直接运行
flutter run -d chrome
```

---

### 发布新版本
```powershell
# 1. 更新版本号（android/app/build.gradle.kts）
versionCode = 2
versionName = "1.0.1"

# 2. 清理构建
.\build_android.ps1 -Clean

# 3. 上传到 Google Play
# 参考 GOOGLE_PLAY_RELEASE.md
```

---

### 故障排除
```powershell
# 检查环境
.\check_build_env.ps1

# 清理项目
flutter clean
flutter pub get

# 重新构建
.\build_android.ps1 -Clean
```

---

## 📚 文档结构

```
todolist_mobile/
├── BUILD_QUICK_START.md         ← 5分钟快速入门
├── GOOGLE_PLAY_RELEASE.md       ← Google Play 完整发布指南
├── ENV_CONFIG.md                ← 环境变量配置说明
├── BUILD_INDEX.md               ← 本文档（总索引）
├── README.md                    ← 项目说明
│
├── check_build_env.ps1          ← 环境检查脚本
├── generate_keystore.ps1        ← 密钥生成脚本
├── build_android.ps1            ← Android 构建脚本
├── run_dev.ps1                  ← 开发环境运行
├── run_prod.ps1                 ← 生产环境运行
│
├── .env                         ← 环境配置（不提交）
├── .env.example                 ← 配置模板（提交）
├── .env.production              ← 生产配置示例
│
└── android/
    ├── key.properties           ← 签名配置（不提交）
    ├── key.properties.example   ← 签名配置模板（提交）
    ├── upload-keystore.jks      ← 密钥库文件（不提交）
    └── app/
        ├── build.gradle.kts     ← Android 构建配置
        └── proguard-rules.pro   ← 代码混淆规则
```

---

## ⚡ 快捷命令

```powershell
# 检查环境
.\check_build_env.ps1

# 生成密钥
.\generate_keystore.ps1

# 构建发布包
.\build_android.ps1

# 构建测试 APK
.\build_android.ps1 -Type apk

# 清理重建
.\build_android.ps1 -Clean

# 开发运行
.\run_dev.ps1

# 生产测试
.\run_prod.ps1
```

---

## 🆘 需要帮助？

1. **快速开始**：查看 [BUILD_QUICK_START.md](BUILD_QUICK_START.md)
2. **详细步骤**：查看 [GOOGLE_PLAY_RELEASE.md](GOOGLE_PLAY_RELEASE.md)
3. **配置问题**：查看 [ENV_CONFIG.md](ENV_CONFIG.md)
4. **环境问题**：运行 `.\check_build_env.ps1`
5. **构建帮助**：运行 `.\build_android.ps1 -Help`

---

## ✅ 检查清单

发布前确认：

- [ ] 已生成并备份密钥库文件
- [ ] 已配置 .env 文件
- [ ] 已修改应用 ID（不使用示例包名）
- [ ] 已更新版本号
- [ ] 已测试所有功能
- [ ] 已准备好截图和图标
- [ ] 已阅读 Google Play 政策
- [ ] 已准备好隐私政策

---

**祝你构建顺利！** 🎉
