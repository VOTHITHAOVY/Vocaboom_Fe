import 'package:flutter/material.dart';
// 👇 Import đúng tên file LoginScreen.dart của bạn
import 'LoginScreen.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final int heartCount;
  final int coinCount;
  final Function(int)? onHeartCountChanged;
  final Function(int)? onCoinCountChanged;

  const ProfileScreen({
    Key? key,
    this.userData,
    this.heartCount = 0,
    this.coinCount = 0,
    this.onHeartCountChanged,
    this.onCoinCountChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem đã đăng nhập chưa
    bool isLoggedIn = userData != null && userData!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Center(
        child: isLoggedIn
            ? _buildUserProfile(context) // Nếu đã đăng nhập -> Hiện hồ sơ
            : _buildGuestView(context),  // Nếu chưa -> Hiện giao diện khách
      ),
    );
  }

  // 1. GIAO DIỆN CHO NGƯỜI ĐÃ ĐĂNG NHẬP
  Widget _buildUserProfile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Avatar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blueAccent, width: 2)),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: userData!['avatarUrl'] != null
                ? NetworkImage(userData!['avatarUrl'])
                : null,
            child: userData!['avatarUrl'] == null
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
        ),
        const SizedBox(height: 20),

        // Tên & Email
        Text(
          userData!['fullName'] ?? "Người dùng VocaBoom",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          userData!['email'] ?? "",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),

        const SizedBox(height: 40),

        // Thống kê Coin/Tim (Optional)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem(Icons.favorite, Colors.pink, "$heartCount", "Trái tim"),
            const SizedBox(width: 30),
            _buildStatItem(Icons.water_drop, Colors.blue, "$coinCount", "Giọt nước"),
          ],
        ),

        const SizedBox(height: 50),

        // Nút Đăng xuất
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              // Logic đăng xuất: Quay về màn hình Login và xóa hết stack cũ
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text("Đăng xuất", style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        )
      ],
    );
  }

  // 2. GIAO DIỆN CHO KHÁCH (CHƯA ĐĂNG NHẬP)
  Widget _buildGuestView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_person_outlined, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 20),
        const Text(
          "Bạn chưa đăng nhập",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Text(
            "Đăng nhập để lưu tiến độ học tập và tham gia bảng xếp hạng nhé!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Chuyển sang màn hình LoginScreen để đăng nhập
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Đăng nhập ngay", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // Widget con hiển thị thống kê
  Widget _buildStatItem(IconData icon, Color color, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}