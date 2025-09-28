import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../models/todo_event.dart';
import '../utils/constants.dart';
import 'web_storage_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  WebStorageService? _webStorage;

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('Use WebStorageService for web platform');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  WebStorageService get webStorage {
    if (!kIsWeb) {
      throw UnsupportedError(
          'WebStorageService is only available on web platform');
    }
    _webStorage ??= WebStorageService();
    return _webStorage!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('Use WebStorageService for web platform');
    }

    try {
      // 桌面平台初始化FFI
      if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      // 移动平台使用默认的sqflite

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'todolist.db');

      return await openDatabase(
        path,
        version: 2, // 增加版本号以支持二级任务
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw Exception('Database initialization failed: ${e.toString()}');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建用户表
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        local_id TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // 创建事件表
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        due_date TEXT,
        is_completed INTEGER DEFAULT 0,
        priority TEXT DEFAULT 'medium',
        local_id TEXT,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 创建任务表（支持二级任务）
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        event_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        parent_task_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        due_date TEXT,
        status TEXT DEFAULT 'pending',
        priority TEXT DEFAULT 'medium',
        local_id TEXT,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (parent_task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX idx_events_user_id ON events (user_id)');
    await db.execute('CREATE INDEX idx_tasks_event_id ON tasks (event_id)');
    await db.execute('CREATE INDEX idx_tasks_user_id ON tasks (user_id)');
    await db.execute(
        'CREATE INDEX idx_tasks_parent_task_id ON tasks (parent_task_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 升级到版本2：添加父任务支持
      await db.execute('ALTER TABLE tasks ADD COLUMN parent_task_id INTEGER');
      await db.execute(
          'CREATE INDEX idx_tasks_parent_task_id ON tasks (parent_task_id)');
    }
  }

  // 事件相关操作
  Future<int> insertEvent(TodoEvent event, {String? localId}) async {
    if (kIsWeb) {
      return await webStorage.insertEvent(event);
    }
    final db = await database;
    return await db.insert(
        'events',
        {
          'id': event.id,
          'title': event.title,
          'description': event.description,
          'user_id': event.userId,
          'created_at': event.createdAt.toIso8601String(),
          'updated_at': event.updatedAt.toIso8601String(),
          'due_date': event.dueDate?.toIso8601String(),
          'is_completed': event.isCompleted ? 1 : 0,
          'priority': event.priority.name,
          'local_id': localId,
          'is_synced': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TodoEvent>> getEvents({int? userId, String? localId}) async {
    if (kIsWeb) {
      return await webStorage.getEvents(userId: userId);
    }
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause = 'user_id = ?';
      whereArgs.add(userId);
    }

    if (localId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'local_id = ?';
      whereArgs.add(localId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return TodoEvent(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        userId: map['user_id'],
        createdAt: DateTime.parse(map['created_at']),
        updatedAt: DateTime.parse(map['updated_at']),
        dueDate:
            map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
        isCompleted: map['is_completed'] == 1,
        priority: TaskPriority.values.firstWhere(
          (p) => p.name == map['priority'],
          orElse: () => TaskPriority.medium,
        ),
      );
    });
  }

  Future<bool> updateEvent(TodoEvent event) async {
    if (kIsWeb) {
      return await webStorage.updateEvent(event);
    }
    final db = await database;
    final count = await db.update(
      'events',
      {
        'title': event.title,
        'description': event.description,
        'updated_at': DateTime.now().toIso8601String(),
        'due_date': event.dueDate?.toIso8601String(),
        'is_completed': event.isCompleted ? 1 : 0,
        'priority': event.priority.name,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [event.id],
    );
    return count > 0;
  }

  Future<bool> deleteEvent(int eventId) async {
    if (kIsWeb) {
      return await webStorage.deleteEvent(eventId);
    }
    final db = await database;
    final count = await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [eventId],
    );
    return count > 0;
  }

  // 任务相关操作
  Future<int> insertTask(TodoTask task, {String? localId}) async {
    if (kIsWeb) {
      return await webStorage.insertTask(task);
    }
    final db = await database;
    return await db.insert(
        'tasks',
        {
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'event_id': task.eventId,
          'user_id': task.userId,
          'parent_task_id': task.parentTaskId,
          'created_at': task.createdAt.toIso8601String(),
          'updated_at': task.updatedAt.toIso8601String(),
          'due_date': task.dueDate?.toIso8601String(),
          'status': task.status.name,
          'priority': task.priority.name,
          'local_id': localId,
          'is_synced': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TodoTask>> getTasks(
      {int? eventId, int? userId, int? parentTaskId}) async {
    if (kIsWeb) {
      return await webStorage.getTasks(eventId: eventId, userId: userId);
    }
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (eventId != null) {
      whereClause = 'event_id = ?';
      whereArgs.add(eventId);
    }

    if (userId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'user_id = ?';
      whereArgs.add(userId);
    }

    if (parentTaskId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'parent_task_id = ?';
      whereArgs.add(parentTaskId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return TodoTask(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        eventId: map['event_id'],
        userId: map['user_id'],
        parentTaskId: map['parent_task_id'],
        createdAt: DateTime.parse(map['created_at']),
        updatedAt: DateTime.parse(map['updated_at']),
        dueDate:
            map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
        status: TaskStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => TaskStatus.pending,
        ),
        priority: TaskPriority.values.firstWhere(
          (p) => p.name == map['priority'],
          orElse: () => TaskPriority.medium,
        ),
      );
    });
  }

  // 用户相关操作
  Future<int> insertUser(User user, {String? localId}) async {
    if (kIsWeb) {
      return await webStorage.insertUser(user);
    }
    final db = await database;
    return await db.insert(
        'users',
        {
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'password_hash': '', // 简化处理
          'avatar_url': null,
          'created_at': user.createdAt.toIso8601String(),
          'updated_at': user.updatedAt.toIso8601String(),
          'local_id': localId,
          'is_synced': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserByEmail(String email) async {
    if (kIsWeb) {
      return await webStorage.getUserByEmail(email);
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // 获取单个事件
  Future<TodoEvent?> getEvent(int eventId) async {
    if (kIsWeb) {
      final events = await webStorage.getEvents();
      try {
        return events.firstWhere((event) => event.id == eventId);
      } catch (e) {
        return null;
      }
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [eventId],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return TodoEvent(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      isCompleted: map['is_completed'] == 1,
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
    );
  }

  // 获取当前用户
  Future<User?> getCurrentUser() async {
    if (kIsWeb) {
      final users = await webStorage.getUsers();
      return users.isNotEmpty ? users.first : null;
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      limit: 1,
      orderBy: 'created_at DESC',
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  // 更新任务
  Future<bool> updateTask(TodoTask task) async {
    if (kIsWeb) {
      return await webStorage.updateTask(task);
    }
    final db = await database;
    final count = await db.update(
      'tasks',
      {
        'title': task.title,
        'description': task.description,
        'updated_at': DateTime.now().toIso8601String(),
        'due_date': task.dueDate?.toIso8601String(),
        'status': task.status.name,
        'priority': task.priority.name,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return count > 0;
  }

  // 删除任务
  Future<bool> deleteTask(int taskId) async {
    if (kIsWeb) {
      return await webStorage.deleteTask(taskId);
    }
    final db = await database;
    final count = await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
    return count > 0;
  }

  // 清除所有数据
  Future<void> clearAllData() async {
    if (kIsWeb) {
      return await webStorage.clearAll();
    }
    final db = await database;
    await db.delete('tasks');
    await db.delete('events');
    await db.delete('users');
  }

  // 获取未同步的记录
  Future<List<Map<String, dynamic>>> getUnsyncedRecords() async {
    if (kIsWeb) {
      // Web平台不需要同步
      return [];
    }
    final db = await database;
    final List<Map<String, dynamic>> records = [];

    // 获取未同步的事件
    final events =
        await db.query('events', where: 'is_synced = ?', whereArgs: [0]);
    for (final event in events) {
      records.add({...event, 'table': 'events'});
    }

    // 获取未同步的任务
    final tasks =
        await db.query('tasks', where: 'is_synced = ?', whereArgs: [0]);
    for (final task in tasks) {
      records.add({...task, 'table': 'tasks'});
    }

    return records;
  }

  // 标记为已同步
  Future<void> markAsSynced(String tableName, int id) async {
    if (kIsWeb) {
      // Web平台不需要同步
      return;
    }
    final db = await database;
    await db.update(
      tableName,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 清理方法
  Future<void> close() async {
    if (kIsWeb) return;
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
