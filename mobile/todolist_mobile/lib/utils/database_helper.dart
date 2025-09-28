import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/todo_model.dart'; // Import the Todo model

class DatabaseHelper {
  static const _databaseName = "ToDoDatabase.db";
  static const _databaseVersion = 1; // Increment this if schema changes

  static const tableTodos = 'todos';
  static const columnId = 'id'; // Primary Key
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnIsCompleted = 'isCompleted';
  static const columnUserId = 'userId';
  static const columnCreatedAt = 'createdAt';
  static const columnUpdatedAt = 'updatedAt';
  static const columnIsSynced = 'isSynced';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        // onUpgrade: _onUpgrade, // Add this if you need to handle schema migrations
        );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableTodos (
            $columnId TEXT PRIMARY KEY,
            $columnTitle TEXT NOT NULL,
            $columnDescription TEXT,
            $columnIsCompleted INTEGER NOT NULL DEFAULT 0,
            $columnUserId TEXT,
            $columnCreatedAt TEXT,
            $columnUpdatedAt TEXT,
            $columnIsSynced INTEGER NOT NULL DEFAULT 1
          )
          ''');
  }

  // Optional: Add onUpgrade for schema migrations if you change the table structure in the future
  // Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  //   if (oldVersion < newVersion) {
  //     // Example: if oldVersion is 1 and newVersion is 2, add a new column
  //     // await db.execute("ALTER TABLE $tableTodos ADD COLUMN newColumn TEXT;");
  //   }
  // }

  // --- CRUD Methods for Todos ---

  // Insert a Todo
  Future<int> insertTodo(Todo todo) async {
    Database db = await instance.database;
    // Use insert with conflictAlgorithm.replace to handle cases where an ID might already exist
    // (e.g., syncing from server after local creation with a temporary ID)
    // Or, if IDs are always unique (e.g., UUIDs), conflictAlgorithm.fail is fine.
    return await db.insert(tableTodos, todo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all Todos (optionally filter by userId or sync status)
  Future<List<Todo>> getAllTodos({String? userId, bool? isSynced}) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (userId != null && isSynced != null) {
      whereClause = '$columnUserId = ? AND $columnIsSynced = ?';
      whereArgs = [userId, isSynced ? 1 : 0];
    } else if (userId != null) {
      whereClause = '$columnUserId = ?';
      whereArgs = [userId];
    } else if (isSynced != null) {
      whereClause = '$columnIsSynced = ?';
      whereArgs = [isSynced ? 1 : 0];
    }

    maps = await db.query(tableTodos, where: whereClause, whereArgs: whereArgs, orderBy: '$columnCreatedAt DESC');
    
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  // Get a single Todo by ID
  Future<Todo?> getTodoById(String id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(tableTodos,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1);
    if (maps.isNotEmpty) {
      return Todo.fromMap(maps.first);
    }
    return null;
  }

  // Update a Todo
  Future<int> updateTodo(Todo todo) async {
    Database db = await instance.database;
    return await db.update(tableTodos, todo.toMap(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  // Delete a Todo by ID
  Future<int> deleteTodo(String id) async {
    Database db = await instance.database;
    return await db.delete(tableTodos, where: '$columnId = ?', whereArgs: [id]);
  }

  // Delete all todos (e.g., on logout or for testing)
  Future<int> clearAllTodos({String? userId}) async {
    Database db = await instance.database;
    if (userId != null) {
      return await db.delete(tableTodos, where: '$columnUserId = ?', whereArgs: [userId]);
    }
    return await db.delete(tableTodos);
  }

  // Batch insert/update todos (useful for syncing)
  Future<void> upsertTodos(List<Todo> todos) async {
    Database db = await instance.database;
    Batch batch = db.batch();
    for (var todo in todos) {
      batch.insert(tableTodos, todo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
