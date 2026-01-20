import 'package:flutter/material.dart';
import 'quiz_result_screen.dart';

class QuizQuestionScreen extends StatefulWidget {
  final int level;
  final VoidCallback onLevelComplete;
  final int heartCount;
  final Function(int)? onHeartCountChanged;
  final Function(int)? onCoinCountChanged;

  const QuizQuestionScreen({
    Key? key,
    this.level = 0,
    required this.onLevelComplete,
    required this.heartCount,
    this.onHeartCountChanged,
    this.onCoinCountChanged,
  }) : super(key: key);

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  int currentQuestion = 1;
  final int totalQuestions = 10;
  String? selectedAnswer;
  bool showResult = false;
  int score = 0;
  bool answerSubmitted = false;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'How are you?',
      'translation': 'Bạn khỏe không?',
      'options': ['Fine', 'Good', 'Great', 'Not bad'],
      'correct': 'Fine',
      'explanation': '"Fine" là cách trả lời phổ biến nhất cho câu hỏi này.',
    },
    {
      'question': 'What\'s your name?',
      'translation': 'Tên bạn là gì?',
      'options': ['My name is', 'I am', 'Call me', 'I\'m'],
      'correct': 'My name is',
      'explanation': '"My name is" là cách giới thiệu tên trang trọng và phổ biến.',
    },
    {
      'question': 'Where are you from?',
      'translation': 'Bạn đến từ đâu?',
      'options': ['I am from', 'I come from', 'I\'m from', 'All of the above'],
      'correct': 'All of the above',
      'explanation': 'Tất cả các cách trên đều đúng để trả lời câu hỏi này.',
    },
    {
      'question': 'Nice to meet you.',
      'translation': 'Rất vui được gặp bạn.',
      'options': ['Same to you', 'Me too', 'Nice to meet you too', 'Thank you'],
      'correct': 'Nice to meet you too',
      'explanation': 'Đây là cách phản hồi phổ biến nhất.',
    },
  ];

  void checkAnswer(String answer) {
    if (answerSubmitted) return;

    setState(() {
      selectedAnswer = answer;
      showResult = true;
      answerSubmitted = true;

      if (answer == questions[(currentQuestion - 1) % questions.length]['correct']) {
        score += 10;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (currentQuestion < totalQuestions) {
        setState(() {
          currentQuestion++;
          selectedAnswer = null;
          showResult = false;
          answerSubmitted = false;
        });
      } else {
        widget.onCoinCountChanged?.call(score ~/ 2);
        widget.onHeartCountChanged?.call(widget.heartCount + 1);
        widget.onLevelComplete();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => QuizResultScreen(
            score: score,
            totalQuestions: totalQuestions,
            onCoinCountChanged: widget.onCoinCountChanged,
          )),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionIndex = (currentQuestion - 1) % questions.length;
    final question = questions[questionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Thoát quiz?'),
                content: const Text('Tiến trình của bạn sẽ không được lưu. Bạn có chắc chắn muốn thoát?'),
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
                    child: const Text('Thoát'),
                  ),
                ],
              ),
            );
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: currentQuestion / totalQuestions,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Trái tim'),
                    content: const Text('Mỗi trái tim cho phép bạn tham gia một quiz. Hoàn thành quiz để nhận thêm trái tim.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(Icons.favorite, color: Colors.pink, size: 24),
            ),
            const SizedBox(width: 4),
            Text(
              widget.heartCount.toString(),
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Câu $currentQuestion/$totalQuestions',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  'Điểm: $score',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Phát âm thanh'),
                              content: const Text('Phát âm thanh câu hỏi...'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Icon(Icons.volume_up, color: Colors.purple),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          question['question'],
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question['translation'],
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Chọn câu trả lời đúng:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              question['options'].length,
                  (index) {
                final option = question['options'][index];
                final isSelected = selectedAnswer == option;
                final isCorrect = option == question['correct'];
                Color? borderColor;
                Color? backgroundColor;

                if (showResult) {
                  if (isSelected) {
                    borderColor = isCorrect ? Colors.green : Colors.red;
                    backgroundColor = isCorrect ? Colors.green[50] : Colors.red[50];
                  } else if (isCorrect) {
                    borderColor = Colors.green;
                    backgroundColor = Colors.green[50];
                  }
                } else if (isSelected) {
                  borderColor = Colors.purple;
                  backgroundColor = Colors.purple[50];
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: answerSubmitted ? null : () => checkAnswer(option),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor ?? Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: borderColor ?? Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: borderColor ?? Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (showResult && (isSelected || isCorrect))
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (showResult)
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giải thích:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(question['explanation']),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}