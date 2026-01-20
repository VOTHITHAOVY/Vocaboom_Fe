import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final Function(int)? onCoinCountChanged;

  const QuizResultScreen({
    Key? key,
    required this.score,
    required this.totalQuestions,
    this.onCoinCountChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accuracy = (score / (totalQuestions * 10) * 100).toInt();
    final coinsEarned = score ~/ 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Chia sẻ kết quả'),
                          content: const Text('Chia sẻ kết quả của bạn với bạn bè!'),
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
                ],
              ),
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
              ),
              const SizedBox(height: 30),
              Text(
                score >= 70 ? 'Xuất sắc!' : 'Chúc mừng!',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Bạn đã hoàn thành quiz',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Điểm số:', style: TextStyle(fontSize: 16)),
                        Text('$score/${totalQuestions * 10}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Độ chính xác:', style: TextStyle(fontSize: 16)),
                        Text('$accuracy%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accuracy >= 80 ? Colors.green : Colors.orange)),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Xu nhận được:', style: TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            const Icon(Icons.diamond, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text('+$coinsEarned', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Tiếp tục học',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Xem lại đáp án'),
                      content: const Text('Chức năng này sẽ sớm có mặt.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'Xem lại đáp án',
                  style: TextStyle(fontSize: 16, color: Colors.purple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}