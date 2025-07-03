import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasky.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users(
        uid TEXT PRIMARY KEY,
        pseudo TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        profileLetter TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Create tasks table
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        completedAt INTEGER,
        userId TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (uid) ON DELETE CASCADE
      )
    ''');
  }

  // User operations
  Future<void> insertUser(UserModel user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser(String uid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'uid = ?',
      whereArgs: [user.uid],
    );
  }

  Future<void> deleteUser(String uid) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // Task operations
  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    Map<String, dynamic> taskMap = task.toMap();
    taskMap.remove('id'); // Remove id for auto-increment
    return await db.insert('tasks', taskMap);
  }

  Future<List<TaskModel>> getTasks(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return TaskModel.fromMap(maps[i], maps[i]['id'].toString());
    });
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [int.parse(task.id)],
    );
  }

  Future<void> deleteTask(String taskId) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [int.parse(taskId)],
    );
  }

  Future<Map<String, int>> getTaskStats(String userId) async {
    final db = await database;
    
    // Get total tasks
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE userId = ?',
      [userId],
    );
    int totalTasks = totalResult.first['count'] as int;

    // Get completed tasks
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE userId = ? AND status = ?',
      [userId, 'completed'],
    );
    int completedTasks = completedResult.first['count'] as int;

    int pendingTasks = totalTasks - completedTasks;

    return {
      'total': totalTasks,
      'completed': completedTasks,
      'pending': pendingTasks,
    };
  }

  // Stream for tasks (simulated with periodic updates)
  Stream<List<TaskModel>> getTasksStream(String userId) {
    late StreamController<List<TaskModel>> controller;
    Timer? timer;

    controller = StreamController<List<TaskModel>>(
      onListen: () {
        // Send initial data
        getTasks(userId).then((tasks) {
          if (!controller.isClosed) {
            controller.add(tasks);
          }
        });

        // Set up periodic updates
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          getTasks(userId).then((tasks) {
            if (!controller.isClosed) {
              controller.add(tasks);
            }
          });
        });
      },
      onCancel: () {
        timer?.cancel();
      },
    );

    return controller.stream;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}