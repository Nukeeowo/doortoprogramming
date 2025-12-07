import 'package:cloud_firestore/cloud_firestore.dart';

// --- 1. USER MODEL (users Collection) ---
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final List<String> favoritedLessonIds; // Enhanced field

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.favoritedLessonIds = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return UserModel(
      uid: doc.id,
      email: data?['email'] ?? '',
      displayName: data?['displayName'],
      favoritedLessonIds: List<String>.from(data?['favorited_lessons'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'favorited_lessons': favoritedLessonIds,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}

// --- 2. LESSON MODEL (lessons Collection) ---
class LessonModel {
  final String id;
  final String title;
  final String languageId;
  final int lessonNumber;
  final List<Map<String, dynamic>> contentBlocks;
  final String quizId;

  LessonModel({
    required this.id,
    required this.title,
    required this.languageId,
    required this.lessonNumber,
    required this.contentBlocks,
    required this.quizId,
  });

  factory LessonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return LessonModel(
      id: doc.id,
      title: data?['title'] ?? 'Untitled Lesson',
      languageId: data?['language_id'] ?? '',
      lessonNumber: data?['lesson_number'] ?? 0,
      contentBlocks: List<Map<String, dynamic>>.from(data?['content_blocks'] ?? []),
      quizId: data?['quiz_id'] ?? '',
    );
  }
}

// --- 3. PROGRESS MODEL (user_progress Collection - Adaptive Tracking) ---
class ProgressModel {
  final String userId;
  final String lessonId;
  final bool completed;
  final int bestScore; // Deeper Tracking
  final int attemptsCount; // Deeper Tracking
  final List<String> incorrectQuestionIds; // Deeper Tracking

  ProgressModel({
    required this.userId,
    required this.lessonId,
    this.completed = false,
    this.bestScore = 0,
    this.attemptsCount = 0,
    this.incorrectQuestionIds = const [],
  });

  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return ProgressModel(
      userId: data?['user_id'] ?? '',
      lessonId: data?['lesson_id'] ?? '',
      completed: data?['completed'] ?? false,
      bestScore: data?['best_score'] ?? 0,
      attemptsCount: data?['attempts_count'] ?? 0,
      incorrectQuestionIds: List<String>.from(data?['incorrect_question_ids'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'lesson_id': lessonId,
      'completed': completed,
      'last_accessed': FieldValue.serverTimestamp(),
      'best_score': bestScore,
      'attempts_count': attemptsCount,
      'incorrect_question_ids': incorrectQuestionIds,
    };
  }
}

// --- 4. QUESTION MODEL (questions Collection) ---
class QuestionModel {
  final String id;
  final String lessonId;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation; // Deeper Tracking

  QuestionModel({
    required this.id,
    required this.lessonId,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return QuestionModel(
      id: doc.id,
      lessonId: data?['lesson_id'] ?? '',
      questionText: data?['question_text'] ?? '',
      options: List<String>.from(data?['options'] ?? []),
      correctAnswerIndex: data?['correct_answer_index'] ?? 0,
      explanation: data?['explanation'] ?? '',
    );
  }
}