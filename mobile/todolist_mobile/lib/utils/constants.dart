import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 环境配置
enum Environment {
  development,
  production,
}

class Config {
  static Environment get environment {
    final environmentString =
        dotenv.get('ENVIRONMENT', fallback: 'development');
    return Environment.values.firstWhere(
      (e) => e.name == environmentString,
      orElse: () => Environment.development,
    );
  }

  static String get baseUrl {
    switch (environment) {
      case Environment.development:
        return dotenv.get('DEV_API_URL',
            fallback: 'http://localhost:8080/api/v1');
      case Environment.production:
        return dotenv.get('PROD_API_URL',
            fallback: 'https://api.todolist.com/api/v1');
    }
  }

  // WebSocket URL（可选）
  static String get wsUrl {
    switch (environment) {
      case Environment.development:
        return dotenv.get('DEV_WS_URL', fallback: 'ws://localhost:8080/ws');
      case Environment.production:
        return dotenv.get('PROD_WS_URL', fallback: 'wss://api.todolist.com/ws');
    }
  }

  // 应用配置
  static String get appName => dotenv.get('APP_NAME', fallback: 'ToDoList');
  static String get appVersion => dotenv.get('APP_VERSION', fallback: '1.0.0');

  // 功能开关
  static bool get enableAnalytics =>
      dotenv.get('ENABLE_ANALYTICS', fallback: 'false') == 'true';
  static bool get enableCrashReporting =>
      dotenv.get('ENABLE_CRASH_REPORTING', fallback: 'false') == 'true';
  static bool get enableDebugMode =>
      dotenv.get('ENABLE_DEBUG_MODE', fallback: 'true') == 'true';

  // API配置
  static int get apiTimeout =>
      int.tryParse(dotenv.get('API_TIMEOUT', fallback: '30000')) ?? 30000;

  // 本地存储配置
  static int get maxCacheSize =>
      int.tryParse(dotenv.get('MAX_CACHE_SIZE', fallback: '50')) ?? 50;
  static int get autoSyncInterval =>
      int.tryParse(dotenv.get('AUTO_SYNC_INTERVAL', fallback: '300')) ?? 300;

  static bool get isProduction => environment == Environment.production;
  static bool get isDevelopment => environment == Environment.development;
}

/// API配置
class ApiConstants {
  static String get baseUrl => Config.baseUrl;

  // 认证接口
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get refresh => '$baseUrl/auth/refresh';

  // 事件接口
  static String get events => '$baseUrl/events';
  static String get eventsById => '$baseUrl/events'; // + /{id}

  // 任务接口
  static String get tasks => '$baseUrl/tasks';
  static String get tasksById => '$baseUrl/tasks'; // + /{id}

  // 用户接口
  static String get profile => '$baseUrl/user/profile';
  static String get updateProfile => '$baseUrl/user/profile';
}

/// 应用主题色彩
class AppColors {
  static const Color primary = Color(0xFF007AFF);
  static const Color secondary = Color(0xFF5AC8FA);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);

  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F2F7);

  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFC7C7CC);

  static const Color divider = Color(0xFFE5E5EA);
}

/// 应用文本样式
class AppTextStyles {
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle subhead = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

/// 应用间距
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// 应用圆角
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

/// 应用动画时长
class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

/// 本地存储键名
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String isFirstLaunch = 'is_first_launch';
  static const String offlineMode = 'offline_mode';
}

/// 任务状态
enum TaskStatus {
  pending,
  completed,
  cancelled,
}

/// 任务优先级
enum TaskPriority {
  low,
  medium,
  high,
}

/// 扩展方法
extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return '进行中';
      case TaskStatus.completed:
        return '已完成';
      case TaskStatus.cancelled:
        return '已取消';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.pending:
        return AppColors.warning;
      case TaskStatus.completed:
        return AppColors.success;
      case TaskStatus.cancelled:
        return AppColors.textSecondary;
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return '低';
      case TaskPriority.medium:
        return '中';
      case TaskPriority.high:
        return '高';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return AppColors.success;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.high:
        return AppColors.error;
    }
  }
}
