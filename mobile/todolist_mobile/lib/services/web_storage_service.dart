import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../models/todo_event.dart';

class WebStorageService {
  static final WebStorageService _instance = WebStorageService._internal();
  factory WebStorageService() => _instance;
  WebStorageService._internal();

  late html.Storage _localStorage;
  bool _isInitialized = false;

  static const String _eventsKey = 'todolist_events';
  static const String _tasksKey = 'todolist_tasks';
  static const String _usersKey = 'todolist_users';
  static const String _counterKey = 'todolist_counter';

  Future<void> init() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      _localStorage = html.window.localStorage;
      _isInitialized = true;
    } else {
      throw UnsupportedError(
          'WebStorageService is only supported on web platform');
    }
  }

  // 获取下一个ID
  int _getNextId() {
    final counterStr = _localStorage[_counterKey];
    int counter = counterStr != null ? int.tryParse(counterStr) ?? 1 : 1;
    _localStorage[_counterKey] = (counter + 1).toString();
    return counter;
  }

  // 事件相关方法
  Future<List<TodoEvent>> getEvents({int? userId}) async {
    await init();

    final eventsJson = _localStorage[_eventsKey];
    if (eventsJson == null) return [];

    try {
      final List<dynamic> eventsList = json.decode(eventsJson);
      final events = eventsList
          .map((json) => TodoEvent.fromJson(json as Map<String, dynamic>))
          .toList();

      if (userId != null) {
        return events.where((event) => event.userId == userId).toList();
      }

      return events;
    } catch (e) {
      print('Error loading events: $e');
      return [];
    }
  }

  Future<int> insertEvent(TodoEvent event) async {
    await init();

    final events = await getEvents();
    final newEvent = event.copyWith(
      id: event.id == 0 ? _getNextId() : event.id,
      createdAt: event.createdAt,
      updatedAt: DateTime.now(),
    );

    events.add(newEvent);

    final eventsJson = json.encode(events.map((e) => e.toJson()).toList());
    _localStorage[_eventsKey] = eventsJson;

    return newEvent.id;
  }

  Future<bool> updateEvent(TodoEvent event) async {
    await init();

    final events = await getEvents();
    final index = events.indexWhere((e) => e.id == event.id);

    if (index == -1) return false;

    events[index] = event.copyWith(updatedAt: DateTime.now());

    final eventsJson = json.encode(events.map((e) => e.toJson()).toList());
    _localStorage[_eventsKey] = eventsJson;

    return true;
  }

  Future<bool> deleteEvent(int eventId) async {
    await init();

    final events = await getEvents();
    final initialLength = events.length;
    events.removeWhere((event) => event.id == eventId);

    if (events.length == initialLength) return false;

    final eventsJson = json.encode(events.map((e) => e.toJson()).toList());
    _localStorage[_eventsKey] = eventsJson;

    // 同时删除相关的任务
    await _deleteTasksByEventId(eventId);

    return true;
  }

  // 任务相关方法
  Future<List<TodoTask>> getTasks({int? eventId, int? userId}) async {
    await init();

    final tasksJson = _localStorage[_tasksKey];
    if (tasksJson == null) return [];

    try {
      final List<dynamic> tasksList = json.decode(tasksJson);
      final tasks = tasksList
          .map((json) => TodoTask.fromJson(json as Map<String, dynamic>))
          .toList();

      if (eventId != null) {
        return tasks.where((task) => task.eventId == eventId).toList();
      }

      if (userId != null) {
        return tasks.where((task) => task.userId == userId).toList();
      }

      return tasks;
    } catch (e) {
      print('Error loading tasks: $e');
      return [];
    }
  }

  Future<int> insertTask(TodoTask task) async {
    await init();

    final tasks = await getTasks();
    final newTask = task.copyWith(
      id: task.id == 0 ? _getNextId() : task.id,
      createdAt: task.createdAt,
      updatedAt: DateTime.now(),
    );

    tasks.add(newTask);

    final tasksJson = json.encode(tasks.map((t) => t.toJson()).toList());
    _localStorage[_tasksKey] = tasksJson;

    return newTask.id;
  }

  Future<bool> updateTask(TodoTask task) async {
    await init();

    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);

    if (index == -1) return false;

    tasks[index] = task.copyWith(updatedAt: DateTime.now());

    final tasksJson = json.encode(tasks.map((t) => t.toJson()).toList());
    _localStorage[_tasksKey] = tasksJson;

    return true;
  }

  Future<bool> deleteTask(int taskId) async {
    await init();

    final tasks = await getTasks();
    final initialLength = tasks.length;
    tasks.removeWhere((task) => task.id == taskId);

    if (tasks.length == initialLength) return false;

    final tasksJson = json.encode(tasks.map((t) => t.toJson()).toList());
    _localStorage[_tasksKey] = tasksJson;

    return true;
  }

  Future<void> _deleteTasksByEventId(int eventId) async {
    final tasks = await getTasks();
    tasks.removeWhere((task) => task.eventId == eventId);

    final tasksJson = json.encode(tasks.map((t) => t.toJson()).toList());
    _localStorage[_tasksKey] = tasksJson;
  }

  // 用户相关方法
  Future<List<User>> getUsers() async {
    await init();

    final usersJson = _localStorage[_usersKey];
    if (usersJson == null) return [];

    try {
      final List<dynamic> usersList = json.decode(usersJson);
      return usersList
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

  Future<int> insertUser(User user) async {
    await init();

    final users = await getUsers();
    final newUser = user.copyWith(
      id: user.id == 0 ? _getNextId() : user.id,
      createdAt: user.createdAt,
      updatedAt: DateTime.now(),
    );

    users.add(newUser);

    final usersJson = json.encode(users.map((u) => u.toJson()).toList());
    _localStorage[_usersKey] = usersJson;

    return newUser.id;
  }

  Future<bool> updateUser(User user) async {
    await init();

    final users = await getUsers();
    final index = users.indexWhere((u) => u.id == user.id);

    if (index == -1) return false;

    users[index] = user.copyWith(updatedAt: DateTime.now());

    final usersJson = json.encode(users.map((u) => u.toJson()).toList());
    _localStorage[_usersKey] = usersJson;

    return true;
  }

  Future<User?> getUserByEmail(String email) async {
    final users = await getUsers();
    try {
      return users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserById(int id) async {
    final users = await getUsers();
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // 清除所有数据
  Future<void> clearAll() async {
    await init();

    _localStorage.remove(_eventsKey);
    _localStorage.remove(_tasksKey);
    _localStorage.remove(_usersKey);
    _localStorage.remove(_counterKey);
  }

  // 数据统计
  Future<Map<String, int>> getDataStats() async {
    final events = await getEvents();
    final tasks = await getTasks();
    final users = await getUsers();

    return {
      'events': events.length,
      'tasks': tasks.length,
      'users': users.length,
    };
  }
}
