import 'package:flutter/material.dart';

// --- Re-using Language Structure from home_page.dart for consistency ---
class ProgrammingLanguage {
  final String title;
  final String imagePath;
  final Color color;
  final List<Lesson> lessons;

  const ProgrammingLanguage({
    required this.title,
    required this.imagePath,
    required this.color,
    required this.lessons,
  });
}

// --- Lesson Data Models ---

class Lesson {
  final int id;
  final String title;
  final List<LessonSection> sections;
  final Quiz quiz;

  const Lesson({
    required this.id,
    required this.title,
    required this.sections,
    required this.quiz,
  });
}

class LessonSection {
  final String heading;
  final String content;
  final String? codeSnippet;

  const LessonSection({
    required this.heading,
    required this.content,
    this.codeSnippet,
  });
}

class Quiz {
  final String title;
  final List<QuizQuestion> questions;

  const Quiz({
    required this.title,
    required this.questions,
  });
}

class QuizQuestion {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  const QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });
}

// --- Hardcoded Java Lessons (Example Data) ---

final javaLessons = [
  Lesson(
    id: 101,
    title: 'Java-д тавтай морил',
    sections: [
      LessonSection(
        heading: 'Java гэж юу вэ?',
        content:
            'Java бол объект хандалгатай, ангид суурилсан, тухайн хэлбэрээс хамааралгүй (write once, run anywhere) програмчлалын хэл юм. Үүнийг 1995 онд Sun Microsystems компани бүтээжээ.',
      ),
      LessonSection(
        heading: 'Анхны програм',
        content: 'Програмчлалын хэл сурахын тулд хамгийн түрүүнд "Hello, World!" хөтөлбөрийг бичих хэрэгтэй.',
        codeSnippet: '''
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
        ''',
      ),
      LessonSection(
        heading: 'Түлхүүр ойлголт: Виртуал Машин (JVM)',
        content: 'Java Virtual Machine (JVM) нь Java кодын гүйцэтгэлийг хариуцдаг бөгөөд Java-г платформ хамааралгүй болгодог гол бүрэлдэхүүн хэсэг юм. [Image of Java Virtual Machine (JVM) architecture]',
      ),
    ],
    quiz: Quiz(
      title: 'Урамшуулал 1: Java-ийн үндэс',
      questions: [
        QuizQuestion(
          questionText: 'Java хэлийг хэн бүтээсэн бэ?',
          options: ['Microsoft', 'Google', 'Sun Microsystems', 'Oracle'],
          correctAnswerIndex: 2,
        ),
        QuizQuestion(
          questionText: 'Java-г платформ хамааралгүй болгодог бүрэлдэхүүн хэсэг юу вэ?',
          options: ['JDK', 'JRE', 'JVM', 'JIT'],
          correctAnswerIndex: 2,
        ),
      ],
    ),
  ),
  // You would add more lessons here (e.g., id: 102, 103, etc.)
];

// --- Combine all data into the main list ---

final List<ProgrammingLanguage> allLanguagesWithLessons = [
  ProgrammingLanguage(
    title: 'Java',
    imagePath: 'assets/java.png',
    color: const Color(0xFFE53935), // Red
    lessons: javaLessons,
  ),
  // Add Python, C++, etc., lessons here
  ProgrammingLanguage(
    title: 'Python',
    imagePath: 'assets/python.png',
    color: const Color(0xFF42A5F5), // Blue
    lessons: const [], // Placeholder
  ),
  ProgrammingLanguage(
    title: 'C++',
    imagePath: 'assets/cpp.png',
    color: const Color(0xFF7E57C2), // Purple
    lessons: const [], // Placeholder
  ),
  ProgrammingLanguage(
    title: 'Java Script',
    imagePath: 'assets/javascript.png',
    color: const Color(0xFFFFCA28), // Yellow
    lessons: const [], // Placeholder
  ),
  ProgrammingLanguage(
    title: 'Php',
    imagePath: 'assets/php.png',
    color: const Color(0xFF5C6BC0), // Indigo
    lessons: const [], // Placeholder
  ),
  ProgrammingLanguage(
    title: 'Dart',
    imagePath: 'assets/dart.png',
    color: const Color(0xFF00BFA5), // Teal
    lessons: const [], // Placeholder
  ),
];