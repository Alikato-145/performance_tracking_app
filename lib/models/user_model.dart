enum UserRole {teacher, student}

class UserModel {
  final int id;
  final String name;
  final UserRole role;
  final String faculty;
  final String department;
  final String? studentCode;
  final int? yearLevel;

  const UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.faculty,
    required this.department,
    this.studentCode,
    this.yearLevel,
  });
}