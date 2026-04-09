enum AssignmentType { assignment, exam }

class AssignmentModel {
  final int? id;
  final int courseId;
  final String title;
  final String? description;
  final AssignmentType type;
  final int maxScore;
  final DateTime dueDate;

  const AssignmentModel({
    this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.type,
    required this.maxScore,
    required this.dueDate,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'course_id': courseId,
    'title': title,
    'description': description,
    'type': type.name,
    'max_score': maxScore,
    'due_date': dueDate.toIso8601String(),
  };

  factory AssignmentModel.fromMap(Map<String, dynamic> m) => AssignmentModel(
    id: m['id'],
    courseId: m['course_id'],
    title: m['title'],
    description: m['description'],
    type: AssignmentType.values.byName(m['type']),
    maxScore: m['max_score'],
    dueDate: DateTime.parse(m['due_date']),
  );
}