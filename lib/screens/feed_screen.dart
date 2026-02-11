import 'package:flutter/material.dart';
import '../models/lesson.dart';         // Import Model
import '../services/api_service.dart';  // Import Service
import 'lesson_detail_screen.dart';
// import '../utils/search_delegates.dart'; // Giữ nguyên nếu bạn có file này

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<Lesson>> futureLessons;

  @override
  void initState() {
    super.initState();
    futureLessons = ApiService.fetchLessons(); // Gọi API ngay khi mở màn hình
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nhập môn', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      // 👇 Dùng FutureBuilder để chờ dữ liệu
      body: FutureBuilder<List<Lesson>>(
        future: futureLessons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Đang tải...
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có bài học nào"));
          }

          // Có dữ liệu rồi!
          List<Lesson> lessons = snapshot.data!;

          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index]; // Lấy bài học tại vị trí index

              return GestureDetector(
                onTap: () {
                  // Truyền cả object lesson sang màn hình chi tiết
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LessonDetailScreen(lesson: lesson),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          // Nếu API chưa có ảnh, dùng ảnh random theo ID cho đẹp
                          lesson.imageUrl ?? 'https://picsum.photos/400/250?random=${lesson.lessonId}',
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${lesson.title}: ${lesson.nameLesson}', // Hiển thị Title thật
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bài học số ${lesson.lessonId}', // Hiển thị ID hoặc mô tả
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                            // ... Giữ nguyên phần trang trí Row bên dưới ...
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}