import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/app_models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // --- COLLECTION REFERENCES ---
  final String _usersCollection = 'users';
  final String _lessonsCollection = 'lessons';
  final String _progressCollection = 'user_progress';
  final String _languagesCollection = 'languages';
  final String _questionsCollection = 'questions';

  // =========================================================
  // 1. USER OPERATIONS (users Collection)
  // =========================================================

  // Create or Update user profile upon registration/login
  Future<void> saveNewUserProfile(String uid, String email) async {
    await _db.collection(_usersCollection).doc(uid).set({
      'email': email,
      'displayName': email.split('@').first,
      'favorited_lessons': [],
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  
  // Get current user profile data
  Stream<UserModel> streamUserProfile(String uid) {
    return _db.collection(_usersCollection).doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      // Return a default model if user profile is missing (should not happen after registration)
      return UserModel(uid: uid, email: 'unknown@user.com'); 
    });
  }

  // Toggle favorite status for a lesson
  Future<void> toggleFavoriteLesson(String lessonId, bool isFavorited) async {
    if (currentUserId == null) return;

    final userRef = _db.collection(_usersCollection).doc(currentUserId);

    await userRef.update({
      'favorited_lessons': isFavorited
          ? FieldValue.arrayRemove([lessonId])
          : FieldValue.arrayUnion([lessonId]),
    });
  }

  // =========================================================
  // 2. LESSON AND LANGUAGE OPERATIONS
  // =========================================================

  // Stream all languages for the Home Page
  Stream<List<Map<String, dynamic>>> streamAllLanguages() {
    return _db.collection(_languagesCollection)
        .orderBy('title') // Example order
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Get all lessons for a specific language (for a lesson list screen)
  Stream<List<LessonModel>> streamLessonsByLanguage(String languageId) {
    return _db.collection(_lessonsCollection)
        .where('language_id', isEqualTo: languageId)
        .orderBy('lesson_number')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => LessonModel.fromFirestore(doc)).toList()
        );
  }


  // =========================================================
  // 3. PROGRESS AND QUIZ OPERATIONS (Adaptive Tracking)
  // =========================================================

  // Get a specific lesson's progress for the current user
  Stream<ProgressModel> streamProgressForLesson(String lessonId) {
    if (currentUserId == null) {
      return Stream.value(ProgressModel(userId: 'guest', lessonId: lessonId));
    }
    
    // Composite Document ID: user_id + lesson_id
    final docId = '${currentUserId!}_$lessonId'; 
    
    return _db.collection(_progressCollection).doc(docId).snapshots().map((doc) {
      if (doc.exists) {
        return ProgressModel.fromFirestore(doc);
      }
      // Return default progress if document doesn't exist yet
      return ProgressModel(userId: currentUserId!, lessonId: lessonId);
    });
  }

  // Update progress after completing a lesson or quiz
  Future<void> updateProgress({
    required String lessonId,
    bool? completed, // Set to true when content is read
    int? score, // Quiz score
    List<String>? newIncorrectQuestions, // List of QIDs missed in the attempt
  }) async {
    if (currentUserId == null) return;
    
    final docId = '${currentUserId!}_$lessonId';
    final progressRef = _db.collection(_progressCollection).doc(docId);

    // Get the current progress data to correctly calculate bestScore/attempts
    final currentDoc = await progressRef.get();
    final currentProgress = currentDoc.exists 
        ? ProgressModel.fromFirestore(currentDoc) 
        : ProgressModel(userId: currentUserId!, lessonId: lessonId);

    Map<String, dynamic> updateData = {
      'user_id': currentUserId,
      'lesson_id': lessonId,
      'last_accessed': FieldValue.serverTimestamp(),
      'completed': completed ?? currentProgress.completed,
    };
    
    // Logic for adaptive tracking fields (only if score is provided)
    if (score != null) {
      updateData['attempts_count'] = currentProgress.attemptsCount + 1;
      updateData['best_score'] = (score > currentProgress.bestScore) ? score : currentProgress.bestScore;
      
      // Merge incorrect questions into the existing list
      if (newIncorrectQuestions != null && newIncorrectQuestions.isNotEmpty) {
        // Collect existing incorrect IDs and add the new ones, then convert back to a list
        Set<String> allIncorrect = Set<String>.from(currentProgress.incorrectQuestionIds);
        allIncorrect.addAll(newIncorrectQuestions);
        updateData['incorrect_question_ids'] = allIncorrect.toList();
      }
    }

    // Use set with merge: true to create or update the document atomically
    await progressRef.set(updateData, SetOptions(merge: true));
  }

  // =========================================================
  // 4. QUESTION DATA (questions Collection)
  // =========================================================

  // Get all questions for a specific quiz ID (used by the quiz screen)
  Future<List<QuestionModel>> getQuestionsForQuiz(String quizId) async {
    final snapshot = await _db.collection(_questionsCollection)
        .where('lesson_id', isEqualTo: quizId) // Assuming quizId is the same as lesson_id for simplicity
        .get();
    
    return snapshot.docs.map((doc) => QuestionModel.fromFirestore(doc)).toList();
  }
}