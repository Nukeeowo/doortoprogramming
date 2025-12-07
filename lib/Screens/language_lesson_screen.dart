import 'package:flutter/material.dart';
import 'package:door_to_programming/Lessons/lesson_data.dart';
import 'quiz_page.dart';
import 'package:door_to_programming/Services/db_helper.dart';

class LanguageLessonScreen extends StatefulWidget {
  final Map<String, dynamic> user;
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
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus();
  }

  void _checkCompletionStatus() async {
    final userId = widget.user['id'] as int;
    final completed = await DBHelper.isLessonCompleted(userId, widget.lesson.id);
    if (mounted) {
      setState(() {
        _isCompleted = completed;
      });
    }
  }

  void _markAsCompleted() async {
    final userId = widget.user['id'] as int;
    await DBHelper.markLessonCompleted(userId, widget.lesson.id);
    if (mounted) {
      setState(() {
        _isCompleted = true;
      });
      // Optionally notify the parent (HomePage) to refresh progress display
    }
  }

  void _navigateToQuiz() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPage(
          user: widget.user,
          lessonId: widget.lesson.id,
          quiz: widget.lesson.quiz,
          lessonTitle: widget.lesson.title,
          languageColor: widget.languageColor,
        ),
      ),
    );

    // Check if the quiz was completed successfully and mark the lesson complete
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
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100), // Space for bottom button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Completion Status Badge
                _buildStatusBadge(),
                const SizedBox(height: 20),

                // Lesson Sections
                ...widget.lesson.sections.map((section) => _buildSection(context, section)),
                
                const SizedBox(height: 40),

                // Quiz Call to Action
                _buildQuizButton(),
                
                const SizedBox(height: 40),

                // Mark as Read Button (for non-quiz lessons, or manual mark)
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

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _isCompleted ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isCompleted ? Icons.check_circle_outline : Icons.pending_actions,
            color: _isCompleted ? Colors.green : Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 5),
          Text(
            _isCompleted ? 'Хичээл дууссан' : 'Хичээл дуусаагүй',
            style: TextStyle(
              color: _isCompleted ? Colors.green.shade900 : Colors.orange.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

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