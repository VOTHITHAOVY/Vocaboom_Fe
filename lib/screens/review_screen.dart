import 'package:flutter/material.dart';
import 'video_detail_screen.dart';
import 'notifications_screen.dart';
import '../models/video_lesson.dart'; // Import model
class ReviewScreen extends StatelessWidget {
  final int heartCount;

  const ReviewScreen({Key? key, required this.heartCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Câu hỏi sai',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Ôn tập các câu và từ sai',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Thú cưng ôn tập'),
                                content: const Text('Ôn tập cùng thú cưng để nhận thêm phần thưởng!'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple[300],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.cake, color: Colors.white, size: 30),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Cake Plus',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            const ListTile(
                              leading: Icon(Icons.diamond, color: Colors.orange),
                              title: Text('Nội dung đặc biệt'),
                              subtitle: Text('Truy cập tất cả nội dung PLUS'),
                            ),
                            const ListTile(
                              leading: Icon(Icons.offline_bolt, color: Colors.orange),
                              title: Text('Học offline'),
                              subtitle: Text('Tải xuống và học mọi lúc'),
                            ),
                            const ListTile(
                              leading: Icon(Icons.auto_awesome, color: Colors.orange),
                              title: Text('Không quảng cáo'),
                              subtitle: Text('Trải nghiệm học tập liền mạch'),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                child: const Text('Nâng cấp ngay'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.diamond, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'PLUS',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Bắt đầu dùng Cake Plus',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 20),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Video đã học',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ...List.generate(3, (index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoDetailScreen(

                          videoData: VideoLesson(
                              id: 0,
                              title: 'Video ôn tập #${index + 1}',
                              youtubeId: 'g-S6nyX8_6k', // ID video mẫu
                              thumbnailUrl: '',
                              subtitles: [] // Danh sách sub rỗng
                          ),

                          heartCount: heartCount,
                          onHeartCountChanged: null,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Video học #${index + 1}',
                                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                              ),
                              Text(
                                'Hoàn thành ${index + 2} ngày trước',
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Nhiều hồ sơ học tập hơn',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    _buildStatRow('Câu đã lưu', '0', Icons.bookmark_border),
                    const Divider(height: 30),
                    _buildStatRow('Từ đã lưu', '0', Icons.favorite_border),
                    const Divider(height: 30),
                    _buildStatRow('Quiz trong tâm', '0', Icons.quiz_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Trái tim của bạn'),
                  content: Text('Bạn có $heartCount trái tim.\nDùng trái tim để lưu nội dung yêu thích.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.favorite, color: Colors.pink, size: 32),
                  Positioned(
                    bottom: 0,
                    child: Text(
                      heartCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String title, String value, IconData icon) {
    return Builder(
      builder: (BuildContext rowContext) {
        return GestureDetector(
          onTap: () {
            showDialog(
              context: rowContext,
              builder: (BuildContext dialogContext) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                content: const Text(
                  'Xem chi tiết thống kê học tập của bạn.',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text(
                      'Đóng',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.purple,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}