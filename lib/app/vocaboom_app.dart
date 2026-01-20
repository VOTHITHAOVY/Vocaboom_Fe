import 'package:flutter/material.dart';
import '../screens/main_screen.dart';

class VocaboomApp extends StatelessWidget {
  const VocaboomApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocaboom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'SF Pro',
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const MainScreen(),
    );
  }
}