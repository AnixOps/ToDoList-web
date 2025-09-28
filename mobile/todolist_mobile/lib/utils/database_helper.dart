import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// 假设您的Todo模型类大致如下，如果不同，请进行调整
// class Todo {
//   final String id;
//   final String title;
//   final String? description;
//   final bool isCompleted;
//   // 可能还有 userId, createdAt, updatedAt等字段

//   Todo({
//     required this.id,
//     required this.title,
//     this.description,
//     required this.isCompleted,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'isCompleted': isCompleted ? 1 : 0,
//     };
//   }

//   static Todo fromMap(Map<String, dynamic> map) {
//     return Todo(
//       id: map['id'],
//       title: map['title'],
//       description: map['description'],
//       isCompleted: map['isCompleted'] == 1,
//     );
//   }
// }


class DatabaseHelper {
  static const _databaseName = "ToDoDatabase.db";
  static const _databaseVersion = 1;

  static const tableTodos = 'todos';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnIsCompleted = 'isCompleted';
  // 考虑添加:
  // static const columnUserId = 'userId';
  // static const columnCreatedAt = 'createdAt';
  // static const columnUpdatedAt = 'updatedAt';
  // static const columnIsSynced = 'isSynced'; // 用于追踪同步状态

  // 单例模式
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableTodos (
            $columnId TEXT PRIMARY KEY,
            $columnTitle TEXT NOT NULL,
            $columnDescription TEXT,
            $columnIsCompleted INTEGER NOT NULL DEFAULT 0
            // , $columnUserId TEXT
            // , $columnCreatedAt TEXT
            // , $columnUpdatedAt TEXT
            // , $columnIsSynced INTEGER DEFAULT 0
          )
          ''');
  }

  // 后续将在这里添加CRUD方法:
  // Future<int> insertTodo(Todo todo) async { ... }
  // Future<List<Todo>> getAllTodos() async { ... }
  // Future<int> updateTodo(Todo todo) async { ... }
  // Future<int> deleteTodo(String id) async { ... }
  // Future<void> clearTodos() async { ... }
}
