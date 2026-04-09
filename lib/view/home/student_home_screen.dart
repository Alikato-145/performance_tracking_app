import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Home'),
      ),
      body: const Center(
        child: Text('Student Home Screen'),
      ),
    );
  }
}
