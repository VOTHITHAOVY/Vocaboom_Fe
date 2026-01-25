import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'settings_screen.dart';
import 'LoginScreen.dart';
import 'notifications_screen.dart';// <-- Nghi ngờ thiếu dòng này nhất
import 'settings_screen.dart';
class ProfileScreen extends StatelessWidget {
  final int heartCount;
  final int coinCount;
  final Function(int)? onHeartCountChanged;
  final Function(int)? onCoinCountChanged;

  // Thêm biến nhận dữ liệu user từ MainScreen
  final Map<String, dynamic>? userData;

  const ProfileScreen({
    Key? key,
    required this.heartCount,
    required this.coinCount,
    this.onHeartCountChanged,
    this.onCoinCountChanged,
    this.userData, // Nhận dữ liệu ở đây
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Xác định trạng thái đăng nhập dựa trên dữ liệu truyền vào
    final bool isLoggedIn = userData != null;

    // Lấy thông tin (Sử dụng toán tử ?? để lấy giá trị mặc định nếu null)
    // Lưu ý: Key ('name', 'email', 'avatar') phải khớp với JSON API trả về
    final String userName = userData?['name'] ?? userData?['fullName'] ?? 'Khách';
    final String userEmail = userData?['email'] ?? 'Chưa cập nhật';
    final String? avatarUrl = userData?['picture'] ?? userData?['avatarUrl'];
    final String phone = userData?['phone'] ?? 'Chưa cập nhật';
    final String dob = userData?['dob'] ?? userData?['birthday'] ?? 'Chưa cập nhật';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header với gradient
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0277BD), Color(0xFF01579B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Hồ sơ của tôi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
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

                    // Avatar
                    GestureDetector(
                      onTap: () {
                        // Chức năng thay đổi avatar
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              // Hiển thị ảnh từ API nếu có, ngược lại hiện icon
                              image: (isLoggedIn && avatarUrl != null && avatarUrl.isNotEmpty)
                                  ? DecorationImage(
                                image: NetworkImage(avatarUrl),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: (isLoggedIn && avatarUrl != null && avatarUrl.isNotEmpty)
                                ? null // Đã có ảnh nền
                                : const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF0277BD),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF0277BD), width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Color(0xFF0277BD),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tên người dùng hiển thị động
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Level badge (Có thể lấy từ API nếu có field 'level')
                    if (isLoggedIn)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Level 1 • Beginner',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Thống kê (Có thể map dữ liệu từ API vào đây nếu có)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Streak', '0', Icons.local_fire_department, Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Điểm', coinCount.toString(), Icons.stars, Colors.amber),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Bài học', '0', Icons.book, Colors.blue),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Thông tin cá nhân (chỉ hiện khi đã đăng nhập)
              if (isLoggedIn) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin cá nhân',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Card thông tin
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.person_outline, 'Họ và tên', userName),
                            const Divider(height: 1),
                            _buildInfoRow(Icons.email_outlined, 'Email', userEmail),
                            const Divider(height: 1),
                            // Nếu API không trả về phone/dob thì hiển thị placeholder hoặc ẩn đi
                            _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', phone),
                            const Divider(height: 1),
                            _buildInfoRow(Icons.cake_outlined, 'Ngày sinh', dob),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Các menu item
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tính năng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              _buildMenuItem(Icons.chat_bubble_outline, 'AI Chat Assistant', 'Trò chuyện với AI', const Color(0xFF0277BD), () {}),
              _buildMenuItem(Icons.mic, 'Luyện phát âm', 'Cải thiện khả năng nói', Colors.pink, () {}),
              _buildMenuItem(Icons.auto_stories, 'Tiến trình học tập', 'Theo dõi quá trình học', Colors.blue, () {}),
              _buildMenuItem(Icons.notifications_outlined, 'Thông báo', 'Quản lý thông báo', Colors.teal, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(heartCount: 5),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Nút đăng nhập/đăng xuất
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                height: 50,
                child: isLoggedIn
                    ? OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Đăng xuất'),
                          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Đóng dialog
                                // Chuyển về màn hình đăng nhập và xóa lịch sử route
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                      (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Đăng xuất'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                )
                    : ElevatedButton.icon(
                  onPressed: () {
                    // Chuyển đến màn hình login
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    'Đăng nhập / Đăng ký',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0277BD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 3,
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

  // --- Các Widget con giữ nguyên ---

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0277BD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF0277BD), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Chỉ cho phép sửa nếu có dữ liệu thực tế (Optional)
          IconButton(
            icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
            onPressed: () {
              // Chức năng chỉnh sửa thông tin
            },
          ),
        ],
      ),
    );
  }
}