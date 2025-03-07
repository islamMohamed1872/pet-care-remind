import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _database;
  static const String tableName = 'tasks';

  static Future<Database> get database async {

    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {

    String path = join(await getDatabasesPath(), 'pet_care.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            date Text,
            time TEXT,
            notification INTEGER,
            repeat TEXT,
            repeatType TEXT,
            isCompleted INTEGER
          )
        ''').then((onValue){
          print("done!");
        }).catchError((onError){
          print("error!");
          print(onError);
        });
      },
    );
  }

  static Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.insert(tableName, task);
  }

  static Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query(tableName, orderBy: 'time ASC');
  }

  static Future<int> updateTask(int id, Map<String, dynamic> task) async {
    final db = await database;
    return await db.update(tableName, task, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> closeDB() async {
    final db = _database;
    if (db != null) await db.close();
  }
}
