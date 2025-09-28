import 'package:flutter/material.dart';

import '../models/todo_event.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class TodoProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<TodoEvent> _events = [];
  List<TodoTask> _tasks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TodoEvent> get events => _events;
  List<TodoTask> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
  Future<void> loadEvents() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get<List<dynamic>>(
        ApiConstants.events,
        fromJson: (json) => json as List<dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        _events = response.data!
            .map((json) => TodoEvent.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // 按更新时间降序排列
        _events.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        
        notifyListeners();
      } else {
        _setError(response.message ?? '加载事件失败');
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
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    _setLoading(true);
    _clearError();

    try {
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
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? '创建事件失败');
        return false;
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
        final updatedEvent = TodoEvent.fromJson(response.data!);
        final index = _events.indexWhere((event) => event.id == eventId);
        
        if (index != -1) {
          _events[index] = updatedEvent;
          notifyListeners();
        }
        
        return true;
      } else {
        _setError(response.message ?? '更新事件失败');
        return false;
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
      final response = await _apiService.delete(
        '${ApiConstants.eventsById}/$eventId',
      );

      if (response.isSuccess) {
        _events.removeWhere((event) => event.id == eventId);
        _tasks.removeWhere((task) => task.eventId == eventId);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? '删除事件失败');
        return false;
      }
    } catch (e) {
      _setError('删除事件异常: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 加载指定事件的任务
  Future<void> loadTasks(int eventId) async {
    _setLoading(true);
    _clearError();

    try {
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
        
        // 按创建时间排序
        _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        notifyListeners();
      } else {
        _setError(response.message ?? '加载任务失败');
      }
    } catch (e) {
      _setError('加载任务异常: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 创建任务
  Future<bool> createTask({
    required int eventId,
    required String title,
    required String description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.tasks,
        data: {
          'event_id': eventId,
          'title': title,
          'description': description,
          if (dueDate != null) 'due_date': dueDate.toIso8601String(),
          'priority': priority.name,
        },
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final newTask = TodoTask.fromJson(response.data!);
        _tasks.insert(0, newTask);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? '创建任务失败');
        return false;
      }
    } catch (e) {
      _setError('创建任务异常: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 更新任务
  Future<bool> updateTask({
    required int taskId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (dueDate != null) data['due_date'] = dueDate.toIso8601String();
      if (priority != null) data['priority'] = priority.name;
      if (status != null) data['status'] = status.name;

      final response = await _apiService.put<Map<String, dynamic>>(
        '${ApiConstants.tasksById}/$taskId',
        data: data,
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final updatedTask = TodoTask.fromJson(response.data!);
        final index = _tasks.indexWhere((task) => task.id == taskId);
        
        if (index != -1) {
          _tasks[index] = updatedTask;
          notifyListeners();
        }
        
        return true;
      } else {
        _setError(response.message ?? '更新任务失败');
        return false;
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
      final response = await _apiService.delete(
        '${ApiConstants.tasksById}/$taskId',
      );

      if (response.isSuccess) {
        _tasks.removeWhere((task) => task.id == taskId);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? '删除任务失败');
        return false;
      }
    } catch (e) {
      _setError('删除任务异常: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 切换任务状态
  Future<bool> toggleTaskStatus(int taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final newStatus = task.status == TaskStatus.completed 
        ? TaskStatus.pending 
        : TaskStatus.completed;
    
    return await updateTask(taskId: taskId, status: newStatus);
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
}