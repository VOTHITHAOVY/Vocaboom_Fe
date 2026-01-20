import 'package:flutter/material.dart';

class QuizPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple.withOpacity(0.2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.4, 60);
    path.quadraticBezierTo(
      size.width * 0.1, size.height * 0.3,
      size.width * 0.2, size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.7,
      size.width * 0.5, size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.85,
      size.width * 0.8, size.height * 0.7,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}