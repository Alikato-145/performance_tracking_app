import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async{
    _database ??= await _initDB('performance.db');
    return _database!;
  }
  Future<Database> _initDB(String filePath) async{
    final dbPath = join(await getDatabasesPath(), filePath);
    return await openDatabase(dbPath,version: 1,onCreate: _createDB);
  }

  FutureOr<void> _createDB(Database db, int version) async{
    await db.execute('PRAGMA foreign_keys = ON');

    await db.execute('''
      CREATE TABLE courses (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        course_code TEXT    NOT NULL,
        course_name TEXT    NOT NULL,
        teacher_id  INTEGER NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE course_students (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id  INTEGER NOT NULL,
        student_id INTEGER NOT NULL,
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
        UNIQUE(course_id, student_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE assignments (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id   INTEGER NOT NULL,
        title       TEXT    NOT NULL,
        description TEXT,
        type        TEXT    NOT NULL,
        max_score   INTEGER NOT NULL,
        due_date    TEXT    NOT NULL,
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE submissions (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        assignment_id INTEGER NOT NULL,
        student_id    INTEGER NOT NULL,
        status        TEXT    NOT NULL DEFAULT 'pending',
        file_url      TEXT,
        link_url      TEXT,
        submitted_at  TEXT,
        FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
        UNIQUE(assignment_id, student_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE scores (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        submission_id INTEGER NOT NULL,
        assignment_id INTEGER NOT NULL,
        student_id    INTEGER NOT NULL,
        score         REAL    NOT NULL DEFAULT 0,
        teacher_note  TEXT,
        graded_at     TEXT,
        FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE CASCADE,
        UNIQUE(assignment_id, student_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE student_notes (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id  INTEGER NOT NULL,
        student_id INTEGER NOT NULL,
        teacher_id INTEGER NOT NULL,
        note       TEXT    NOT NULL,
        updated_at TEXT    NOT NULL,
        UNIQUE(course_id, student_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE teacher_reviews (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id  INTEGER NOT NULL,
        student_id INTEGER NOT NULL,
        teacher_id INTEGER NOT NULL,
        note       TEXT    NOT NULL,
        rating     INTEGER NOT NULL DEFAULT 5,
        created_at TEXT    NOT NULL
      )
    ''');
  }
  Future<void> close() async {
    final db = await database;
    db.close();
  }

}