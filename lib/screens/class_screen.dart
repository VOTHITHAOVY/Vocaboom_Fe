import 'package:flutter/material.dart';
import '../widgets/course_detail_screen.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({Key? key}) : super(key: key);

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Class', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.pink,
          labelColor: Colors.pink,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Khóa học'),
            Tab(text: 'Speak'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCoursesTab(),
          _buildSpeakTab(),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Khóa học phổ biến tuần qua',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                final courses = [
                  {'title': 'Spencer', 'subtitle': 'Thể hiện Cảm xúc', 'level': 'Nhập môn', 'days': '8 ngày', 'views': '71,840'},
                  {'title': 'Spencer&Alex', 'subtitle': 'Luyện Câu trúc Câu', 'level': 'Sơ cấp', 'days': '12 ngày', 'views': '70,844'},
                  {'title': 'Alex', 'subtitle': 'Ngữ pháp Cơ bản', 'level': 'Trung cấp', 'days': '10 ngày', 'views': '65,320'},
                ];

                final course = courses[index];

                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(course['title']!),
                        content: Text('${course['subtitle']!}\n${course['level']} - ${course['days']}\n${course['views']} lượt xem'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Đóng'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailScreen(course: course),
                                ),
                              );
                            },
                            child: const Text('Xem chi tiết'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: index == 0 ? Colors.cyan[300] : (index == 1 ? Colors.teal[300] : Colors.blue[300]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.bookmark_border, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 60),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    'https://picsum.photos/100/100?random=${index + 200}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(Icons.visibility, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    course['views']!,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                course['title']!,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                course['subtitle']!,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${course['level']} · ${course['days']}',
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Trình độ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Chuyên mục',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            ListTile(
                              title: const Text('Ngữ pháp'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {},
                            ),
                            ListTile(
                              title: const Text('Từ vựng'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {},
                            ),
                            ListTile(
                              title: const Text('Phát âm'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Chuyên mục',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildLevelChip('Tất cả', true),
                _buildLevelChip('Nhập môn', false),
                _buildLevelChip('Sơ cấp', false),
                _buildLevelChip('Trung cấp', false),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Course ${index + 4}'),
                      content: const Text('Learn English with interactive lessons.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Đóng'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseDetailScreen(
                                  course: {
                                    'title': 'Course ${index + 4}',
                                    'subtitle': 'Learn English',
                                    'level': 'Nhập môn',
                                    'days': '5 ngày',
                                    'views': '10,000',
                                  },
                                ),
                              ),
                            );
                          },
                          child: const Text('Xem chi tiết'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.bookmark_border, size: 20),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  'https://picsum.photos/80/80?random=${index + 300}',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Course ${index + 4}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Learn English',
                              style: TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Nhập môn · 5 ngày',
                              style: TextStyle(fontSize: 11, color: Colors.black45),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'Practice Speaking',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Text(
            'Coming soon!',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Thông báo'),
                  content: const Text('Tính năng luyện nói sẽ sớm có mặt. Hãy quay lại sau!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Nhận thông báo khi có'),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}