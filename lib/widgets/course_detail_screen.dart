import 'package:flutter/material.dart';

class CourseDetailScreen extends StatelessWidget {
  final Map<String, String> course;

  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course['title']!),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage('https://picsum.photos/400/300?random=60'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              course['title']!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              course['subtitle']!,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    course['level']!,
                    style: const TextStyle(color: Colors.purple),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(course['days']!, style: const TextStyle(color: Colors.grey)),
                const SizedBox(width: 10),
                const Icon(Icons.visibility, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(course['views']!, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Mô tả khóa học:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Khóa học này sẽ giúp bạn nắm vững kiến thức cơ bản và nâng cao kỹ năng tiếng Anh. '
                  'Với các bài học tương tác và bài tập thực hành, bạn sẽ tiến bộ nhanh chóng.',
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Bắt đầu học'),
                      content: const Text('Bạn có muốn bắt đầu khóa học này ngay bây giờ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Bắt đầu'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Bắt đầu học', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}