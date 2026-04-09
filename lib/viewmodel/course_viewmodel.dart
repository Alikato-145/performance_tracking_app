import 'package:flutter_riverpod/legacy.dart';
import 'package:sqflite/sqflite.dart';
import '../../../database/database_helper.dart';
import '../../../models/assignment_model.dart';
import '../../../models/submission_model.dart';
import '../../../models/score_model.dart';
import '../../../models/user_model.dart';
import '../../../database/seed_data.dart';

class CourseState {
  final List<AssignmentModel> assignments;
  final Map<int, SubmissionModel?> submissions; // key = assignmentId
  final Map<int, ScoreModel?> scores;           // key = assignmentId
  final bool isLoading;
  final int totalMaxScore; // ผลรวม max_score ของ assignments ทั้งหมดใน course

  const CourseState({
    this.assignments = const [],
    this.submissions = const {},
    this.scores = const {},
    this.isLoading = false,
    this.totalMaxScore = 0,
  });

  CourseState copyWith({
    List<AssignmentModel>? assignments,
    Map<int, SubmissionModel?>? submissions,
    Map<int, ScoreModel?>? scores,
    bool? isLoading,
    int? totalMaxScore,
  }) =>
      CourseState(
        assignments: assignments ?? this.assignments,
        submissions: submissions ?? this.submissions,
        scores: scores ?? this.scores,
        isLoading: isLoading ?? this.isLoading,
        totalMaxScore: totalMaxScore ?? this.totalMaxScore,
      );

  // คำนวณคะแนนรวมของนักศึกษาคนหนึ่ง
  double totalScore() {
    double sum = 0;
    for (final s in scores.values) {
      if (s != null) sum += s.score;
    }
    return sum;
  }

  // แปลงคะแนนเป็นเกรด
  String grade() {
    if (totalMaxScore == 0) return '-';
    final pct = totalScore() / totalMaxScore * 100;
    if (pct >= 80) return 'A';
    if (pct >= 75) return 'B+';
    if (pct >= 70) return 'B';
    if (pct >= 65) return 'C+';
    if (pct >= 60) return 'C';
    if (pct >= 55) return 'D+';
    if (pct >= 50) return 'D';
    return 'F';
  }
}

class CourseViewModel extends StateNotifier<CourseState> {
  CourseViewModel() : super(const CourseState());

  Future<void> load(int courseId, UserModel currentUser) async {
    state = state.copyWith(isLoading: true);
    final db = await DatabaseHelper.instance.database;

    final assignmentRows = await db.query(
      'assignments',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
    final assignments = assignmentRows.map(AssignmentModel.fromMap).toList();

    final totalMaxScore =
    assignments.fold<int>(0, (sum, a) => sum + a.maxScore);

    final submissionsMap = <int, SubmissionModel?>{};
    final scoresMap = <int, ScoreModel?>{};

    for (final a in assignments) {
      // ดึง submission ของนักศึกษาคนนี้
      final subRows = await db.query(
        'submissions',
        where: 'assignment_id = ? AND student_id = ?',
        whereArgs: [a.id, currentUser.id],
        limit: 1,
      );
      final sub = subRows.isEmpty ? null : SubmissionModel.fromMap(subRows.first);
      submissionsMap[a.id!] = sub;

      // ดึง score
      final scoreRows = await db.query(
        'scores',
        where: 'assignment_id = ? AND student_id = ?',
        whereArgs: [a.id, currentUser.id],
        limit: 1,
      );
      scoresMap[a.id!] =
      scoreRows.isEmpty ? null : ScoreModel.fromMap(scoreRows.first);
    }

    state = state.copyWith(
      assignments: assignments,
      submissions: submissionsMap,
      scores: scoresMap,
      totalMaxScore: totalMaxScore,
      isLoading: false,
    );
  }

  Future<void> addAssignment(AssignmentModel assignment) async {
    final db = await DatabaseHelper.instance.database;

    // ตรวจว่า max_score รวมกันแล้วไม่เกิน 100
    final sumRow = await db.rawQuery(
      'SELECT COALESCE(SUM(max_score), 0) as total FROM assignments WHERE course_id = ?',
      [assignment.courseId],
    );
    final currentTotal = (sumRow.first['total'] as num).toInt();
    if (currentTotal + assignment.maxScore > 100) {
      throw Exception(
          'คะแนนรวมเกิน 100 (ปัจจุบัน $currentTotal คะแนน เหลือ ${100 - currentTotal} คะแนน)');
    }

    await db.insert('assignments', assignment.toMap());

    // สร้าง submission สถานะ pending ให้นักศึกษาทุกคนอัตโนมัติ
    final batch = db.batch();
    for (final student in SeedData.students) {
      batch.insert(
        'submissions',
        {
          'assignment_id': assignment.id,
          'student_id': student.id,
          'status': 'pending',
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);

    await load(assignment.courseId, SeedData.teacher); // reload
  }

  Future<void> submitAssignment({
    required int assignmentId,
    required int studentId,
    required int courseId,
    String? linkUrl,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'submissions',
      {
        'status': 'submitted',
        'link_url': linkUrl,
        'submitted_at': DateTime.now().toIso8601String(),
      },
      where: 'assignment_id = ? AND student_id = ?',
      whereArgs: [assignmentId, studentId],
    );

    final student = SeedData.students.firstWhere((s) => s.id == studentId);
    await load(courseId, student);
  }

  Future<void> gradeStudent({
    required int submissionId,
    required int assignmentId,
    required int studentId,
    required int courseId,
    required double score,
    String? note,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'scores',
      ScoreModel(
        submissionId: submissionId,
        assignmentId: assignmentId,
        studentId: studentId,
        score: score,
        teacherNote: note,
        gradedAt: DateTime.now(),
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await load(courseId, SeedData.teacher);
  }
}

final courseViewModelProvider =
StateNotifierProvider.autoDispose<CourseViewModel, CourseState>((ref) {
  return CourseViewModel();
});