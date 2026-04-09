enum SubmissionStatus { pending, submitted, late }

class SubmissionModel {
  final int? id;
  final int assignmentId;
  final int studentId;
  final SubmissionStatus status;
  final String? fileUrl;
  final String? linkUrl;
  final DateTime? submittedAt;

  const SubmissionModel({
    this.id,
    required this.assignmentId,
    required this.studentId,
    required this.status,
    this.fileUrl,
    this.linkUrl,
    this.submittedAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'assignment_id': assignmentId,
    'student_id': studentId,
    'status': status.name,
    'file_url': fileUrl,
    'link_url': linkUrl,
    'submitted_at': submittedAt?.toIso8601String(),
  };

  factory SubmissionModel.fromMap(Map<String, dynamic> m) => SubmissionModel(
    id: m['id'],
    assignmentId: m['assignment_id'],
    studentId: m['student_id'],
    status: SubmissionStatus.values.byName(m['status']),
    fileUrl: m['file_url'],
    linkUrl: m['link_url'],
    submittedAt: m['submitted_at'] != null
        ? DateTime.parse(m['submitted_at'])
        : null,
  );
}