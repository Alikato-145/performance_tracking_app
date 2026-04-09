import 'package:performance_tracking_app/models/user_model.dart';

class SeedData {
  static const UserModel teacher = UserModel(
    id: 1,
    name: 'ผศ.ดร. สมชาย ใจดี',
    role: UserRole.teacher,
    faculty: 'คณะวิทยาศาสตร์',
    department: 'วิทยาการคอมพิวเตอร์',
  );

  static const List<UserModel> students =[
    UserModel(
      id: 101,
      name: 'นายกิตติพงศ์ แสงทอง',
      role: UserRole.student,
      faculty: 'คณะวิทยาศาสตร์',
      department: 'วิทยาการคอมพิวเตอร์',
      studentCode: '6601001',
      yearLevel: 3,
    ),
    UserModel(
      id: 102,
      name: 'นางสาวปาริชาต มีสุข',
      role: UserRole.student,
      faculty: 'คณะวิทยาศาสตร์',
      department: 'วิทยาการคอมพิวเตอร์',
      studentCode: '6601002',
      yearLevel: 3,
    ),
    UserModel(
      id: 103,
      name: 'นายธนกร วงศ์ไพร',
      role: UserRole.student,
      faculty: 'คณะวิทยาศาสตร์',
      department: 'วิทยาการคอมพิวเตอร์',
      studentCode: '6601003',
      yearLevel: 3,
    ),
    UserModel(
      id: 104,
      name: 'นางสาวภัทรา ศิลปชัย',
      role: UserRole.student,
      faculty: 'คณะวิทยาศาสตร์',
      department: 'วิทยาการคอมพิวเตอร์',
      studentCode: '6601004',
      yearLevel: 3,
    ),
    UserModel(
      id: 105,
      name: 'นายวรุตม์ ทองดี',
      role: UserRole.student,
      faculty: 'คณะวิทยาศาสตร์',
      department: 'วิทยาการคอมพิวเตอร์',
      studentCode: '6601005',
      yearLevel: 3,
    ),
  ];
  static List<UserModel> get allUsers => [teacher, ...students];
}