# 环境变量配置说明

## 📋 概述

本项目使用 `.env` 文件来管理环境变量，包括 API 地址、功能开关等配置。

## 🚀 快速开始

### 1. 创建环境配置文件

首次使用时，复制 `.env.example` 文件为 `.env`：

```bash
# Windows PowerShell
Copy-Item .env.example .env

# Linux/MacOS
cp .env.example .env
```

### 2. 修改配置

在 `.env` 文件中修改你的配置：

```env
# 开发环境
ENVIRONMENT=development
DEV_API_URL=http://localhost:8080/api/v1

# 生产环境
PROD_API_URL=https://your-production-api.com/api/v1
```

### 3. 安装依赖

```bash
flutter pub get
```

### 4. 运行应用

```bash
# 开发环境
flutter run

# 生产环境（需要先在 .env 中设置 ENVIRONMENT=production）
flutter run
```

## 📝 配置项说明

### 必需配置

| 配置项 | 说明 | 默认值 | 示例 |
|--------|------|--------|------|
| `ENVIRONMENT` | 应用环境 | `development` | `development` 或 `production` |
| `DEV_API_URL` | 开发环境 API 地址 | `http://localhost:8080/api/v1` | `http://192.168.1.100:8080/api/v1` |
| `PROD_API_URL` | 生产环境 API 地址 | `https://api.todolist.com/api/v1` | `https://your-api.com/api/v1` |

### 可选配置

| 配置项 | 说明 | 默认值 | 示例 |
|--------|------|--------|------|
| `DEV_WS_URL` | 开发环境 WebSocket 地址 | `ws://localhost:8080/ws` | - |
| `PROD_WS_URL` | 生产环境 WebSocket 地址 | `wss://api.todolist.com/ws` | - |
| `APP_NAME` | 应用名称 | `ToDoList` | - |
| `APP_VERSION` | 应用版本 | `1.0.0` | - |
| `ENABLE_ANALYTICS` | 是否启用分析 | `false` | `true` 或 `false` |
| `ENABLE_CRASH_REPORTING` | 是否启用崩溃报告 | `false` | `true` 或 `false` |
| `ENABLE_DEBUG_MODE` | 是否启用调试模式 | `true` | `true` 或 `false` |
| `API_TIMEOUT` | API 超时时间（毫秒） | `30000` | `60000` |
| `MAX_CACHE_SIZE` | 最大缓存数量 | `50` | `100` |
| `AUTO_SYNC_INTERVAL` | 自动同步间隔（秒） | `300` | `600` |

## 🔧 使用方法

### 在代码中访问配置

```dart
import 'package:todolist_mobile/utils/constants.dart';

// 获取当前环境
final env = Config.environment; // Environment.development 或 Environment.production

// 获取 API 地址
final apiUrl = Config.baseUrl;

// 获取 WebSocket 地址
final wsUrl = Config.wsUrl;

// 获取应用信息
final appName = Config.appName;
final appVersion = Config.appVersion;

// 功能开关
if (Config.enableDebugMode) {
  print('Debug mode is enabled');
}

// API 配置
final timeout = Config.apiTimeout;
```

## 🌍 多环境切换

### 方式一：修改 .env 文件

直接在 `.env` 文件中修改 `ENVIRONMENT` 的值：

```env
# 开发环境
ENVIRONMENT=development

# 或生产环境
ENVIRONMENT=production
```

### 方式二：使用不同的配置文件

创建多个配置文件：
- `.env.development` - 开发环境
- `.env.production` - 生产环境
- `.env.staging` - 预发布环境

使用时复制对应的文件：

```bash
# 切换到生产环境
Copy-Item .env.production .env

# 切换到开发环境
Copy-Item .env.example .env
```

## 📦 在代码中的使用示例

### 1. API 服务配置

```dart
import 'package:dio/dio.dart';
import 'package:todolist_mobile/utils/constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: Config.baseUrl,
      connectTimeout: Duration(milliseconds: Config.apiTimeout),
      receiveTimeout: Duration(milliseconds: Config.apiTimeout),
    ));
  }
}
```

### 2. 条件渲染

```dart
import 'package:todolist_mobile/utils/constants.dart';

Widget build(BuildContext context) {
  return Column(
    children: [
      Text('当前环境: ${Config.environment.name}'),
      if (Config.enableDebugMode)
        Text('API: ${Config.baseUrl}'),
    ],
  );
}
```

## 🔒 安全注意事项

1. **不要提交 `.env` 文件到 Git**
   - `.env` 文件已添加到 `.gitignore`
   - 只提交 `.env.example` 作为模板

2. **生产环境配置保护**
   - 不要在 `.env.example` 中包含真实的生产环境密钥
   - 使用环境变量或密钥管理服务存储敏感信息

3. **团队协作**
   - 每个开发者维护自己的 `.env` 文件
   - 通过 `.env.example` 同步必需的配置项
   - 敏感信息通过安全渠道分享

## 🐛 故障排除

### 问题：应用无法加载配置

**解决方案**：
1. 确保 `.env` 文件存在于项目根目录
2. 检查 `pubspec.yaml` 中是否正确配置了资源：
   ```yaml
   flutter:
     assets:
       - .env
   ```
3. 运行 `flutter pub get` 重新获取依赖
4. 完全清理并重新构建：
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### 问题：配置值未生效

**解决方案**：
1. 检查 `.env` 文件格式是否正确（key=value，无空格）
2. 重启应用（热重载不会重新加载 `.env` 文件）
3. 检查代码中是否使用了 `Config` 类的正确方法

### 问题：找不到 flutter_dotenv 包

**解决方案**：
```bash
flutter pub add flutter_dotenv
flutter pub get
```

## 📚 参考资源

- [flutter_dotenv 文档](https://pub.dev/packages/flutter_dotenv)
- [Flutter 环境配置最佳实践](https://flutter.dev/docs/deployment/flavors)
- [Dart 环境变量指南](https://dart.dev/tools/dart-run#environment-variables)
