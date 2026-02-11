import 'package:flutter/material.dart';
// Import các màn hình con
import 'home_screen.dart';
import 'feed_screen.dart';
import 'vocabulary_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  // Nhận dữ liệu user từ màn hình Login gửi sang
  final Map<String, dynamic>? userData;

  const MainScreen({
    Key? key,
    this.userData,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Khởi tạo giá trị mặc định
  int _coinCount = 0;
  int _heartCount = 5;

  @override
  void initState() {
    super.initState();
    // 👇 QUAN TRỌNG: Cập nhật xu và tim từ dữ liệu Database nếu có
    if (widget.userData != null) {
      setState(() {
        // Nếu database chưa có trường 'coins' thì mặc định là 0
        _coinCount = widget.userData?['coins'] ?? 0;
        // Nếu database chưa có trường 'hearts' thì mặc định là 5
        _heartCount = widget.userData?['hearts'] ?? 5;
      });
    }
  }

  void _updateHeartCount(int newCount) {
    setState(() => _heartCount = newCount);
  }

  void _updateCoinCount(int newCount) {
    setState(() => _coinCount = newCount);
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách các màn hình
    final screens = [
      // Index 0: Home (Truyền xu và tim vào để hiển thị)
      HomeScreen(
        heartCount: _heartCount,
        coinCount: _coinCount,
        userData: widget.userData,
        onHeartCountChanged: _updateHeartCount,
        onCoinCountChanged: _updateCoinCount,
      ),

      // Index 1: Feed (Lessons - Video lướt giống TikTok)
      const FeedScreen(),

      // Index 2: Vocabulary (Dictionary/Flashcard)
      VocabularyScreen(
        heartCount: _heartCount,
        onHeartCountChanged: _updateHeartCount,
      ),

      // Index 3: Profile (Truyền thông tin user vào để hiển thị tên, email...)
      ProfileScreen(
        heartCount: _heartCount,
        coinCount: _coinCount,
        userData: widget.userData, // Truyền userData để Profile hiển thị thông tin
        onHeartCountChanged: _updateHeartCount,
        onCoinCountChanged: _updateCoinCount,
      ),
    ];

    return Scaffold(
      // Hiển thị màn hình tương ứng với tab được chọn
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),

      // Thanh điều hướng dưới đáy (Đã làm đẹp)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Bóng mờ nhẹ
              blurRadius: 10,
              offset: const Offset(0, -5), // Đổ bóng lên trên
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed, // Dùng fixed để icon không bị nhảy khi có >3 item
          backgroundColor: Colors.white,
          elevation: 0, // Tắt bóng mặc định để dùng bóng custom ở trên

          // Màu sắc khi chọn và chưa chọn
          selectedItemColor: const Color(0xFFFF6B6B), // Màu hồng cam chủ đạo
          unselectedItemColor: Colors.grey.shade400,

          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),

          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded, size: 28),
                label: 'Home'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.video_library_outlined),
                activeIcon: Icon(Icons.video_library_rounded, size: 28),
                label: 'Lessons'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.book_outlined),
                activeIcon: Icon(Icons.book_rounded, size: 28),
                label: 'Từ vựng'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded, size: 28),
                label: 'Hồ sơ'
            ),
          ],
        ),
      ),
    );
  }
}