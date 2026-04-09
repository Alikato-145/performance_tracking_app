import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:performance_tracking_app/view/login_screen.dart';
import 'theme/app_theme.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Performance Tracking',
      theme: AppTheme.light,
      home: LoginScreen(),
    );
  }
}
