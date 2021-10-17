import 'package:calendar_app/model/task_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TasksDatabase {
  static final TasksDatabase instance = TasksDatabase._init();

  static Database? _database;

  TasksDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $tableTasks ( 
  ${TaskFields.id} $idType, 
  ${TaskFields.isImportant} $boolType,
  ${TaskFields.date} $textType,
  ${TaskFields.title} $textType,
  ${TaskFields.description} $textType,
  ${TaskFields.time} $textType,
  ${TaskFields.year} $integerType,
  ${TaskFields.month} $integerType,
  ${TaskFields.day} $integerType
  )
''');
  }

  Future<Task> create(Task task) async {
    final db = await instance.database;
    final id = await db.insert(tableTasks, task.toJson());
    return task.copy(id: id);
  }

  Future<Task> readTask(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableTasks,
      columns: TaskFields.values,
      where: '${TaskFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Task>> readAllTasks() async {
    final db = await instance.database;

    final orderBy = '${TaskFields.time} ASC';
    final result = await db.query(tableTasks, orderBy: orderBy);

    return result.map((json) => Task.fromJson(json)).toList();
  }

  Future<int> update(Task task) async {
    final db = await instance.database;

    return db.update(
      tableTasks,
      task.toJson(),
      where: '${TaskFields.id} = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableTasks,
      where: '${TaskFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
