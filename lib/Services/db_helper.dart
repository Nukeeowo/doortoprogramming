import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DBHelper {
  static Database? _db;
  static const _secureStorage = FlutterSecureStorage();
  static const String DB_NAME = 'users.db';
  static const String USER_TABLE = 'users';
  // New table names
  static const String PROGRESS_TABLE = 'lesson_progress';
  static const String SCORES_TABLE = 'quiz_scores';


  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), DB_NAME);
    // Note: We need to increment the version number to trigger onCreate/onUpgrade
    // Since this is the first time adding new tables, we change version to 2
    return await openDatabase(path, version: 2, onCreate: (db, version) async {
      // 1. User table (Existing)
      await db.execute('''
        CREATE TABLE $USER_TABLE (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE
        )
      ''');
      // 2. Lesson Progress Table (New)
      await db.execute('''
        CREATE TABLE $PROGRESS_TABLE (
          user_id INTEGER,
          lesson_id INTEGER,
          is_completed INTEGER NOT NULL DEFAULT 0, -- 0 for false, 1 for true
          PRIMARY KEY (user_id, lesson_id),
          FOREIGN KEY (user_id) REFERENCES $USER_TABLE(id)
        )
      ''');
      // 3. Quiz Scores Table (New)
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
      // Handle upgrades if users already have V1 of the database
      if (oldVersion < 2) {
        // Create Lesson Progress Table
        await db.execute('''
          CREATE TABLE $PROGRESS_TABLE (
            user_id INTEGER,
            lesson_id INTEGER,
            is_completed INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (user_id, lesson_id),
            FOREIGN KEY (user_id) REFERENCES $USER_TABLE(id)
          )
        ''');
        // Create Quiz Scores Table
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
    if (result.isNotEmpty) return -1; // user already exists

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
      // Update password in Secure Storage
      await _secureStorage.write(key: email, value: newPassword);
      // Return 1 for success
      return 1;
    }
    // Return 0 if user not found
    return 0;
  }
  
  // --- NEW: Lesson Progress Methods ---

  static Future<bool> isLessonCompleted(int userId, int lessonId) async {
    final dbClient = await db;
    final result = await dbClient.query(
      PROGRESS_TABLE,
      where: 'user_id = ? AND lesson_id = ?',
      whereArgs: [userId, lessonId],
    );
    // Check if the lesson is marked as completed (is_completed = 1)
    return result.isNotEmpty && (result.first['is_completed'] == 1);
  }

  static Future<void> markLessonCompleted(int userId, int lessonId) async {
    final dbClient = await db;
    await dbClient.insert(
      PROGRESS_TABLE,
      {'user_id': userId, 'lesson_id': lessonId, 'is_completed': 1},
      conflictAlgorithm: ConflictAlgorithm.replace, // Upsert: update if exists
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

  // --- NEW: Quiz Scores Methods ---

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
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Get the current user stream for automatic sign-in checking
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 2. Replaces DBHelper.registerUser
  Future<User?> registerUser(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      // Handle Firebase errors (e.g., 'email-already-in-use', 'weak-password')
      // The calling UI function will handle the error message based on return null.
      return null;
    } catch (e) {
      // General error
      return null;
    }
  }

  // 3. Replaces DBHelper.loginUser
  Future<User?> loginUser(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      // Handle Firebase errors (e.g., 'user-not-found', 'wrong-password')
      return null;
    } catch (e) {
      return null;
    }
  }

  // 4. Replaces DBHelper.resetPassword
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true; // Success: Email sent
    } on FirebaseAuthException {
      // Handle Firebase errors (e.g., 'user-not-found')
      return false; // Failure
    }
  }

  // 5. New function to handle sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}