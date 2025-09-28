import 'package:flutter/material.dart';

/// API配置
class ApiConstants {
  // 替换为你的实际API域名 - 请更新这个URL为你的云端API地址
  static const String baseUrl = 'https://your-actual-api-domain.com/api/v1';
  
  // 认证接口
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String refresh = '$baseUrl/auth/refresh';
  
  // 事件接口
  static const String events = '$baseUrl/events';
  static const String eventsById = '$baseUrl/events'; // + /{id}
  
  // 任务接口
  static const String tasks = '$baseUrl/tasks';
  static const String tasksById = '$baseUrl/tasks'; // + /{id}
  
  // 用户接口
  static const String profile = '$baseUrl/user/profile';
  static const String updateProfile = '$baseUrl/user/profile';
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