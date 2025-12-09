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

// =======================================================
//                   LESSON CONTENTS
// =======================================================

// --- 1. Java Lessons (ID: 100s) ---
final javaLessons = [
  Lesson(
    id: 101,
    title: 'Java-д тавтай морил',
    sections: [
      LessonSection(
        heading: 'Java гэж юу вэ?',
        content: 'Java бол объект хандалгатай, ангид суурилсан, платформ хамааралгүй (write once, run anywhere) програмчлалын хэл юм. Үүнийг 1995 онд Sun Microsystems компани бүтээжээ.',
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
        content: 'Java Virtual Machine (JVM) нь Java кодын гүйцэтгэлийг хариуцдаг бөгөөд Java-г платформ хамааралгүй болгодог гол бүрэлдэхүүн хэсэг юм.',
      ),
    ],
    quiz: Quiz(
      title: 'Java-ийн үндэс',
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
];

// --- 2. Python Lessons (ID: 200s) ---
final pythonLessons = [
  Lesson(
    id: 201,
    title: 'Python-ийн танилцуулга',
    sections: [
      LessonSection(
        heading: 'Python гэж юу вэ?',
        content: 'Python бол энгийн, уншихад хялбар синтакс бүхий өндөр түвшний програмчлалын хэл юм. Өгөгдлийн шинжлэх ухаан, хиймэл оюун ухаан, вэб хөгжүүлэлтэд өргөн ашиглагддаг.',
      ),
      LessonSection(
        heading: 'Анхны програм',
        content: 'Python дээр "Hello, World!" бичих нь маш хялбар. Хаалт эсвэл цэг таслал шаардлагагүй.',
        codeSnippet: 'print("Hello, World!")',
      ),
      LessonSection(
        heading: 'Онцлог: Догол мөр (Indentation)',
        content: 'Python нь кодын блокуудыг тодорхойлохдоо хаалт {} биш, харин догол мөр (indentation) ашигладаг.',
      ),
    ],
    quiz: Quiz(
      title: 'Python-ийн үндэс',
      questions: [
        QuizQuestion(
          questionText: 'Python кодын блокыг юугаар тодорхойлдог вэ?',
          options: ['Хаалт {}', 'Цэг таслал ;', 'Догол мөр (Indentation)', 'Түлхүүр үг'],
          correctAnswerIndex: 2,
        ),
        QuizQuestion(
          questionText: 'Дэлгэцэн дээр текст хэвлэх функц аль нь вэ?',
          options: ['echo()', 'printf()', 'System.out.println()', 'print()'],
          correctAnswerIndex: 3,
        ),
      ],
    ),
  ),
];

// --- 3. C++ Lessons (ID: 300s) ---
final cppLessons = [
  Lesson(
    id: 301,
    title: 'C++ хэлний үндэс',
    sections: [
      LessonSection(
        heading: 'C++ гэж юу вэ?',
        content: 'C++ нь C хэл дээр суурилсан, объект хандалтат програмчлалын боломжуудыг нэмсэн хүчирхэг хэл юм. Тоглоом хөгжүүлэлт болон систем програмчлалд ихэвчлэн ашиглагддаг.',
      ),
      LessonSection(
        heading: 'Анхны програм',
        content: 'iostream санг ашиглан дэлгэцэнд хэвлэх жишээ:',
        codeSnippet: '''
#include <iostream>
using namespace std;

int main() {
  cout << "Hello, World!";
  return 0;
}
        ''',
      ),
    ],
    quiz: Quiz(
      title: 'C++ мэдлэг шалгах',
      questions: [
        QuizQuestion(
          questionText: 'C++ хэл аль хэл дээр суурилсан бэ?',
          options: ['Java', 'C', 'Python', 'Assembly'],
          correctAnswerIndex: 1,
        ),
        QuizQuestion(
          questionText: 'Гаралт хэвлэхэд аль командыг ашигладаг вэ?',
          options: ['cin', 'cout', 'print', 'write'],
          correctAnswerIndex: 1,
        ),
      ],
    ),
  ),
];

// --- 4. JavaScript Lessons (ID: 400s) ---
final jsLessons = [
  Lesson(
    id: 401,
    title: 'JavaScript: Вэбийн хэл',
    sections: [
      LessonSection(
        heading: 'JavaScript гэж юу вэ?',
        content: 'JavaScript нь вэб хуудсыг интерактив, амьд болгодог хэл юм. Үүнийг вэб хөтөч дээр шууд ажиллуулах боломжтой.',
      ),
      LessonSection(
        heading: 'Анхны програм',
        content: 'Консол дээр текст хэвлэх жишээ:',
        codeSnippet: 'console.log("Hello, World!");',
      ),
    ],
    quiz: Quiz(
      title: 'JS-ийн үндэс',
      questions: [
        QuizQuestion(
          questionText: 'JavaScript-ийг ихэвчлэн хаана ашигладаг вэ?',
          options: ['Мобайл апп', 'Вэб хөтөч (Browser)', 'Үйлдлийн систем', 'Микроконтроллер'],
          correctAnswerIndex: 1,
        ),
        QuizQuestion(
          questionText: 'Консол руу бичих тушаал аль нь вэ?',
          options: ['print()', 'echo', 'console.log()', 'System.out.print()'],
          correctAnswerIndex: 2,
        ),
      ],
    ),
  ),
];

// --- 5. PHP Lessons (ID: 500s) ---
final phpLessons = [
  Lesson(
    id: 501,
    title: 'PHP ба Сервер тал',
    sections: [
      LessonSection(
        heading: 'PHP гэж юу вэ?',
        content: 'PHP бол вэб хөгжүүлэлтэд зориулагдсан, сервер талд ажилладаг скрипт хэл юм. WordPress зэрэг олон системүүд PHP дээр суурилдаг.',
      ),
      LessonSection(
        heading: 'Синтакс',
        content: 'PHP код нь <?php ... ?> тэмдэглэгээний хооронд бичигдэнэ.',
        codeSnippet: '''
<?php
  echo "Hello, World!";
?>
        ''',
      ),
    ],
    quiz: Quiz(
      title: 'PHP мэдлэг шалгах',
      questions: [
        QuizQuestion(
          questionText: 'PHP хувьсагч ямар тэмдэгтээр эхэлдэг вэ?',
          options: ['@', '#', '\$', '%'],
          correctAnswerIndex: 2,
        ),
        QuizQuestion(
          questionText: 'PHP код хаана ажилладаг вэ?',
          options: ['Хэрэглэгчийн хөтөч дээр', 'Сервер дээр', 'Database дотор', 'Үйлдлийн систем дээр'],
          correctAnswerIndex: 1,
        ),
      ],
    ),
  ),
];

// --- 6. SQL Lessons (ID: 600s) ---
final sqlLessons = [
  Lesson(
    id: 601,
    title: 'SQL ба Өгөгдлийн сан',
    sections: [
      LessonSection(
        heading: 'SQL гэж юу вэ?',
        content: 'SQL (Structured Query Language) нь өгөгдлийн сантай харилцах, мэдээлэл хадгалах, татах, өөрчлөхөд ашиглагддаг стандарт хэл юм.',
      ),
      LessonSection(
        heading: 'Мэдээлэл сонгох',
        content: '"Users" хүснэгтээс бүх мэдээллийг авах жишээ:',
        codeSnippet: 'SELECT * FROM Users;',
      ),
    ],
    quiz: Quiz(
      title: 'SQL-ийн үндэс',
      questions: [
        QuizQuestion(
          questionText: 'Өгөгдөл татаж авахад ямар түлхүүр үг ашигладаг вэ?',
          options: ['GET', 'PULL', 'SELECT', 'FETCH'],
          correctAnswerIndex: 2,
        ),
        QuizQuestion(
          questionText: 'SQL гэдэг нь юуны товчлол вэ?',
          options: ['Simple Query Language', 'Structured Question List', 'Structured Query Language', 'System Query Logic'],
          correctAnswerIndex: 2,
        ),
      ],
    ),
  ),
];

// --- 7. Ruby Lessons (ID: 700s) ---
final rubyLessons = [
  Lesson(
    id: 701,
    title: 'Ruby: Хөгжүүлэгчийн жаргал',
    sections: [
      LessonSection(
        heading: 'Ruby гэж юу вэ?',
        content: 'Ruby бол энгийн, ойлгомжтой байдалд төвлөрсөн, бүрэн объект хандалтат хэл юм. Ruby on Rails фреймворкоороо алдартай.',
      ),
      LessonSection(
        heading: 'Анхны програм',
        content: 'Дэлгэцэн дээр текст хэвлэх:',
        codeSnippet: 'puts "Hello, World!"',
      ),
    ],
    quiz: Quiz(
      title: 'Ruby мэдлэг шалгах',
      questions: [
        QuizQuestion(
          questionText: 'Ruby хэлийг хэн бүтээсэн бэ?',
          options: ['Guido van Rossum', 'Yukihiro Matsumoto (Matz)', 'James Gosling', 'Rasmus Lerdorf'],
          correctAnswerIndex: 1,
        ),
        QuizQuestion(
          questionText: 'Ruby-д текст хэвлэх команд аль нь вэ?',
          options: ['print', 'puts', 'echo', 'printf'],
          correctAnswerIndex: 1,
        ),
      ],
    ),
  ),
];

// --- 8. Go Lessons (ID: 800s) ---
final goLessons = [
  Lesson(
    id: 801,
    title: 'Go (Golang)',
    sections: [
      LessonSection(
        heading: 'Go гэж юу вэ?',
        content: 'Go нь Google-ээс бүтээсэн, өндөр гүйцэтгэлтэй, зэрэгцээ ажиллагааг (concurrency) сайн дэмждэг хэл юм.',
      ),
      LessonSection(
        heading: 'Анхны програм',
        content: 'Go хэлний бүтэц:',
        codeSnippet: '''
package main
import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
        ''',
      ),
    ],
    quiz: Quiz(
      title: 'Go хэлний үндэс',
      questions: [
        QuizQuestion(
          questionText: 'Go хэлийг аль компани хөгжүүлдэг вэ?',
          options: ['Facebook', 'Apple', 'Google', 'Amazon'],
          correctAnswerIndex: 2,
        ),
        QuizQuestion(
          questionText: 'Go програмын эхлэл цэг юу вэ?',
          options: ['Start()', 'Init()', 'main()', 'Run()'],
          correctAnswerIndex: 2,
        ),
      ],
    ),
  ),
];

// --- Combine all data into the main list ---

final List<ProgrammingLanguage> allLanguagesWithLessons = [
  ProgrammingLanguage(
    title: 'Java',
    imagePath: 'assets/java.png',
    // Orange/Red (Java Brand Color)
    color: const Color(0xFFE65100), 
    lessons: javaLessons,
  ),
  ProgrammingLanguage(
    title: 'Python',
    imagePath: 'assets/python.png',
    // Python Blue
    color: const Color(0xFF1E88E5), 
    lessons: pythonLessons,
  ),
  ProgrammingLanguage(
    title: 'C++',
    imagePath: 'assets/cpp.png',
    // Deep Blue
    color: const Color(0xFF1565C0), 
    lessons: cppLessons,
  ),
  ProgrammingLanguage(
    title: 'JavaScript',
    imagePath: 'assets/javascript.png',
    // Amber/Gold (Readable "Yellow")
    color: const Color(0xFFFFB300), 
    lessons: jsLessons,
  ),
  ProgrammingLanguage(
    title: 'PHP',
    imagePath: 'assets/php.png',
    // Indigo/Purple
    color: const Color(0xFF5C6BC0), 
    lessons: phpLessons,
  ),
  ProgrammingLanguage(
    title: 'SQL',
    imagePath: 'assets/sql.png',
    // Blue Grey (Database feel)
    color: const Color(0xFF546E7A), 
    lessons: sqlLessons,
  ),
  ProgrammingLanguage(
    title: 'Ruby',
    imagePath: 'assets/ruby.png',
    // Ruby Red
    color: const Color(0xFFD32F2F), 
    lessons: rubyLessons,
  ),
  ProgrammingLanguage(
    title: 'Go',
    imagePath: 'assets/go.png',
    // Go Cyan
    color: const Color(0xFF00ACC1), 
    lessons: goLessons,
  ),
];