# ToDoList Mobile - Flutter版本

## 📱 项目简介

ToDoList的Flutter移动端版本，支持iOS和Android平台。

## 🚀 Flutter安装指南

### Windows环境安装Flutter

1. **下载Flutter SDK**
   ```bash
   # 访问官网下载：https://flutter.dev/docs/get-started/install/windows
   # 或者使用Git克隆（推荐）
   git clone https://github.com/flutter/flutter.git -b stable
   ```

2. **设置环境变量**
   - 将Flutter的bin目录添加到PATH
   - 例如：`C:\flutter\bin`

3. **验证安装**
   ```bash
   flutter doctor
   ```

4. **安装VS Code插件**
   - Flutter插件
   - Dart插件

## 🛠 项目设置

### 创建Flutter项目
```bash
cd mobile
flutter create todolist_mobile
cd todolist_mobile
```

### 主要依赖包
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0              # HTTP请求
  shared_preferences: ^2.2.0 # 本地存储
  provider: ^6.0.5          # 状态管理
  json_annotation: ^4.8.1   # JSON序列化
  cupertino_icons: ^1.0.2   # iOS风格图标
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  json_serializable: ^6.7.1
  build_runner: ^2.4.6
```

## 📂 项目结构

```
mobile/todolist_mobile/
├── lib/
│   ├── main.dart              # 应用入口
│   ├── models/                # 数据模型
│   │   ├── user.dart
│   │   ├── todo_event.dart
│   │   └── todo_task.dart
│   ├── services/              # API服务
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   └── storage_service.dart
│   ├── providers/             # 状态管理
│   │   ├── auth_provider.dart
│   │   └── todo_provider.dart
│   ├── screens/               # 页面
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── todo_list_screen.dart
│   │   └── profile_screen.dart
│   ├── widgets/               # 通用组件
│   │   ├── custom_button.dart
│   │   ├── todo_card.dart
│   │   └── loading_widget.dart
│   └── utils/                 # 工具类
│       ├── constants.dart
│       ├── helpers.dart
│       └── validators.dart
├── ios/                       # iOS配置
├── android/                   # Android配置
└── pubspec.yaml              # 依赖配置
```

## 🔗 API对接

项目将对接现有的Go后端API：

### API端点配置
```dart
class ApiConstants {
  static const String baseUrl = 'https://your-api-domain.com/api/v1';
  
  // 认证接口
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  
  // 任务接口
  static const String events = '$baseUrl/events';
  static const String tasks = '$baseUrl/tasks';
}
```

### HTTP请求服务
```dart
class ApiService {
  static final http.Client _client = http.Client();
  
  static Future<Map<String, dynamic>> get(String url) async {
    // GET请求实现
  }
  
  static Future<Map<String, dynamic>> post(String url, Map<String, dynamic> data) async {
    // POST请求实现
  }
}
```

## 🎨 UI设计

### 主题配置
- **iOS风格**: Cupertino组件
- **Android风格**: Material Design组件
- **自适应**: 根据平台自动切换

### 响应式设计
- 支持不同屏幕尺寸
- 横屏/竖屏适配
- 平板电脑支持

## 📱 平台特性

### iOS特有功能
- Touch ID / Face ID 认证
- iOS原生分享
- Haptic Feedback（震动反馈）
- iOS风格导航

### Android特有功能
- 指纹认证
- Android分享
- Material Design动画
- Android Back按钮处理

## 🚀 运行项目

```bash
# 检查环境
flutter doctor

# 获取依赖
flutter pub get

# 运行iOS模拟器（需要Xcode）
flutter run -d ios

# 运行Android模拟器
flutter run -d android

# 热重载
r  # 热重载
R  # 热重启
q  # 退出
```

## 📦 打包发布

### iOS打包
```bash
flutter build ios --release
```

### Android打包
```bash
flutter build apk --release
```

## ✅ 开发计划

- [ ] 环境搭建和项目初始化
- [ ] 用户认证功能（登录/注册）
- [ ] 主界面和导航
- [ ] 任务列表展示
- [ ] 任务创建和编辑
- [ ] 离线存储功能
- [ ] 数据同步
- [ ] iOS/Android平台适配
- [ ] 性能优化
- [ ] 测试和发布