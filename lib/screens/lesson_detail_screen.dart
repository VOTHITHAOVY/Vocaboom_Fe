import 'package:flutter/material.dart';
import '../models/lesson.dart'; // Import Model
import 'learning_screen.dart';
class LessonDetailScreen extends StatelessWidget {
  final Lesson lesson;

  const LessonDetailScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title), // Tiêu đề thật
        // ... actions giữ nguyên
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${lesson.title}: ${lesson.nameLesson}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  // Ảnh thật hoặc random theo ID
                  image: NetworkImage(lesson.imageUrl ?? 'https://picsum.photos/400/300?random=${lesson.lessonId}'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nội dung bài học:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 👇 CHỖ NÀY QUAN TRỌNG: Hiện tại Lesson chỉ có tên.
            // Nội dung chi tiết (LessonContent) cần gọi thêm 1 API nữa.
            // Tạm thời hiển thị tên bài học làm nội dung demo.
            Text(
              'Chào mừng bạn đến với bài học "${lesson.nameLesson}". \n'
                  'Hãy bấm nút bên dưới để bắt đầu luyện tập các nội dung chi tiết!',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Chuyển sang màn hình LearningScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LearningScreen(
                        lessonId: lesson.lessonId, // Truyền ID để API biết lấy bài nào
                        lessonTitle: lesson.title, // Truyền tên để hiện lên thanh tiêu đề
                      ),
                    ),
                  );
                },
                child: const Text('Bắt đầu học', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}