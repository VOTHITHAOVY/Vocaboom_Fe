import 'dart:convert';

class Question {
  final int id;
  final String questionType; // MULTIPLE_CHOICE, SPEAKING, MATCHING
  final String questionText;
  final String? mediaUrl;

  // Dữ liệu đã xử lý để dùng cho UI
  final List<String> options; // Cho trắc nghiệm
  final Map<String, String> matchingPairs; // Cho nối từ (nếu có)

  Question({
    required this.id,
    required this.questionType,
    required this.questionText,
    this.mediaUrl,
    required this.options,
    required this.matchingPairs,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Xử lý optionsJson từ String sang List/Map
    List<String> parsedOptions = [];
    Map<String, String> parsedMatching = {};

    if (json['optionsJson'] != null) {
      try {
        var decoded = jsonDecode(json['optionsJson']);
        if (decoded is List) {
          parsedOptions = List<String>.from(decoded);
        } else if (decoded is Map) {
          parsedMatching = Map<String, String>.from(decoded);
        }
      } catch (e) {
        print("Lỗi parse optionsJson: $e");
      }
    }

    return Question(
      id: json['id'],
      questionType: json['questionType'],
      questionText: json['questionText'],
      mediaUrl: json['mediaUrl'],
      options: parsedOptions,
      matchingPairs: parsedMatching,
    );
  }
}

class ExamDetail {
  final int id;
  final String title;
  final String description;
  final int durationMinutes;
  final List<Question> questions;

  ExamDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.questions,
  });

  factory ExamDetail.fromJson(Map<String, dynamic> json) {
    return ExamDetail(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? "",
      durationMinutes: json['durationMinutes'] ?? 0,
      questions: (json['questions'] as List)
          .map((i) => Question.fromJson(i))
          .toList(),
    );
  }
}