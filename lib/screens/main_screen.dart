import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'feed_screen.dart';
import 'class_screen.dart';
import 'review_screen.dart';
import 'vocabulary_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {

  final Map<String, dynamic>? userData;
  const MainScreen({
    Key? key,
    this.userData // 2. Thêm vào constructor
  }) : super(key: key);
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _coinCount = 0;

  int _heartCount = 5;

  void _updateHeartCount(int newCount) {
    setState(() => _heartCount = newCount);
  }

  void _updateCoinCount(int newCount) {
    setState(() => _coinCount = newCount);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Sắp xếp lại danh sách màn hình cho khớp với menu bên dưới
    final screens = [
      // Index 0: Home
      HomeScreen(
        heartCount: _heartCount,
        coinCount: _coinCount,
        userData: widget.userData,
        onHeartCountChanged: _updateHeartCount,
        onCoinCountChanged: _updateCoinCount,
      ),
      // Index 1: Feed (Lessons)
      const FeedScreen(),

      // Index 2: Vocabulary (Dictionary)
      VocabularyScreen(
        heartCount: _heartCount,
        onHeartCountChanged: _updateHeartCount,
      ),

      // Index 3: Profile
      ProfileScreen(
        heartCount: _heartCount,
        coinCount: _coinCount,
        onHeartCountChanged: _updateHeartCount,
        onCoinCountChanged: _updateCoinCount,
      ),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _selectedIndex == 0 ? Colors.pink : Colors.purple,
        unselectedItemColor: Colors.grey,

        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'Lessons'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), label: 'Dictionary'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}