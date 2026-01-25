import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exam_model.dart';

class ExamService {
  // Đổi IP theo máy của bạn (10.0.2.2 nếu chạy máy ảo Android)
  final String baseUrl = "http://10.0.2.2:8080/api/v1/exams";

  // 1. Lấy chi tiết đề thi
  Future<ExamDetail?> getExam(int examId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$examId'));
      if (response.statusCode == 200) {
        return ExamDetail.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        print("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
    }
    return null;
  }

  // 2. Nộp bài
  Future<Map<String, dynamic>> submitExam(int examId, int userId, List<Map<String, dynamic>> answers) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "examId": examId,
          "userId": userId,
          "answers": answers
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("Lỗi nộp bài: $e");
    }
    return {"success": false, "message": "Lỗi kết nối"};
  }
}