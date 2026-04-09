import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:performance_tracking_app/database/database_helper.dart';
import 'package:performance_tracking_app/models/course_model.dart';
import 'package:sqflite/sqflite.dart';import '../database/seed_data.dart';


import '../models/user_model.dart';
import '../providers/current_user_provider.dart';

class HomeState  {
  final List<CourseModel> courses;
  final bool isLoading;
  final String? error;
  const HomeState ({
    this.courses = const [],
    this.isLoading = false,
    this.error
});
  HomeState  copyWith({
    List<CourseModel>? courses,
    bool? isLoading,
    String? error,
  }) =>
      HomeState (
        courses: courses ?? this.courses,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}
class HomeViewModel extends StateNotifier<HomeState>{
  final Ref _ref;
  HomeViewModel(this._ref) : super(const HomeState());
  Future<void> loadCourses(UserModel user) async{
    state = state.copyWith(isLoading: true);
    try{
      final db = await DatabaseHelper.instance.database;
      List<Map<String,dynamic>> rows;

      if(user.role == UserRole.teacher){
        rows = await db.query('courses', where: 'teacher_id = ?', whereArgs: [user.id]);
      }else{
        rows = await db.rawQuery('''
          SELECT c.* FROM courses c
          INNER JOIN course_students cs ON cs.course_id = c.id
          WHERE cs.student_id = ?
        ''', [user.id]);
      }
      state = state.copyWith(
        courses: rows.map(CourseModel.fromMap).toList(),
        isLoading: false,
      );
    }catch(e){
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  Future<void> createCourse({
    required String courseCode,
    required String courseName,
    required String description,
    required int teacherId,
  })async{
    final db = await DatabaseHelper.instance.database;
    final courseId = await db.insert('courses', {
      'course_code': courseCode,
      'course_name': courseName,
      'teacher_id': teacherId,
      'description': description,
    });
    //auto-enroll for student when have create course
    final batch = db.batch();
    for (final student in SeedData.students) {
      batch.insert(
        'course_students',
        {'course_id': courseId, 'student_id': student.id},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);

    final currentUser = _ref.read(currentUserProvider);
    if (currentUser != null) await loadCourses(currentUser);
  }
  Future<void> deleteCourse(int courseId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('courses', where: 'id = ?', whereArgs: [courseId]);
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser != null) await loadCourses(currentUser);
  }
}

final homeViewModelProvider =
StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(ref);
});