import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/course_model.dart';
import '../../../models/assignment_model.dart';
import '../../../database/seed_data.dart';
import '../../viewmodel/course_viewmodel.dart';

class TeacherCourseScreen extends ConsumerStatefulWidget {
  final CourseModel course;
  const TeacherCourseScreen({super.key, required this.course});

  @override
  ConsumerState<TeacherCourseScreen> createState() =>
      _TeacherCourseScreenState();
}

class _TeacherCourseScreenState extends ConsumerState<TeacherCourseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(courseViewModelProvider.notifier)
          .load(widget.course.id!, SeedData.teacher);
    });
  }

  void _showAddAssignmentDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final scoreCtrl = TextEditingController();
    AssignmentType type = AssignmentType.assignment;
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text('เพิ่มงาน / การสอบ'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // type
                SegmentedButton<AssignmentType>(
                  segments: [
                    ButtonSegment(
                        value: AssignmentType.assignment,
                        label: Text('งาน'),
                        icon: Icon(Icons.assignment)),
                    ButtonSegment(
                        value: AssignmentType.exam,
                        label: Text('สอบ'),
                        icon: Icon(Icons.quiz)),
                  ],
                  selected: {type},
                  onSelectionChanged: (v) =>
                      setStateDialog(() => type = v.first),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: 'หัวข้อ'),
                  validator: (v) => v!.isEmpty ? 'กรุณากรอกหัวข้อ' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: InputDecoration(labelText: 'รายละเอียด'),
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: scoreCtrl,
                  decoration: InputDecoration(labelText: 'คะแนนเต็ม'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v!.isEmpty) return 'กรุณากรอกคะแนน';
                    if (int.tryParse(v) == null) return 'กรอกเป็นตัวเลข';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('วันกำหนดส่ง'),
                  subtitle: Text(DateFormat('dd MMM yyyy').format(dueDate)),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add( Duration(days: 365)),
                    );
                    if (picked != null) {
                      setStateDialog(() => dueDate = picked);
                    }
                  },
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('ยกเลิก')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  await ref.read(courseViewModelProvider.notifier).addAssignment(
                    AssignmentModel(
                      courseId: widget.course.id!,
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      type: type,
                      maxScore: int.parse(scoreCtrl.text),
                      dueDate: dueDate,
                    ),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('เพิ่ม'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseViewModelProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.courseName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(children: [
              Text(widget.course.courseCode,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              Spacer(),
              Container(
                padding:
                EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'คะแนนรวม ${state.totalMaxScore}/100',
                  style: TextStyle(
                      color: scheme.onPrimaryContainer, fontSize: 12),
                ),
              ),
            ]),
          ),
        ),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator())
          : state.assignments.isEmpty
          ? Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.assignment_outlined,
              size: 64, color: Colors.grey.shade300),
          SizedBox(height: 8),
          Text('ยังไม่มีงาน/การสอบ',
              style: TextStyle(color: Colors.grey.shade500)),
        ]),
      )
          : ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: state.assignments.length,
        separatorBuilder: (_, __) => SizedBox(height: 10),
        itemBuilder: (_, i) {
          final a = state.assignments[i];
          return _AssignmentCard(
            assignment: a,
            courseId: widget.course.id!,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.totalMaxScore >= 100 ? null : _showAddAssignmentDialog,
        icon: Icon(Icons.add),
        label: Text('เพิ่มงาน/สอบ'),
        backgroundColor:
        state.totalMaxScore >= 100 ? Colors.grey : scheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _AssignmentCard extends ConsumerWidget {
  final AssignmentModel assignment;
  final int courseId;
  const _AssignmentCard({required this.assignment, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isExam = assignment.type == AssignmentType.exam;
    final isPast = DateTime.now().isAfter(assignment.dueDate);

    return Card(
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isExam
                ? Colors.orange.shade50
                : scheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isExam ? Icons.quiz : Icons.assignment,
            color: isExam ? Colors.orange : scheme.primary,
            size: 20,
          ),
        ),
        title: Text(assignment.title,
            style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Row(children: [
          Text('${assignment.maxScore} คะแนน',
              style: TextStyle(fontSize: 12)),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isPast ? Colors.red.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'ส่งก่อน ${DateFormat('dd/MM/yy').format(assignment.dueDate)}',
              style: TextStyle(
                fontSize: 11,
                color: isPast ? Colors.red : Colors.green.shade700,
              ),
            ),
          ),
        ]),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(),
                Text('คะแนนรายบุคคล',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12)),
                SizedBox(height: 8),
                ...SeedData.students.map((student) {
                  final state = ref.watch(courseViewModelProvider);
                  final sub = state.submissions[assignment.id];
                  final score = state.scores[assignment.id];
                  return _StudentScoreRow(
                    student: student,
                    submission: sub,
                    score: score,
                    assignment: assignment,
                    courseId: courseId,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentScoreRow extends ConsumerWidget {
  final dynamic student;
  final dynamic submission;
  final dynamic score;
  final AssignmentModel assignment;
  final int courseId;

  const _StudentScoreRow({
    required this.student,
    required this.submission,
    required this.score,
    required this.assignment,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreCtrl = TextEditingController(
        text: score != null ? score.score.toStringAsFixed(0) : '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(student.name, style: TextStyle(fontSize: 13)),
            Text(student.studentCode,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ]),
        ),
        SizedBox(
          width: 64,
          child: TextField(
            controller: scoreCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
            decoration: InputDecoration(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              hintText: '/ ${assignment.maxScore}',
              hintStyle:TextStyle(fontSize: 11),
            ),
            onSubmitted: (v) async {
              final s = double.tryParse(v);
              if (s == null || submission == null) return;
              await ref.read(courseViewModelProvider.notifier).gradeStudent(
                submissionId: submission.id,
                assignmentId: assignment.id!,
                studentId: student.id,
                courseId: courseId,
                score: s,
              );
            },
          ),
        ),
      ]),
    );
  }
}