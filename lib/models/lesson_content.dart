// lib/models/lesson_content.dart

class Question {
  final int id;
  final String questionText;
  final String questionType;
  final String optionsJson; // Đáp án A, B, C, D lưu dạng JSON string
  final String? correctAnswer; // Có thể null nếu muốn giấu đáp án ở client

  Question({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.optionsJson,
    this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      questionText: json['questionText'] ?? '',
      questionType: json['questionType'] ?? 'MULTIPLE_CHOICE',
      optionsJson: json['optionsJson'] ?? '[]',
      correctAnswer: json['correctAnswer'],
    );
  }
}

class LessonContent {
  final int id;
  final String content;
  final String? videoUrl;
  final int orderIndex;
  final List<Question> questions;

  LessonContent({
    required this.id,
    required this.content,
    this.videoUrl,
    required this.orderIndex,
    required this.questions,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    var list = json['questions'] as List? ?? [];
    List<Question> questionsList = list.map((i) => Question.fromJson(i)).toList();

    return LessonContent(
      id: json['id'] ?? 0, // Lưu ý: Backend trả về id hay id_lesson_content? Kiểm tra lại JSON
      content: json['content'] ?? '',
      videoUrl: json['videoUrl'],
      orderIndex: json['orderIndex'] ?? 0,
      questions: questionsList,
    );
  }
}