import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:performance_tracking_app/providers/current_user_provider.dart';
import '../../models/course_model.dart';
import '../../viewmodel/home_viewmodel.dart';
import '../login_screen.dart';
import '../teacher/teacher_course_screen.dart';
class TeacherHomeScreen extends ConsumerStatefulWidget  {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      final user = ref.read(currentUserProvider);
      if(user != null){
        ref.read(homeViewModelProvider.notifier).loadCourses(user);
      }
    });
  }
  void _showCreateCourseDialog() {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
      title: const Text('สร้างรายวิชาใหม่'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          TextFormField(
            controller: codeCtrl,
            decoration:  InputDecoration(labelText: 'รหัสรายวิชา'),
            validator: (v)=>v!.isEmpty? 'กรุณากรอกรหัสวิชา' :null,
          ),
        SizedBox(height: 12),
        TextFormField(
          controller: nameCtrl,
          decoration:  InputDecoration(labelText: 'ชื่อวิชา'),
          validator: (v)=>v!.isEmpty? 'กรุณากรอกชื่อวิชา' :null,
        ),
        SizedBox(height: 12),
        TextFormField(
          controller: descCtrl,
          decoration:  InputDecoration(labelText: 'คำอธิบาย (ถ้ามี)'),
          maxLines: 2,
        ),
          ]),
      ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ยกเลิก')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final user = ref.read(currentUserProvider)!;
              await ref.read(homeViewModelProvider.notifier).createCourse(
                courseCode: codeCtrl.text.trim(),
                courseName: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                teacherId: user.id,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('สร้าง'),
          ),
        ],
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final state = ref.watch(homeViewModelProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title:  Text('รายวิชาของฉัน'),
        actions: [
          IconButton(
            icon:  Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => LoginScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            color: scheme.primaryContainer.withOpacity(0.3),
            padding:  EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user?.name ?? '',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(user?.department ?? '',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ]),
          ),
          // Content
          Expanded(
            child: state.isLoading
                ?  Center(child: CircularProgressIndicator())
                : state.courses.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book_outlined,
                      size: 64, color: Colors.grey.shade300),
                  SizedBox(height: 12),
                  Text('ยังไม่มีรายวิชา',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            )
                : ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: state.courses.length,
              separatorBuilder: (_, __) => SizedBox(height: 10),
              itemBuilder: (_, i) {
                final course = state.courses[i];
                return _CourseCard(
                  course: course,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TeacherCourseScreen(course: course),
                    ),
                  ),
                  onDelete: () => ref
                      .read(homeViewModelProvider.notifier)
                      .deleteCourse(course.id!),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCourseDialog,
        icon:  Icon(Icons.add),
        label:  Text('สร้างวิชา'),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CourseCard(
      {required this.course, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding:  EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.menu_book, color: scheme.primary),
        ),
        title: Text(course.courseName,
            style:  TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(course.courseCode,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.chevron_right),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
            onPressed: onDelete,
          ),
        ]),
        onTap: onTap,
      ),
    );
  }
}
