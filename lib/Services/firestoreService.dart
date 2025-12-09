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
      'photoUrl': null, // <--- Initialize as null
      'points': 0,
      'favorited_lessons': [],
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 2. Stream User Data
  Stream<UserModel> streamUserProfile(String uid) {
    return _db.collection(_usersCollection).doc(uid).snapshots().map((doc) {
      return UserModel.fromFirestore(doc);
    });
  }

  // 3. Mark Lesson as Completed
  Future<void> completeLesson(String userId, String lessonId) async {
    final docId = '${userId}_$lessonId';
    final progressRef = _db.collection(_progressCollection).doc(docId);
    final userRef = _db.collection(_usersCollection).doc(userId);

    await _db.runTransaction((transaction) async {
      DocumentSnapshot progressDoc = await transaction.get(progressRef);
      
      if (!progressDoc.exists || !(progressDoc.get('completed') ?? false)) {
        transaction.set(progressRef, {
          'user_id': userId,
          'lesson_id': lessonId,
          'completed': true,
          'last_accessed': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        transaction.set(userRef, {
          'points': FieldValue.increment(10)
        }, SetOptions(merge: true));
      }
    });
  }

  // 4. Get Completed Lesson Count
  Stream<int> streamCompletedLessonCount(String userId) {
    return _db
        .collection(_progressCollection)
        .where('user_id', isEqualTo: userId)
        .where('completed', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // 5. Check if lesson is completed
  Stream<bool> isLessonCompleted(String userId, String lessonId) {
    final docId = '${userId}_$lessonId';
    return _db.collection(_progressCollection).doc(docId).snapshots().map((doc) {
      return doc.exists && (doc.data()?['completed'] == true);
    });
  }

  // 6. NEW: Toggle Favorite
  Future<void> toggleFavorite(String uid, String languageTitle) async {
    final userRef = _db.collection(_usersCollection).doc(uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> currentFavs = doc.data()?['favorited_lessons'] ?? [];
      
      if (currentFavs.contains(languageTitle)) {
        currentFavs.remove(languageTitle); // Remove if exists
      } else {
        currentFavs.add(languageTitle); // Add if doesn't exist
      }
      
      await userRef.update({'favorited_lessons': currentFavs});
    }
  }
  Future<void> updateUserPhoto(String uid, String url) async {
    await _db.collection(_usersCollection).doc(uid).update({
      'photoUrl': url,
    });
  }
}
