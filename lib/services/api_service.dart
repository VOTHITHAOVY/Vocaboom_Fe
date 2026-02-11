import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lesson.dart';
import '../models/lesson_content.dart'; // 1. Nhớ import file này nha!

class ApiService {
  // 👇 Đổi thành URL Cloudflare của bạn hoặc IP Local
  static const String baseUrl = "http://192.168.1.10:8080";

  // Lấy danh sách bài học
  static Future<List<Lesson>> fetchLessons() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Lesson'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // 'Authorization': 'Bearer ...' // Tạm thời comment dòng này lại nếu chưa có token thật, kẻo bị lỗi 401/403
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      List<Lesson> lessons = body.map((dynamic item) => Lesson.fromJson(item)).toList();
      return lessons;
    } else {
      throw Exception('Không tải được bài học: ${response.statusCode}');
    }
  }

  // 2. Thêm 'static' vào đây để dễ gọi
  static Future<List<LessonContent>> getLessonContents(int lessonId) async {
    // 3. Thêm '/api' vào đường dẫn cho khớp với backend
    final response = await http.get(Uri.parse('$baseUrl/api/lesson-contents/lesson/$lessonId'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      List<LessonContent> contents = body.map((dynamic item) => LessonContent.fromJson(item)).toList();
      return contents;
    } else {
      throw Exception('Không thể tải nội dung bài học: ${response.statusCode}');
    }
  }
}