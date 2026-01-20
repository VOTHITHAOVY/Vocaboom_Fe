import 'package:flutter/material.dart';
import 'quiz_level_screen.dart';
import 'quiz_question_screen.dart';
import '../../utils/quiz_path_painter.dart';

class QuizTodayScreen extends StatefulWidget {
  final int heartCount;
  final Function(int)? onHeartCountChanged;
  final Function(int)? onCoinCountChanged;

  const QuizTodayScreen({
    Key? key,
    required this.heartCount,
    this.onHeartCountChanged,
    this.onCoinCountChanged,
  }) : super(key: key);

  @override
  State<QuizTodayScreen> createState() => _QuizTodayScreenState();
}

class _QuizTodayScreenState extends State<QuizTodayScreen> {
  List<bool> _levelUnlocked = [true, false, false, false, false];
  int _currentLevel = 0;

  void _unlockNextLevel() {
    if (_currentLevel < 4) {
      setState(() {
        _levelUnlocked[_currentLevel + 1] = true;
        _currentLevel++;

        widget.onCoinCountChanged?.call(10);
        widget.onHeartCountChanged?.call(widget.heartCount + 2);

        _showLevelCompleteDialog();
      });
    }
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chúc mừng!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 50),
            const SizedBox(height: 10),
            Text('Bạn đã hoàn thành cấp độ $_currentLevel'),
            const SizedBox(height: 10),
            const Text('+10 điểm\n+2 trái tim'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Unit 1'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text('Thông tin Unit'),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Unit 1: Chào hỏi Hằng ngày'),
                              content: const Text('Học cách chào hỏi và giới thiệu bản thân trong tiếng Anh.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.restart_alt),
                        title: const Text('Làm lại từ đầu'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _levelUnlocked = [true, false, false, false, false];
                            _currentLevel = 0;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.purple,
            child: const Text(
              'Chào hỏi Hằng ngày',
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple, width: 2),
                    ),
                    child: const Text(
                      'ngay lập tức\nBắt đầu bài kiểm tra!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomPaint(
                    size: const Size(300, 300),
                    painter: QuizPathPainter(),
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 20,
                            left: 100,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuizLevelScreen(
                                      heartCount: widget.heartCount,
                                      onHeartCountChanged: widget.onHeartCountChanged,
                                      onCoinCountChanged: widget.onCoinCountChanged,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 130,
                            left: 30,
                            child: _buildLevelCircle(Icons.play_arrow, _levelUnlocked[0] ? Colors.green : Colors.grey[300]!, 0),
                          ),
                          Positioned(
                            top: 200,
                            left: 80,
                            child: _buildLevelCircle(Icons.search, _levelUnlocked[1] ? Colors.green : Colors.grey[300]!, 1),
                          ),
                          Positioned(
                            bottom: 80,
                            left: 50,
                            child: _buildLevelCircle(Icons.ad_units, _levelUnlocked[2] ? Colors.green : Colors.grey[300]!, 2),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 80,
                            child: Builder(
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        title: const Text(
                                          'Phần thưởng đặc biệt!',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                        ),
                                        content: const Text(
                                          'Hoàn thành tất cả cấp độ để nhận phần thưởng đặc biệt.',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
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
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.card_giftcard,
                                      color: Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 100,
                            right: 20,
                            child: _buildLevelCircle(Icons.chat_bubble_outline, _levelUnlocked[3] ? Colors.green : Colors.grey[300]!, 3),
                          ),
                          Positioned(
                            right: 20,
                            top: 40,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Thú cưng học tập'),
                                    content: const Text('Chăm sóc thú cưng để nhận thêm phần thưởng!'),
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
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.purple[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.cake, color: Colors.purple, size: 40),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            bottom: 160,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Bạn bè'),
                                    content: const Text('Mời bạn bè cùng học để nhận thêm phần thưởng!'),
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
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.cake_outlined, color: Colors.grey, size: 30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _unlockNextLevel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Mở khóa cấp độ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Builder(
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Trái tim của bạn'),
                            content: Text('Bạn có ${widget.heartCount} trái tim.\nDùng trái tim để mở khóa bài học mới.'),
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
                        padding: const EdgeInsets.all(16),
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
                                widget.heartCount.toString(),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCircle(IconData icon, Color color, int level) {
    return GestureDetector(
      onTap: () {
        if (_levelUnlocked[level]) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizQuestionScreen(
                level: level,
                onLevelComplete: _unlockNextLevel,
                heartCount: widget.heartCount,
                onHeartCountChanged: widget.onHeartCountChanged,
                onCoinCountChanged: widget.onCoinCountChanged,
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cấp độ bị khóa'),
              content: const Text('Hoàn thành cấp độ trước để mở khóa.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: _levelUnlocked[level] ? Border.all(color: Colors.purple, width: 3) : null,
        ),
        child: Icon(icon, color: Colors.grey[600], size: 30),
      ),
    );
  }
}