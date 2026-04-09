class ScoreModel {
  final int? id;
  final int submissionId;
  final int assignmentId;
  final int studentId;
  final double score;
  final String? teacherNote;
  final DateTime? gradedAt;

  const ScoreModel({
    this.id,
    required this.submissionId,
    required this.assignmentId,
    required this.studentId,
    required this.score,
    this.teacherNote,
    this.gradedAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'submission_id': submissionId,
    'assignment_id': assignmentId,
    'student_id': studentId,
    'score': score,
    'teacher_note': teacherNote,
    'graded_at': gradedAt?.toIso8601String(),
  };

  factory ScoreModel.fromMap(Map<String, dynamic> m) => ScoreModel(
    id: m['id'],
    submissionId: m['submission_id'],
    assignmentId: m['assignment_id'],
    studentId: m['student_id'],
    score: (m['score'] as num).toDouble(),
    teacherNote: m['teacher_note'],
    gradedAt:
    m['graded_at'] != null ? DateTime.parse(m['graded_at']) : null,
  );
}