import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;
  static const _secureStorage = FlutterSecureStorage();
  static const String DB_NAME = 'users.db';
  static const String USER_TABLE = 'users';
  static const String PROGRESS_TABLE = 'lesson_progress';
  static const String SCORES_TABLE = 'quiz_scores';


  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), DB_NAME);
    return await openDatabase(path, version: 2, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE $USER_TABLE (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE
        )
      ''');
      await db.execute('''
        CREATE TABLE $PROGRESS_TABLE (
          user_id INTEGER,
          lesson_id INTEGER,
          is_completed INTEGER NOT NULL DEFAULT 0, -- 0 for false, 1 for true
          PRIMARY KEY (user_id, lesson_id),
          FOREIGN KEY (user_id) REFERENCES $USER_TABLE(id)
        )
      ''');
      await db.execute('''
        CREATE TABLE $SCORES_TABLE (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          lesson_id INTEGER,
          score INTEGER NOT NULL,
          total_questions INTEGER NOT NULL,
          timestamp INTEGER,
          FOREIGN KEY (user_id) REFERENCES $USER_TABLE(id)
        )
      ''');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
          CREATE TABLE $PROGRESS_TABLE (
            user_id INTEGER,
            lesson_id INTEGER,
            is_completed INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (user_id, lesson_id),
            FOREIGN KEY (user_id) REFERENCES $USER_TABLE(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE $SCORES_TABLE (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            lesson_id INTEGER,
            score INTEGER NOT NULL,
            total_questions INTEGER NOT NULL,
            timestamp INTEGER,
            FOREIGN KEY (user_id) REFERENCES $USER_TABLE(id)
          )
        ''');
      }
    });
  }

  static Future<int> registerUser(String email, String password) async {
    final dbClient = await db;
    final result = await dbClient.query(USER_TABLE, where: 'email = ?', whereArgs: [email]);
    if (result.isNotEmpty) return -1;

    final id = await dbClient.insert(USER_TABLE, {'email': email});
    if (id != -1) {
      await _secureStorage.write(key: email, value: password);
    }
    return id;
  }

  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final dbClient = await db;
    final result = await dbClient.query(
      USER_TABLE,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      final storedPassword = await _secureStorage.read(key: email);
      if (storedPassword == password) {
        return result.first;
      }
    }
    return null;
  }

  static Future<int> resetPassword(String email, String newPassword) async {
    final dbClient = await db;
    final result = await dbClient.query(USER_TABLE, where: 'email = ?', whereArgs: [email]);
    if (result.isNotEmpty) {
      await _secureStorage.write(key: email, value: newPassword);
      return 1;
    }
    return 0;
  }

  static Future<bool> isLessonCompleted(int userId, int lessonId) async {
    final dbClient = await db;
    final result = await dbClient.query(
      PROGRESS_TABLE,
      where: 'user_id = ? AND lesson_id = ?',
      whereArgs: [userId, lessonId],
    );
    return result.isNotEmpty && (result.first['is_completed'] == 1);
  }

  static Future<void> markLessonCompleted(int userId, int lessonId) async {
    final dbClient = await db;
    await dbClient.insert(
      PROGRESS_TABLE,
      {'user_id': userId, 'lesson_id': lessonId, 'is_completed': 1},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  static Future<int> getCompletedLessonCount(int userId) async {
    final dbClient = await db;
    final result = await dbClient.rawQuery('''
      SELECT COUNT(*) as count FROM $PROGRESS_TABLE 
      WHERE user_id = ? AND is_completed = 1
    ''', [userId]);
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<void> saveQuizScore(int userId, int lessonId, int score, int totalQuestions) async {
    final dbClient = await db;
    await dbClient.insert(
      SCORES_TABLE,
      {
        'user_id': userId,
        'lesson_id': lessonId,
        'score': score,
        'total_questions': totalQuestions,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  static Future<Map<String, dynamic>?> getLatestQuizScore(int userId, int lessonId) async {
    final dbClient = await db;
    final result = await dbClient.query(
      SCORES_TABLE,
      where: 'user_id = ? AND lesson_id = ?',
      whereArgs: [userId, lessonId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    
    return result.isNotEmpty ? result.first : null;
  }
}
