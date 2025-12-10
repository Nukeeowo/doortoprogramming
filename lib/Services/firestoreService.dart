import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:door_to_programming/Lessons/lesson_data.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  

  final String _usersCollection = 'users';
  final String _progressCollection = 'user_progress';
  final String _languagesCollection = 'languages';

  Future<void> saveNewUserProfile(String uid, String email) async {
    await _db.collection(_usersCollection).doc(uid).set({
      'email': email,
      'displayName': email.split('@').first,
      'points': 0,
      'favorited_lessons': [],
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<UserModel> streamUserProfile(String uid) {
    return _db.collection(_usersCollection).doc(uid).snapshots().map((doc) {
      return UserModel.fromFirestore(doc);
    });
  }

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

  Stream<int> streamCompletedLessonCount(String userId) {
    return _db
        .collection(_progressCollection)
        .where('user_id', isEqualTo: userId)
        .where('completed', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<bool> isLessonCompleted(String userId, String lessonId) {
    final docId = '${userId}_$lessonId';
    return _db.collection(_progressCollection).doc(docId).snapshots().map((doc) {
      return doc.exists && (doc.data()?['completed'] == true);
    });
  }

  Future<void> toggleFavorite(String uid, String languageTitle) async {
    final userRef = _db.collection(_usersCollection).doc(uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> currentFavs = doc.data()?['favorited_lessons'] ?? [];
      
      if (currentFavs.contains(languageTitle)) {
        currentFavs.remove(languageTitle);
      } else {
        currentFavs.add(languageTitle);
      }
      
      await userRef.update({'favorited_lessons': currentFavs});
    }
  }
  Future<void> updateUserPhoto(String uid, String url) async {
    await _db.collection(_usersCollection).doc(uid).update({
      'photoUrl': url,
    });
  }
Stream<List<ProgrammingLanguage>> streamLanguages() {
    return _db.collection(_languagesCollection).orderBy('id').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        String colorString = data['colorHex']?.toString() ?? '';
        int colorValue = int.tryParse(colorString) ?? 0xFF000000;

        return ProgrammingLanguage(
          title: data['title'] ?? 'Untitled', 
          imagePath: data['imagePath'] ?? 'assets/lock.png',
          color: Color(colorValue), 
          lessons: (data['lessons'] as List<dynamic>? ?? []).map((l) {
            return Lesson(
              id: l['id'] is int ? l['id'] : int.tryParse(l['id'].toString()) ?? 0,
              title: l['title'] ?? 'No Title',
              sections: (l['sections'] as List<dynamic>? ?? []).map((s) => LessonSection(
                heading: s['heading'] ?? '',
                content: s['content'] ?? '',
                codeSnippet: s['codeSnippet'],
                isHighlighted: s['isHighlighted'] ?? false,
              )).toList(),
              quiz: Quiz(
                title: l['quiz'] != null ? l['quiz']['title'] ?? 'Quiz' : 'Quiz',
                questions: (l['quiz'] != null && l['quiz']['questions'] != null) 
                    ? (l['quiz']['questions'] as List<dynamic>).map((q) => QuizQuestion(
                        questionText: q['questionText'] ?? '',
                        options: List<String>.from(q['options'] ?? []),
                        correctAnswerIndex: q['correctAnswerIndex'] is int 
                            ? q['correctAnswerIndex'] 
                            : int.tryParse(q['correctAnswerIndex'].toString()) ?? 0,
                      )).toList()
                    : [],
              ),
            );
          }).toList(),
        );
      }).toList();
    });
  }
}