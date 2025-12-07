import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:door_to_programming/Lessons/lesson_data.dart';
import 'package:door_to_programming/Services/firestoreService.dart'; // Import Firestore Service
import 'quiz_page.dart';

class LanguageLessonScreen extends StatefulWidget {
  final User user; // <--- CHANGED: Now accepts Firebase User
  final Lesson lesson;
  final Color languageColor;

  const LanguageLessonScreen({
    super.key,
    required this.user,
    required this.lesson,
    required this.languageColor,
  });

  @override
  State<LanguageLessonScreen> createState() => _LanguageLessonScreenState();
}

class _LanguageLessonScreenState extends State<LanguageLessonScreen> {
  final FirestoreService _firestoreService = FirestoreService(); // Use Firestore
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    // No need to manually check status here if we use StreamBuilder in the UI,
    // but we can keep a listener if you prefer local state.
    // For simplicity, we will stick to the Stream in the UI build method.
  }

  void _markAsCompleted() async {
    // <--- CHANGED: Use Firestore Service
    await _firestoreService.completeLesson(widget.user.uid, widget.lesson.id.toString());
    
    if (mounted) {
      setState(() {
        _isCompleted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Хичээл дууслаа! +10 оноо')),
      );
    }
  }

  void _navigateToQuiz() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPage(
          user: widget.user, // <--- NOTE: Ensure QuizPage also accepts User!
          lessonId: widget.lesson.id, // Ensure ID is string
          quiz: widget.lesson.quiz,
          lessonTitle: widget.lesson.title,
          languageColor: widget.languageColor,
        ),
      ),
    );

    if (result == true) {
      _markAsCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.languageColor,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // <--- CHANGED: Badge now listens to Firestore Stream
                StreamBuilder<bool>(
                  stream: _firestoreService.isLessonCompleted(widget.user.uid, widget.lesson.id.toString()),
                  builder: (context, snapshot) {
                    final isCompleted = snapshot.data ?? false;
                    // Update local state so the bottom button knows too
                    if (isCompleted != _isCompleted) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _isCompleted = true);
                      });
                    }
                    return _buildStatusBadge(isCompleted);
                  },
                ),
                const SizedBox(height: 20),

                ...widget.lesson.sections.map((section) => _buildSection(context, section)),
                
                const SizedBox(height: 40),

                _buildQuizButton(),
                
                const SizedBox(height: 40),

                // Only show mark button if NOT completed
                if (!_isCompleted)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _markAsCompleted,
                      icon: const Icon(Icons.done_all, color: Colors.green),
                      label: const Text('Уншиж дууссан гэж тэмдэглэх'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle_outline : Icons.pending_actions,
            color: isCompleted ? Colors.green : Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 5),
          Text(
            isCompleted ? 'Хичээл дууссан' : 'Хичээл дуусаагүй',
            style: TextStyle(
              color: isCompleted ? Colors.green.shade900 : Colors.orange.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ... (Keep _buildSection and _buildQuizButton exactly as they were in your original code)
  Widget _buildSection(BuildContext context, LessonSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: widget.languageColor.withOpacity(0.9),
            ),
          ),
          const Divider(height: 15),
          Text(
            section.content,
            style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          ),
          if (section.codeSnippet != null) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                section.codeSnippet!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizButton() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [widget.languageColor.withOpacity(0.9), widget.languageColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: _navigateToQuiz,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const Icon(Icons.quiz, color: Colors.white, size: 30),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Дадлагын шалгалт: ${widget.lesson.quiz.title}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Өөрийн мэдлэгийг шалгаж, хичээлээ дуусгаарай.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}