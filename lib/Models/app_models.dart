import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final int points; // <--- NEW: Added this field
  final List<String> favoritedLessonIds;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.points = 0, // <--- NEW: Default to 0
    this.favoritedLessonIds = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return UserModel(
      uid: doc.id,
      email: data?['email'] ?? '',
      displayName: data?['displayName'],
      points: data?['points'] ?? 0, // <--- NEW: Read from Firestore
      favoritedLessonIds: List<String>.from(data?['favorited_lessons'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'points': points, // <--- NEW: Write to Firestore
      'favorited_lessons': favoritedLessonIds,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}