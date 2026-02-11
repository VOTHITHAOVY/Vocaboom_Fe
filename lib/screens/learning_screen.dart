import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/lesson_content.dart';
import '../services/api_service.dart';

class LearningScreen extends StatefulWidget {
  final int lessonId;
  final String lessonTitle;

  const LearningScreen({Key? key, required this.lessonId, required this.lessonTitle}) : super(key: key);

  @override
  _LearningScreenState createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late Future<List<LessonContent>> _contentsFuture;

  // Controller để quản lý việc lướt qua lại giữa các trang
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _totalSteps = 0;

  // Lưu trạng thái câu trả lời và kết quả
  final Map<int, String> _userAnswers = {};
  final Map<int, bool?> _quizResults = {};

  @override
  void initState() {
    super.initState();
    _contentsFuture = ApiService.getLessonContents(widget.lessonId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Hàm tiện ích lấy Youtube ID từ URL để hiện ảnh thumbnail
  String? _getYoutubeId(String url) {
    RegExp regExp = RegExp(r"[\w-]{11}");
    Match? match = regExp.firstMatch(url);
    return match?.group(0);
  }

  List<String> _parseOptions(String jsonString) {
    try {
      List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => item.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  void _checkAnswer(int questionId, String correctAnswer) {
    setState(() {
      String? userChoice = _userAnswers[questionId];
      if (userChoice != null) {
        bool isCorrect = userChoice.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
        _quizResults[questionId] = isCorrect;
      }
    });
  }

  void _nextPage() {
    if (_currentPage < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Đã học xong, hiển thị thông báo chúc mừng hoặc quay lại
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Hoàn thành!"),
          content: const Text("Chúc mừng bạn đã hoàn thành bài học này."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Đóng dialog
                Navigator.of(context).pop(); // Quay về màn hình danh sách bài học
              },
              child: const Text("Về danh sách bài"),
            )
          ],
        ),
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        backgroundColor: Colors.purple,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<LessonContent>>(
        future: _contentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Bài học này chưa có nội dung!"));
          }

          final contents = snapshot.data!;
          _totalSteps = contents.length;

          return Column(
            children: [
              // 1. Thanh tiến trình
              LinearProgressIndicator(
                value: (_currentPage + 1) / _totalSteps,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 6,
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Phần ${_currentPage + 1} / $_totalSteps",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),

              // 2. Nội dung chính (PageView)
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Chặn người dùng lướt tay để bắt buộc dùng nút
                  itemCount: contents.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildStepContent(contents[index]),
                    );
                  },
                ),
              ),

              // 3. Khu vực nút điều hướng
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                    ]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nút Quay lại
                    if (_currentPage > 0)
                      ElevatedButton(
                        onPressed: _previousPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text("Quay lại"),
                      )
                    else
                      const SizedBox(width: 10), // Placeholder để giữ khoảng cách

                    // Nút Tiếp theo
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        _currentPage == _totalSteps - 1 ? "Hoàn thành" : "Tiếp theo",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepContent(LessonContent content) {
    String? youtubeId;
    if (content.videoUrl != null && content.videoUrl!.isNotEmpty) {
      youtubeId = _getYoutubeId(content.videoUrl!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- VIDEO ---
        if (youtubeId != null)
          Container(
            height: 220,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black,
              image: DecorationImage(
                image: NetworkImage("https://img.youtube.com/vi/$youtubeId/hqdefault.jpg"),
                fit: BoxFit.cover,
                opacity: 0.7,
              ),
            ),
            child: const Center(
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.red,
                child: Icon(Icons.play_arrow, color: Colors.white, size: 35),
              ),
            ),
          ),

        // --- NỘI DUNG ---
        const Text(
          "Nội dung bài học:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            content.content,
            style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 30),

        // --- CÂU HỎI (Nếu có) ---
        if (content.questions.isNotEmpty) ...[
          const Divider(thickness: 1),
          const SizedBox(height: 10),
          const Text(
            "📝 Bài tập củng cố",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
          ),
          const SizedBox(height: 10),

          ...content.questions.map((q) {
            List<String> options = _parseOptions(q.optionsJson);
            bool? isCorrect = _quizResults[q.id];

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)
                  ],
                  border: Border.all(
                      color: isCorrect == true ? Colors.green : (isCorrect == false ? Colors.red : Colors.transparent),
                      width: 2
                  )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Câu hỏi: ${q.questionText}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),

                  ...options.map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: _userAnswers[q.id],
                      activeColor: Colors.purple,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        if (_quizResults[q.id] == null) {
                          setState(() {
                            _userAnswers[q.id] = val!;
                          });
                        }
                      },
                    );
                  }).toList(),

                  if (isCorrect == null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          if (_userAnswers[q.id] != null) {
                            _checkAnswer(q.id, q.correctAnswer ?? "");
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Hãy chọn một đáp án!")),
                            );
                          }
                        },
                        child: const Text("Kiểm tra"),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        isCorrect ? "Chính xác!" : "Sai rồi. Đáp án đúng: ${q.correctAnswer}",
                        style: TextStyle(
                            color: isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                ],
              ),
            );
          }).toList(),
        ]
      ],
    );
  }
}