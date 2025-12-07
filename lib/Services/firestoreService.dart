import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/app_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  final String _usersCollection = 'users';
  final String _progressCollection = 'user_progress';

  // 1. Create User Profile
  Future<void> saveNewUserProfile(String uid, String email) async {
    await _db.collection(_usersCollection).doc(uid).set({
      'email': email,
      'displayName': email.split('@').first,
      'points': 0, // NEW: Gamification points
      'favorited_lessons': [],
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 2. Stream User Data (Real-time Profile)
  Stream<UserModel> streamUserProfile(String uid) {
    return _db.collection(_usersCollection).doc(uid).snapshots().map((doc) {
      return UserModel.fromFirestore(doc); // Ensure your UserModel handles 'points'
    });
  }

  // 3. Mark Lesson as Completed & Award Points
  Future<void> completeLesson(String userId, String lessonId) async {
    final docId = '${userId}_$lessonId';
    final progressRef = _db.collection(_progressCollection).doc(docId);
    final userRef = _db.collection(_usersCollection).doc(userId);

    // Run as a transaction to ensure points aren't added twice
    await _db.runTransaction((transaction) async {
      DocumentSnapshot progressDoc = await transaction.get(progressRef);
      
      if (!progressDoc.exists || !(progressDoc.get('completed') ?? false)) {
        // First time completing this lesson
        transaction.set(progressRef, {
          'user_id': userId,
          'lesson_id': lessonId,
          'completed': true,
          'last_accessed': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Award 10 points
        transaction.update(userRef, {
          'points': FieldValue.increment(10)
        });
      }
    });
  }

  // 4. Get Completed Lesson Count (For Progress Bar)
  Stream<int> streamCompletedLessonCount(String userId) {
    return _db
        .collection(_progressCollection)
        .where('user_id', isEqualTo: userId)
        .where('completed', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // 5. Check if a specific lesson is completed
  Stream<bool> isLessonCompleted(String userId, String lessonId) {
    final docId = '${userId}_$lessonId';
    return _db.collection(_progressCollection).doc(docId).snapshots().map((doc) {
      return doc.exists && (doc.data()?['completed'] == true);
    });
  }
}