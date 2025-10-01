import 'package:flutter/material.dart';

import '../models/todo_event.dart';
import '../services/api_service.dart';
import '../services/offline_storage_service.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../utils/constants.dart';

class TodoProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final OfflineStorageService _offlineService = OfflineStorageService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final SyncService _syncService = SyncService();

  List<TodoEvent> _events = [];
  final List<TodoTask> _tasks = [];
  bool _isLoading = false;
  String? _error;
  bool _isOfflineMode = false;

  // Getters
  List<TodoEvent> get events => _events;
  List<TodoTask> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOfflineMode => _isOfflineMode;

  // 初始化
  Future<void> init() async {
    await _offlineService.init();
    await _connectivityService.init();

    _isOfflineMode = _offlineService.isOfflineMode;

    // 监听网络状态变化
    _connectivityService.connectionStream.listen((isConnected) {
      if (isConnected && !_isOfflineMode) {
        // 网络恢复时自动同步
        _syncIfNeeded();
      }
    });
  }

  // 获取指定事件的任务
  List<TodoTask> getTasksByEventId(int eventId) {
    return _tasks.where((task) => task.eventId == eventId).toList();
  }

  // 获取待完成的事件
  List<TodoEvent> get pendingEvents {
    return _events.where((event) => !event.isCompleted).toList();
  }

  // 获取已完成的事件
  List<TodoEvent> get completedEvents {
    return _events.where((event) => event.isCompleted).toList();
  }

  // 获取过期的事件
  List<TodoEvent> get overdueEvents {
    return _events.where((event) => event.isOverdue).toList();
  }

  // 获取待完成的任务
  List<TodoTask> get pendingTasks {
    return _tasks.where((task) => task.status == TaskStatus.pending).toList();
  }

  // 获取已完成的任务
  List<TodoTask> get completedTasks {
    return _tasks.where((task) => task.status == TaskStatus.completed).toList();
  }

  // 加载所有事件
  Future<void> loadEvents({int? userId}) async {
    _setLoading(true);
    _clearError();

    try {
      if (_isOfflineMode) {
        // 离线模式：从本地数据库加载
        _events = await _offlineService.getOfflineEvents(userId: userId);
        _events.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        notifyListeners();
      } else {
        // 在线模式：从服务器加载
        final response = await _apiService.get<List<dynamic>>(
          ApiConstants.events,
          fromJson: (json) => json as List<dynamic>,
        );

        if (response.isSuccess && response.data != null) {
          _events = response.data!
              .map((json) => TodoEvent.fromJson(json as Map<String, dynamic>))
              .toList();

          _events.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          // 保存到本地数据库
          for (final event in _events) {
            await _offlineService.dbService.insertEvent(event);
          }

          notifyListeners();
        } else {
          _setError(response.message ?? '加载事件失败');
        }
      }
    } catch (e) {
      _setError('加载事件异常: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 创建事件
  Future<bool> createEvent({
    required String title,
    required String description,
    required int userId,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (_isOfflineMode) {
        // 离线模式：保存到本地数据库
        final newEvent = await _offlineService.createOfflineEvent(
          title: title,
          description: description,
          userId: userId,
          dueDate: dueDate,
          priority: priority,
        );

        _events.insert(0, newEvent);
        notifyListeners();
        return true;
      } else {
        // 在线模式：发送到服务器
        final response = await _apiService.post<Map<String, dynamic>>(
          ApiConstants.events,
          data: {
            'title': title,
            'description': description,
            if (dueDate != null) 'due_date': dueDate.toIso8601String(),
            'priority': priority.name,
          },
          fromJson: (json) => json,
        );

        if (response.isSuccess && response.data != null) {
          final newEvent = TodoEvent.fromJson(response.data!);
          _events.insert(0, newEvent);

          // 同时保存到本地数据库
          await _offlineService.dbService.insertEvent(newEvent);

          notifyListeners();
          return true;
        } else {
          _setError(response.message ?? '创建事件失败');
          return false;
        }
      }
    } catch (e) {
      _setError('创建事件异常: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 更新事件
  Future<bool> updateEvent({
    required int eventId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final eventIndex = _events.indexWhere((event) => event.id == eventId);
      if (eventIndex == -1) {
        _setError('事件不存在');
        return false;
      }

      final originalEvent = _events[eventIndex];
      final updatedEvent = originalEvent.copyWith(
        title: title ?? originalEvent.title,
        description: description ?? originalEvent.description,
        dueDate: dueDate ?? originalEvent.dueDate,
        priority: priority ?? originalEvent.priority,
        isCompleted: isCompleted ?? originalEvent.isCompleted,
      );

      if (_isOfflineMode) {
        // 离线模式：更新本地数据库
        final success = await _offlineService.updateOfflineEvent(updatedEvent);
        if (success) {
          _events[eventIndex] = updatedEvent;
          notifyListeners();
          return true;
        } else {
          _setError('更新事件失败');
          return false;
        }
      } else {
        // 在线模式：发送到服务器
        final data = <String, dynamic>{};
        if (title != null) data['title'] = title;
        if (description != null) data['description'] = description;
        if (dueDate != null) data['due_date'] = dueDate.toIso8601String();
        if (priority != null) data['priority'] = priority.name;
        if (isCompleted != null) data['is_completed'] = isCompleted;

        final response = await _apiService.put<Map<String, dynamic>>(
          '${ApiConstants.eventsById}/$eventId',
          data: data,
          fromJson: (json) => json,
        );

        if (response.isSuccess && response.data != null) {
          final serverEvent = TodoEvent.fromJson(response.data!);
          _events[eventIndex] = serverEvent;

          // 同时更新本地数据库
          await _offlineService.dbService.updateEvent(serverEvent);

          notifyListeners();
          return true;
        } else {
          _setError(response.message ?? '更新事件失败');
          return false;
        }
      }
    } catch (e) {
      _setError('更新事件异常: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 删除事件
  Future<bool> deleteEvent(int eventId) async {
    _setLoading(true);
    _clearError();

    try {
      if (_isOfflineMode) {
        // 离线模式：从本地数据库删除
        final success = await _offlineService.deleteOfflineEvent(eventId);
        if (success) {
          _events.removeWhere((event) => event.id == eventId);
          _tasks.removeWhere((task) => task.eventId == eventId);
          notifyListeners();
          return true;
        } else {
          _setError('删除事件失败');
          return false;
        }
      } else {
        // 在线模式：从服务器删除
        final response = await _apiService.delete(
          '${ApiConstants.eventsById}/$eventId',
        );

        if (response.isSuccess) {
          _events.removeWhere((event) => event.id == eventId);
          _tasks.removeWhere((task) => task.eventId == eventId);

          // 同时从本地数据库删除
          await _offlineService.dbService.deleteEvent(eventId);

          notifyListeners();
          return true;
        } else {
          _setError(response.message ?? '删除事件失败');
          return false;
        }
      }
    } catch (e) {
      _setError('删除事件异常: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 加载指定事件的任务
  Future<void> loadTasks(int eventId, {int? userId}) async {
    _setLoading(true);
    _clearError();

    try {
      if (_isOfflineMode) {
        // 离线模式：从本地数据库加载
        final eventTasks = await _offlineService.getOfflineTasks(
          eventId: eventId,
          userId: userId,
        );

        // 移除旧的任务，添加新的任务
        _tasks.removeWhere((task) => task.eventId == eventId);
        _tasks.addAll(eventTasks);

        _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      } else {
        // 在线模式：从服务器加载
        final response = await _apiService.get<List<dynamic>>(
          ApiConstants.tasks,
          queryParams: {'event_id': eventId},
          fromJson: (json) => json as List<dynamic>,
        );

        if (response.isSuccess && response.data != null) {
          final eventTasks = response.data!
              .map((json) => TodoTask.fromJson(json as Map<String, dynamic>))
              .toList();

          // 移除旧的任务，添加新的任务
          _tasks.removeWhere((task) => task.eventId == eventId);
          _tasks.addAll(eventTasks);

          _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // 保存到本地数据库
          for (final task in eventTasks) {
            await _offlineService.dbService.insertTask(task);
          }

          notifyListeners();
        } else {
          _setError(response.message ?? '加载任务失败');
        }
      }
    } catch (e) {
      _setError('加载任务异常: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 创建任务
  Future<bool> createTask(int eventId, TodoTask task) async {
    _setLoading(true);
    _clearError();

    try {
      if (_isOfflineMode) {
        // 离线模式：保存到本地数据库
        await _offlineService.dbService.insertTask(task);
        _tasks.insert(0, task);

        // 更新事件的任务列表
        final eventIndex = _events.indexWhere((e) => e.id == eventId);
        if (eventIndex != -1) {
          final event = _events[eventIndex];
          final updatedTasks = [...?event.tasks, task];
          _events[eventIndex] = event.copyWith(tasks: updatedTasks);
        }

        notifyListeners();
        return true;
      } else {
        // 在线模式：发送到服务器
        final response = await _apiService.post<Map<String, dynamic>>(
          ApiConstants.tasks,
          data: task.toJson(),
          fromJson: (json) => json,
        );

        if (response.isSuccess && response.data != null) {
          final newTask = TodoTask.fromJson(response.data!);
          _tasks.insert(0, newTask);

          // 更新事件的任务列表
          final eventIndex = _events.indexWhere((e) => e.id == eventId);
          if (eventIndex != -1) {
            final event = _events[eventIndex];
            final updatedTasks = [...?event.tasks, newTask];
            _events[eventIndex] = event.copyWith(tasks: updatedTasks);
          }

          // 同时保存到本地数据库
          await _offlineService.dbService.insertTask(newTask);

          notifyListeners();
          return true;
        } else {
          _setError(response.message ?? '创建任务失败');
          return false;
        }
      }
    } catch (e) {
      _setError('创建任务异常: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 更新任务
  Future<bool> updateTask(TodoTask task) async {
    _setLoading(true);
    _clearError();

    try {
      if (_isOfflineMode) {
        // 离线模式：更新本地数据库
        await _offlineService.dbService.updateTask(task);

        final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
        if (taskIndex != -1) {
          _tasks[taskIndex] = task;
        }

        // 更新事件的任务列表
        final eventIndex = _events.indexWhere((e) => e.id == task.eventId);
        if (eventIndex != -1) {
          final event = _events[eventIndex];
          final updatedTasks =
              event.tasks?.map((t) => t.id == task.id ? task : t).toList();
          if (updatedTasks != null) {
            _events[eventIndex] = event.copyWith(tasks: updatedTasks);
          }
        }

        notifyListeners();
        return true;
      } else {
        // 在线模式：发送到服务器
        final response = await _apiService.put<Map<String, dynamic>>(
          '${ApiConstants.tasks}/${task.id}',
          data: task.toJson(),
          fromJson: (json) => json,
        );

        if (response.isSuccess && response.data != null) {
          final updatedTask = TodoTask.fromJson(response.data!);

          final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
          if (taskIndex != -1) {
            _tasks[taskIndex] = updatedTask;
          }

          // 更新事件的任务列表
          final eventIndex =
              _events.indexWhere((e) => e.id == updatedTask.eventId);
          if (eventIndex != -1) {
            final event = _events[eventIndex];
            final updatedTasks = event.tasks
                ?.map((t) => t.id == task.id ? updatedTask : t)
                .toList();
            if (updatedTasks != null) {
              _events[eventIndex] = event.copyWith(tasks: updatedTasks);
            }
          }

          // 同时更新本地数据库
          await _offlineService.dbService.updateTask(updatedTask);

          notifyListeners();
          return true;
        } else {
          _setError(response.message ?? '更新任务失败');
          return false;
        }
      }
    } catch (e) {
      _setError('更新任务异常: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 删除任务
  Future<bool> deleteTask(int taskId) async {
    _setLoading(true);
    _clearError();

    try {
      if (_isOfflineMode) {
        // 离线模式：从本地数据库删除
        await _offlineService.dbService.deleteTask(taskId);

        final task = _tasks.firstWhere((t) => t.id == taskId,
            orElse: () => throw Exception('Task not found'));
        _tasks.removeWhere((t) => t.id == taskId);

        // 更新事件的任务列表
        final eventIndex = _events.indexWhere((e) => e.id == task.eventId);
        if (eventIndex != -1) {
          final event = _events[eventIndex];
          final updatedTasks =
              event.tasks?.where((t) => t.id != taskId).toList();
          if (updatedTasks != null) {
            _events[eventIndex] = event.copyWith(tasks: updatedTasks);
          }
        }

        notifyListeners();
        return true;
      } else {
        // 在线模式：从服务器删除
        final response = await _apiService.delete(
          '${ApiConstants.tasks}/$taskId',
        );

        if (response.isSuccess) {
          final task = _tasks.firstWhere((t) => t.id == taskId,
              orElse: () => throw Exception('Task not found'));
          _tasks.removeWhere((t) => t.id == taskId);

          // 更新事件的任务列表
          final eventIndex = _events.indexWhere((e) => e.id == task.eventId);
          if (eventIndex != -1) {
            final event = _events[eventIndex];
            final updatedTasks =
                event.tasks?.where((t) => t.id != taskId).toList();
            if (updatedTasks != null) {
              _events[eventIndex] = event.copyWith(tasks: updatedTasks);
            }
          }

          // 同时从本地数据库删除
          await _offlineService.dbService.deleteTask(taskId);

          notifyListeners();
          return true;
        } else {
          _setError(response.message ?? '删除任务失败');
          return false;
        }
      }
    } catch (e) {
      _setError('删除任务异常: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 切换在线/离线模式
  Future<void> switchMode({bool offline = false}) async {
    _setLoading(true);

    try {
      if (offline) {
        // 切换到离线模式
        final syncResult = await _syncService.switchToOfflineMode();
        if (syncResult.success) {
          _isOfflineMode = true;
          await loadEvents(); // 重新加载数据
        } else {
          _setError(syncResult.message);
        }
      } else {
        // 切换到在线模式需要登录信息，这里只是设置标志
        _isOfflineMode = false;
        await _offlineService.setOfflineMode(false);
      }
    } catch (e) {
      _setError('切换模式失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 同步数据
  Future<void> syncData() async {
    if (_isOfflineMode || !_connectivityService.isConnected) {
      return;
    }

    _setLoading(true);

    try {
      final syncResult = await _syncService.performFullSync();
      if (syncResult.success) {
        await loadEvents(); // 重新加载数据
      } else {
        _setError(syncResult.message);
      }
    } catch (e) {
      _setError('同步失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 自动同步（如果需要）
  Future<void> _syncIfNeeded() async {
    if (!_isOfflineMode && _connectivityService.isConnected) {
      final hasUnsyncedData =
          (await _offlineService.getUnsyncedData()).isNotEmpty;
      if (hasUnsyncedData) {
        await syncData();
      }
    }
  }

  // 刷新数据
  Future<void> refresh() async {
    await loadEvents();
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // 设置错误信息
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // 清除错误信息
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // 清除所有数据
  void clear() {
    _events.clear();
    _tasks.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}
