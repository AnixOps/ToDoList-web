# 🚀 快速构建和发布指南

> 5 分钟快速上手 Android 应用构建和 Google Play 发布

## 📋 快速检查清单

开始前确保：

- [x] ✅ Flutter 已安装：`flutter doctor`
- [x] ✅ Android SDK 已配置
- [x] ✅ Java JDK 已安装：`java -version`

## 🎯 三步完成构建

### 步骤 1：生成签名密钥（首次）

```powershell
# 运行密钥生成脚本
.\generate_keystore.ps1
```

按提示输入：
- 密码（记住它！）
- 你的名字/公司名
- 其他信息（可直接回车使用默认值）

**⚠️ 重要**：备份生成的文件：
- `android/upload-keystore.jks`
- `android/key.properties`

### 步骤 2：修改应用信息

编辑 `android/app/build.gradle.kts`：

```kotlin
applicationId = "com.yourcompany.todolist"  // 改成你的包名
versionCode = 1                              // 首次发布用 1
versionName = "1.0.0"                        // 版本号
```

编辑 `android/app/src/main/AndroidManifest.xml`：

```xml
android:label="你的应用名称"
```

### 步骤 3：构建

```powershell
# 构建 Google Play 发布包
.\build_android.ps1

# 或构建 APK 用于测试
.\build_android.ps1 -Type apk
```

**输出位置**：
- AAB: `build/app/outputs/bundle/productionRelease/`
- APK: `build/app/outputs/flutter-apk/`

## 🧪 本地测试

```powershell
# 安装 APK 到设备
adb install build/app/outputs/flutter-apk/app-production-arm64-v8a-release.apk

# 或使用脚本测试
flutter run --release
```

## 📤 上传到 Google Play

1. **登录** [Google Play Console](https://play.google.com/console)

2. **创建应用**
   - 应用名称：ToDoList
   - 类型：应用
   - 免费/付费：免费

3. **上传 AAB**
   - 进入"发布" → "生产"
   - 创建新版本
   - 上传 `app-production-release.aab`

4. **填写商店信息**
   - 应用描述
   - 截图（2-8 张）
   - 应用图标（512x512）
   - 功能图片（1024x500）

5. **提交审核**
   - 内部测试 → 封闭测试 → 生产发布

## 🔄 后续更新

1. 修改版本号：
   ```kotlin
   versionCode = 2       // 递增
   versionName = "1.0.1"
   ```

2. 重新构建：
   ```powershell
   .\build_android.ps1
   ```

3. 上传新版本到 Google Play

## 📚 详细文档

- **完整发布流程**：[GOOGLE_PLAY_RELEASE.md](GOOGLE_PLAY_RELEASE.md)
- **环境变量配置**：[ENV_CONFIG.md](ENV_CONFIG.md)
- **构建脚本说明**：`.\build_android.ps1 -Help`

## 🆘 常见问题

### 构建失败？

```powershell
# 清理后重新构建
.\build_android.ps1 -Clean
```

### 签名错误？

```powershell
# 检查配置
Test-Path android\key.properties
Test-Path android\upload-keystore.jks
```

### 版本冲突？

增加 `versionCode` 的值（必须大于之前的版本）

## 🎉 完成！

现在你可以：
- ✅ 构建 Android 应用
- ✅ 生成签名的 APK/AAB
- ✅ 发布到 Google Play

需要详细说明？查看 [GOOGLE_PLAY_RELEASE.md](GOOGLE_PLAY_RELEASE.md)
