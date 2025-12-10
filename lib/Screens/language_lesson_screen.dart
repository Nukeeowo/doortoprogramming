import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:door_to_programming/Lessons/lesson_data.dart';
import 'package:door_to_programming/Services/firestoreService.dart';
import 'package:door_to_programming/Models/app_models.dart'; 
import 'quiz_page.dart';
import 'code_playground.dart';

class LanguageLessonScreen extends StatelessWidget {
  final User user;
  final Lesson lesson;
  final Color languageColor;
  final String languageTitle;

  LanguageLessonScreen({
    super.key,
    required this.user,
    required this.lesson,
    required this.languageColor,
    required this.languageTitle,
  });

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      appBar: AppBar(
        backgroundColor: languageColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          lesson.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.code, color: Colors.white),
              tooltip: 'Open Compiler',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CodePlaygroundPage(
                      language: languageTitle,
                      initialCode: lesson.sections
                          .firstWhere((s) => s.codeSnippet != null, 
                              orElse: () => const LessonSection(heading: '', content: '', codeSnippet: ''))
                          .codeSnippet ?? '',
                    ),
                  ),
                );
              },
            ),
          StreamBuilder<UserModel>(
            
            stream: _firestoreService.streamUserProfile(user.uid),
            builder: (context, snapshot) {
              final favorites = snapshot.data?.favorites ?? [];
              final isFavorited = favorites.contains(languageTitle);

              return IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  _firestoreService.toggleFavorite(user.uid, languageTitle);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isFavorited 
                          ? '$languageTitle removed from favorites' 
                          : '$languageTitle added to favorites'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<bool>(
                    stream: _firestoreService.isLessonCompleted(user.uid, lesson.id.toString()),
                    builder: (context, snapshot) {
                      final isCompleted = snapshot.data ?? false;
                      if (!isCompleted) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "You have completed this lesson!",
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  ...lesson.sections.map((section) => _buildSection(section)),
                   
                  const SizedBox(height: 80), 
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizPage(
                      user: user,
                      lessonId: lesson.id,
                      lessonTitle: lesson.title,
                      quiz: lesson.quiz,
                      languageColor: languageColor,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: languageColor,
                elevation: 5,
                shadowColor: languageColor.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz, color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Start Quiz',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(LessonSection section) {
    if (section.isHighlighted) {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          color: languageColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: languageColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              decoration: BoxDecoration(
                color: languageColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
              ),
              child: section.heading.isNotEmpty
                  ? Text(
                      section.heading,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: languageColor.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      section.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (section.codeSnippet != null && section.codeSnippet!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildCodeSnippet(section.codeSnippet!),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.heading.isNotEmpty) ...[
            Text(
              section.heading,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            section.content,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
          if (section.codeSnippet != null && section.codeSnippet!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildCodeSnippet(section.codeSnippet!),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeSnippet(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _windowDot(const Color(0xFFFF5F56)),
              const SizedBox(width: 6),
              _windowDot(const Color(0xFFFFBD2E)),
              const SizedBox(width: 6),
              _windowDot(const Color(0xFF27C93F)),
            ],
          ),
          const SizedBox(height: 15),
          SelectableText(
            code,
            style: const TextStyle(
              fontFamily: 'Courier New',
              color: Color(0xFFD4D4D4),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _windowDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}