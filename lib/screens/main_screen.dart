import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'feed_screen.dart';
import 'quiz_screen.dart';
import 'class_screen.dart';
import 'review_screen.dart';
import 'vocabulary_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

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
    final screens = [
      HomeScreen(
        heartCount: _heartCount,
        coinCount: _coinCount,
        onHeartCountChanged: _updateHeartCount,
        onCoinCountChanged: _updateCoinCount,
      ),
      const FeedScreen(),
      QuizScreen(
        heartCount: _heartCount,
        onHeartCountChanged: _updateHeartCount,
      ),
      const ClassScreen(),
      ReviewScreen(
        heartCount: _heartCount,
      ),
      VocabularyScreen(
        heartCount: _heartCount,
        onHeartCountChanged: _updateHeartCount,
      ),
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
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Video'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'Nhập môn'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz_outlined), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Class'),
          BottomNavigationBarItem(icon: Icon(Icons.repeat_outlined), label: 'Review'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), label: 'Từ vựng'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}