class Lesson {
  final int lessonId;
  final String title;      // Ví dụ: "Bài 1"
  final String nameLesson; // Ví dụ: "Chào hỏi cơ bản"
  final String? imageUrl;  // Nếu DB chưa có thì mình sẽ random ảnh tạm

  Lesson({
    required this.lessonId,
    required this.title,
    required this.nameLesson,
    this.imageUrl,
  });

  // Hàm biến đổi JSON từ Server thành Object Dart
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lessonId'] ?? 0,
      title: json['title'] ?? 'No Title',
      nameLesson: json['nameLesson'] ?? '',
      // Nếu backend chưa trả về ảnh, ta tạm để null
      imageUrl: json['image_url'],
    );
  }
}