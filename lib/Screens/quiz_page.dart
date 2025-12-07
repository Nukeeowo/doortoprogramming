import 'package:flutter/material.dart';
import 'package:door_to_programming/Lessons/lesson_data.dart';
import 'package:door_to_programming/Services/db_helper.dart';

class QuizPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final int lessonId;
  final String lessonTitle;
  final Quiz quiz;
  final Color languageColor;

  const QuizPage({
    super.key,
    required this.user,
    required this.lessonId,
    required this.lessonTitle,
    required this.quiz,
    required this.languageColor,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  int _score = 0;
  bool _isAnswerChecked = false;

  void _checkAnswer() {
    if (_selectedAnswerIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Хариултаа сонгоно уу.')),
      );
      return;
    }

    setState(() {
      _isAnswerChecked = true;
      if (_selectedAnswerIndex ==
          widget.quiz.questions[_currentQuestionIndex].correctAnswerIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (!_isAnswerChecked) return;

    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _isAnswerChecked = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    final userId = widget.user['id'] as int;
    final totalQuestions = widget.quiz.questions.length;
    final success = _score > (totalQuestions / 2); // Pass if score is majority

    // 1. Save score to database
    await DBHelper.saveQuizScore(
      userId,
      widget.lessonId,
      _score,
      totalQuestions,
    );
    
    // 2. Display results
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            success ? 'Баяр хүргэе!' : 'Дахин оролдоорой!',
            style: TextStyle(color: success ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Та ${totalQuestions}-аас ${_score} оноо авлаа.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Return true to the lesson screen if passed
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(success); // Pop quiz page
              },
              child: Text(
                'Баталгаажуулах',
                style: TextStyle(color: widget.languageColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lessonTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: widget.languageColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(widget.languageColor),
            ),
            const SizedBox(height: 10),
            
            // Question Counter
            Text(
              'Асуулт ${_currentQuestionIndex + 1} / ${widget.quiz.questions.length}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // Question Text
            Text(
              currentQuestion.questionText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // Options List
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  return _buildOptionTile(
                    index,
                    currentQuestion.options[index],
                    index == currentQuestion.correctAnswerIndex,
                  );
                },
              ),
            ),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isAnswerChecked ? _nextQuestion : _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.languageColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  _isAnswerChecked 
                      ? (_currentQuestionIndex == widget.quiz.questions.length - 1 ? 'Төгсгөх' : 'Дараагийн асуулт')
                      : 'Хариулт шалгах',
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOptionTile(int index, String optionText, bool isCorrect) {
    bool isSelected = _selectedAnswerIndex == index;
    
    Color getTileColor() {
      if (!_isAnswerChecked) {
        return isSelected ? widget.languageColor.withOpacity(0.2) : Colors.white;
      }
      if (isSelected) {
        return isCorrect ? Colors.green.shade100 : Colors.red.shade100;
      }
      if (isCorrect) {
        return Colors.green.shade100;
      }
      return Colors.white;
    }

    Color getBorderColor() {
      if (!_isAnswerChecked) {
        return isSelected ? widget.languageColor : Colors.grey.shade300;
      }
      if (isSelected) {
        return isCorrect ? Colors.green.shade700 : Colors.red.shade700;
      }
      if (isCorrect) {
        return Colors.green.shade700;
      }
      return Colors.grey.shade300;
    }

    IconData? getIcon() {
      if (!_isAnswerChecked) {
        return isSelected ? Icons.check_circle : null;
      }
      if (isCorrect) {
        return Icons.check_circle;
      }
      if (isSelected) {
        return Icons.cancel;
      }
      return null;
    }

    Color getIconColor() {
      if (!_isAnswerChecked) {
        return widget.languageColor;
      }
      return isCorrect ? Colors.green.shade700 : Colors.red.shade700;
    }

    return GestureDetector(
      onTap: _isAnswerChecked
          ? null // Disable tap after checking
          : () {
              setState(() {
                _selectedAnswerIndex = index;
              });
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: getTileColor(),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: getBorderColor(),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: getBorderColor().withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                optionText,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            if (getIcon() != null)
              Icon(
                getIcon(),
                color: getIconColor(),
              ),
          ],
        ),
      ),
    );
  }
}