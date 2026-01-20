import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  final int heartCount;
  final int coinCount;
  final Function(int)? onHeartCountChanged;
  final Function(int)? onCoinCountChanged;

  const ProfileScreen({
    Key? key,
    required this.heartCount,
    required this.coinCount,
    this.onHeartCountChanged,
    this.onCoinCountChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'AI Tutor',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsScreen(
                                  onHeartCountChanged: onHeartCountChanged,
                                  onCoinCountChanged: onCoinCountChanged,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Ảnh đại diện'),
                            content: const Text('Thay đổi ảnh đại diện của bạn.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Thay đổi'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: const Icon(Icons.person, size: 60, color: Colors.purple),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Tên người dùng'),
                            content: const Text('Thay đổi tên hiển thị của bạn.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Lưu'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'Guest User',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Level 1 • Beginner',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Streak', '0', Icons.local_fire_department, Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Points', coinCount.toString(), Icons.stars, Colors.amber),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Lessons', '0', Icons.book, Colors.blue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuItem(Icons.chat_bubble_outline, 'AI Chat Assistant', 'Chat with AI tutor', Colors.purple, () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('AI Chat Assistant'),
                    content: const Text('Trò chuyện với trợ lý AI để được giải đáp thắc mắc.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }),
              _buildMenuItem(Icons.mic, 'Speaking Practice', 'Improve pronunciation', Colors.pink, () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Luyện nói'),
                    content: const Text('Tính năng luyện nói sẽ sớm có mặt.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }),
              _buildMenuItem(Icons.auto_stories, 'My Progress', 'Track your learning', Colors.blue, () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Tiến độ học tập'),
                    content: const Text('Xem thống kê và tiến độ học tập của bạn.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }),
              _buildMenuItem(Icons.workspace_premium, 'Upgrade to Premium', 'Unlock all features', Colors.orange, () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Nâng cấp Premium',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        const ListTile(
                          leading: Icon(Icons.diamond, color: Colors.orange),
                          title: Text('Tất cả nội dung'),
                          subtitle: Text('Truy cập không giới hạn'),
                        ),
                        const ListTile(
                          leading: Icon(Icons.offline_bolt, color: Colors.orange),
                          title: Text('Học offline'),
                          subtitle: Text('Tải xuống mọi lúc'),
                        ),
                        const ListTile(
                          leading: Icon(Icons.auto_awesome, color: Colors.orange),
                          title: Text('Không quảng cáo'),
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
              }),
              _buildMenuItem(Icons.notifications_outlined, 'Notifications', 'Manage alerts', Colors.teal, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(heartCount: 5),
                  ),
                );
              }),
              _buildMenuItem(Icons.help_outline, 'Help & Support', 'Get assistance', Colors.green, () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Trợ giúp & Hỗ trợ'),
                    content: const Text('Liên hệ với chúng tôi nếu bạn cần hỗ trợ.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }),
              _buildMenuItem(Icons.info_outline, 'About', 'App information', Colors.indigo, () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Về ứng dụng'),
                    content: const Text('Vocaboom - Ứng dụng học tiếng Anh\nPhiên bản 1.0.0'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Đăng xuất'),
                        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Đăng xuất'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Builder(
      builder: (BuildContext cardContext) {
        return GestureDetector(
          onTap: () {
            showDialog(
              context: cardContext,
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
                content: Text(
                  'Giá trị hiện tại: $value',
                  style: const TextStyle(fontSize: 16),
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
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}