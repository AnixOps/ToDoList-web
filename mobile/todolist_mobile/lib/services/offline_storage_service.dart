import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../models/todo_event.dart';
import '../utils/constants.dart';
import 'database_service.dart';

class OfflineStorageService {
  static final OfflineStorageService _instance =
      OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  final DatabaseService _dbService = DatabaseService();
  final Uuid _uuid = const Uuid();
  late SharedPreferences _prefs;

  // 暴露数据库服务供同步使用
  DatabaseService get dbService => _dbService;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      // 在非Web平台上初始化数据库服务
      if (!kIsWeb) {
        await _dbService.database;
      }
    } catch (e) {
      throw Exception('Failed to initialize offline storage: $e');
    }
  }

  // 离线模式状态管理
  bool get isOfflineMode => _prefs.getBool(StorageKeys.offlineMode) ?? false;

  Future<void> setOfflineMode(bool enabled) async {
    await _prefs.setBool(StorageKeys.offlineMode, enabled);
  }

  // 离线用户管理
  Future<User> createOfflineUser({
    required String name,
    required String email,
  }) async {
    final now = DateTime.now();
    final localId = _uuid.v4();

    // 使用负数ID表示离线用户
    final userId = -DateTime.now().millisecondsSinceEpoch;

    final user = User(
      id: userId,
      email: email,
      name: name,
      createdAt: now,
      updatedAt: now,
    );

    if (kIsWeb) {
      // Web平台：使用SharedPreferences存储用户信息
      await _prefs.setInt(StorageKeys.userId, userId);
      await _prefs.setString(StorageKeys.userEmail, email);
      await _prefs.setString(StorageKeys.userName, name);
      await _prefs.setString('offline_user_local_id', localId);
      await _prefs.setString('offline_user_created_at', now.toIso8601String());
      await _prefs.setString('offline_user_updated_at', now.toIso8601String());
    } else {
      // 非Web平台：使用数据库
      await _dbService.insertUser(user, localId: localId);
      await _prefs.setInt(StorageKeys.userId, userId);
      await _prefs.setString(StorageKeys.userEmail, email);
      await _prefs.setString(StorageKeys.userName, name);
      await _prefs.setString('offline_user_local_id', localId);
    }

    return user;
  }

  Future<User?> getOfflineUser() async {
    if (kIsWeb) {
      // Web平台：从sharedPreferences读取用户信息
      final userId = _prefs.getInt(StorageKeys.userId);
      final email = _prefs.getString(StorageKeys.userEmail);
      final name = _prefs.getString(StorageKeys.userName);
      final createdAtStr = _prefs.getString('offline_user_created_at');
      final updatedAtStr = _prefs.getString('offline_user_updated_at');

      if (userId != null && email != null && name != null) {
        return User(
          id: userId,
          email: email,
          name: name,
          createdAt: createdAtStr != null
              ? DateTime.parse(createdAtStr)
              : DateTime.now(),
          updatedAt: updatedAtStr != null
              ? DateTime.parse(updatedAtStr)
              : DateTime.now(),
        );
      }
      return null;
    } else {
      // 非Web平台：从数据库读取
      return await _dbService.getCurrentUser();
    }
  }

  // 离线事件管理
  Future<TodoEvent> createOfflineEvent({
    required String title,
    required String description,
    required int userId,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    final now = DateTime.now();
    final localId = _uuid.v4();

    // 使用负数ID表示离线数据
    final eventId = -DateTime.now().millisecondsSinceEpoch;

    final event = TodoEvent(
      id: eventId,
      title: title,
      description: description,
      userId: userId,
      createdAt: now,
      updatedAt: now,
      dueDate: dueDate,
      priority: priority,
    );

    if (kIsWeb) {
      // Web平台：存储在SharedPreferences中
      await _saveEventToPrefs(event);
    } else {
      // 非Web平台：存储在数据库中
      await _dbService.insertEvent(event, localId: localId);
    }
    return event;
  }

  Future<List<TodoEvent>> getOfflineEvents({int? userId}) async {
    if (kIsWeb) {
      // Web平台：从sharedPreferences读取
      return await _getEventsFromPrefs(userId: userId);
    } else {
      // 非Web平台：从数据库读取
      return await _dbService.getEvents(userId: userId);
    }
  }

  Future<TodoEvent?> getOfflineEvent(int eventId) async {
    return await _dbService.getEvent(eventId);
  }

  Future<bool> updateOfflineEvent(TodoEvent event) async {
    try {
      await _dbService.updateEvent(event);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteOfflineEvent(int eventId) async {
    try {
      await _dbService.deleteEvent(eventId);
      // 同时删除相关任务
      final tasks = await _dbService.getTasks(eventId: eventId);
      for (final task in tasks) {
        await _dbService.deleteTask(task.id);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // 离线任务管理
  Future<TodoTask> createOfflineTask({
    required String title,
    required String description,
    required int eventId,
    required int userId,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    final now = DateTime.now();
    final localId = _uuid.v4();

    // 使用负数ID表示离线数据
    final taskId = -DateTime.now().millisecondsSinceEpoch;

    final task = TodoTask(
      id: taskId,
      title: title,
      description: description,
      eventId: eventId,
      userId: userId,
      createdAt: now,
      updatedAt: now,
      dueDate: dueDate,
      priority: priority,
    );

    await _dbService.insertTask(task, localId: localId);
    return task;
  }

  Future<List<TodoTask>> getOfflineTasks({int? eventId, int? userId}) async {
    return await _dbService.getTasks(eventId: eventId, userId: userId);
  }

  Future<bool> updateOfflineTask(TodoTask task) async {
    try {
      await _dbService.updateTask(task);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteOfflineTask(int taskId) async {
    try {
      await _dbService.deleteTask(taskId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 切换任务状态
  Future<bool> toggleOfflineTaskStatus(int taskId) async {
    try {
      final tasks = await _dbService.getTasks();
      final task = tasks.firstWhere((t) => t.id == taskId);

      final newStatus = task.status == TaskStatus.completed
          ? TaskStatus.pending
          : TaskStatus.completed;

      final updatedTask = task.copyWith(status: newStatus);
      return await updateOfflineTask(updatedTask);
    } catch (e) {
      return false;
    }
  }

  // 数据统计
  Future<Map<String, int>> getOfflineStats({int? userId}) async {
    final events = await getOfflineEvents(userId: userId);
    final tasks = await getOfflineTasks(userId: userId);

    final pendingEvents = events.where((e) => !e.isCompleted).length;
    final completedEvents = events.where((e) => e.isCompleted).length;
    final overdueEvents = events.where((e) => e.isOverdue).length;

    final pendingTasks =
        tasks.where((t) => t.status == TaskStatus.pending).length;
    final completedTasks =
        tasks.where((t) => t.status == TaskStatus.completed).length;
    final overdueTasks = tasks.where((t) => t.isOverdue).length;

    return {
      'totalEvents': events.length,
      'pendingEvents': pendingEvents,
      'completedEvents': completedEvents,
      'overdueEvents': overdueEvents,
      'totalTasks': tasks.length,
      'pendingTasks': pendingTasks,
      'completedTasks': completedTasks,
      'overdueTasks': overdueTasks,
    };
  }

  // 数据导出
  Future<Map<String, dynamic>> exportOfflineData({int? userId}) async {
    final events = await getOfflineEvents(userId: userId);
    final tasks = await getOfflineTasks(userId: userId);
    final user = await getOfflineUser();

    return {
      'user': user?.toJson(),
      'events': events.map((e) => e.toJson()).toList(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  // 数据导入
  Future<bool> importOfflineData(Map<String, dynamic> data) async {
    try {
      // 清空现有数据
      await _dbService.clearAllData();

      // 导入用户数据
      if (data['user'] != null) {
        final user = User.fromJson(data['user']);
        await _dbService.insertUser(user);
      }

      // 导入事件数据
      if (data['events'] != null) {
        final events =
            (data['events'] as List).map((e) => TodoEvent.fromJson(e)).toList();

        for (final event in events) {
          await _dbService.insertEvent(event);
        }
      }

      // 导入任务数据
      if (data['tasks'] != null) {
        final tasks =
            (data['tasks'] as List).map((t) => TodoTask.fromJson(t)).toList();

        for (final task in tasks) {
          await _dbService.insertTask(task);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // 清空离线数据
  Future<void> clearOfflineData() async {
    await _dbService.clearAllData();
    await _prefs.remove(StorageKeys.userId);
    await _prefs.remove(StorageKeys.userEmail);
    await _prefs.remove(StorageKeys.userName);
    await _prefs.remove('offline_user_local_id');
    await setOfflineMode(false);
  }

  // 获取需要同步的数据
  Future<List<Map<String, dynamic>>> getUnsyncedData() async {
    return await _dbService.getUnsyncedRecords();
  }

  // 标记数据为已同步
  Future<void> markDataAsSynced(String tableName, int id) async {
    await _dbService.markAsSynced(tableName, id);
  }

  // 检查是否有离线数据
  Future<bool> hasOfflineData() async {
    final events = await getOfflineEvents();
    final tasks = await getOfflineTasks();
    return events.isNotEmpty || tasks.isNotEmpty;
  }

  // Web平台的帮助方法
  Future<void> _saveEventToPrefs(TodoEvent event) async {
    final eventsJson = _prefs.getStringList('offline_events') ?? [];
    final eventData = {
      'id': event.id,
      'title': event.title,
      'description': event.description,
      'userId': event.userId,
      'createdAt': event.createdAt.toIso8601String(),
      'updatedAt': event.updatedAt.toIso8601String(),
      'dueDate': event.dueDate?.toIso8601String(),
      'isCompleted': event.isCompleted,
      'priority': event.priority.toString(),
    };
    eventsJson.add(jsonEncode(eventData));
    await _prefs.setStringList('offline_events', eventsJson);
  }

  Future<List<TodoEvent>> _getEventsFromPrefs({int? userId}) async {
    final eventsJson = _prefs.getStringList('offline_events') ?? [];
    final events = <TodoEvent>[];

    for (final eventStr in eventsJson) {
      try {
        final eventData = jsonDecode(eventStr) as Map<String, dynamic>;
        if (userId == null || eventData['userId'] == userId) {
          final event = TodoEvent(
            id: eventData['id'],
            title: eventData['title'],
            description: eventData['description'],
            userId: eventData['userId'],
            createdAt: DateTime.parse(eventData['createdAt']),
            updatedAt: DateTime.parse(eventData['updatedAt']),
            dueDate: eventData['dueDate'] != null
                ? DateTime.parse(eventData['dueDate'])
                : null,
            isCompleted: eventData['isCompleted'] ?? false,
            priority: TaskPriority.values.firstWhere(
              (p) => p.toString() == eventData['priority'],
              orElse: () => TaskPriority.medium,
            ),
          );
          events.add(event);
        }
      } catch (e) {
        debugPrint('Failed to parse event: $e');
      }
    }

    return events;
  }
}
