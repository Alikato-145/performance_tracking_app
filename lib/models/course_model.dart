class CourseModel {
  final int? id;
  final String courseCode;
  final String courseName;
  final int teacherId;
  final String? description;
  CourseModel({
    this.id,
    required this.courseCode,
    required this.courseName,
    required this.teacherId,
    this.description,
});
  CourseModel copyWith({int? id}) => CourseModel(
    id: id ?? this.id,
    courseCode: courseCode,
    courseName: courseName,
    teacherId: teacherId,
    description: description,
  );
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'course_code': courseCode,
    'course_name': courseName,
    'teacher_id': teacherId,
    'description': description,
  };
  factory CourseModel.fromMap(Map<String, dynamic> m) => CourseModel(
    id: m['id'],
    courseCode: m['course_code'],
    courseName: m['course_name'],
    teacherId: m['teacher_id'],
    description: m['description'],
  );
}