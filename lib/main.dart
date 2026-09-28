import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const QueueLessApp());
}

class QueueLessApp extends StatelessWidget {
  const QueueLessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QueueLess',
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}