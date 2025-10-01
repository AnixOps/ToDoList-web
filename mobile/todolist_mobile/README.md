# 🚀 快速开始指南

## 第一步：安装Flutter

### Windows安装Flutter：

1. **下载Flutter SDK**
   - 访问：https://flutter.dev/docs/get-started/install/windows
   - 下载稳定版本的zip文件

2. **解压并设置环境变量**
   ```
   解压到：C:\flutter
   添加到PATH：C:\flutter\bin
   ```

3. **验证安装**
   ```bash
   flutter doctor
   ```

## 第二步：运行项目

```bash
# 进入项目目录
cd todolist_mobile

# 安装依赖
flutter pub get

# 在Chrome浏览器中运行（推荐用于开发）
flutter run -d chrome

# 或在Android/iOS模拟器中运行
flutter run
```

## 第三步：配置API

编辑 `lib/utils/constants.dart` 文件：

```dart
static const String baseUrl = 'https://your-actual-api-domain.com/api/v1';
```

## 项目结构

```
todolist_mobile/
├── lib/
│   ├── main.dart          # 应用入口
│   ├── models/            # 数据模型
│   ├── services/          # API服务
│   ├── providers/         # 状态管理
│   ├── screens/           # 页面
│   ├── widgets/           # 组件
│   └── utils/             # 工具类
└── pubspec.yaml           # 依赖配置
```

## 主要功能

- ✅ 用户认证（登录/注册）
- ✅ 任务管理（事件和子任务）
- ✅ 云端API对接
- ✅ iOS/Android跨平台支持
- ✅ 离线模式支持
- ✅ 多语言支持（中文/英文）
- ✅ Material Design 3 UI

## 📦 构建和发布

### 快速构建

```powershell
# 生成签名密钥（首次）
.\generate_keystore.ps1

# 构建 Google Play 发布包 (AAB)
.\build_android.ps1

# 构建 APK 用于测试
.\build_android.ps1 -Type apk
```

### 📚 详细文档

- **🚀 快速入门**：[BUILD_QUICK_START.md](BUILD_QUICK_START.md) - 5分钟快速上手
- **📖 完整指南**：[GOOGLE_PLAY_RELEASE.md](GOOGLE_PLAY_RELEASE.md) - Google Play 发布完整流程
- **⚙️ 环境配置**：[ENV_CONFIG.md](ENV_CONFIG.md) - .env 环境变量配置

### 构建脚本

- `generate_keystore.ps1` - 生成签名密钥
- `build_android.ps1` - Android 构建脚本
- `run_dev.ps1` - 开发环境运行
- `run_prod.ps1` - 生产环境运行

## ⚙️ 环境配置

项目使用 `.env` 文件管理环境变量：

```powershell
# 首次运行，复制配置文件
Copy-Item .env.example .env

# 编辑 .env 配置你的 API 地址
```

详见：[ENV_CONFIG.md](ENV_CONFIG.md)

## 开发提示

- 使用VS Code + Flutter插件获得最佳开发体验
- 按 `r` 键热重载，按 `R` 键热重启
- 首次运行Chrome版本进行UI测试
- 配置好API后测试完整功能
- 构建前确保已配置 `.env` 文件