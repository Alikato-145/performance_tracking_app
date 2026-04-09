import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Home'),
      ),
      body: const Center(
        child: Text('Teacher Home Screen'),
      ),
    );
  }
}
