import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/seed_data.dart';
import '../../../models/user_model.dart';
import '../../../providers/current_user_provider.dart';
import 'home/student_home_screen.dart';
import 'home/teacher_home_screen.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  UserRole _selectedRole = UserRole.student;
  UserModel? _selectedUser;

  List<UserModel> get _usersForRole => _selectedRole == UserRole.teacher
      ? [SeedData.teacher]
      : SeedData.students;

  void _login() {
    if (_selectedUser == null) return;
    ref.read(currentUserProvider.notifier).state = _selectedUser;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _selectedUser!.role == UserRole.teacher
            ? const TeacherHomeScreen()
            : const StudentHomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48),
              Text('Performance\nTracking',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  )),
              SizedBox(height: 8),
              Text('เข้าสู่ระบบ',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.grey)),
              SizedBox(height: 40),

              // Select Role
              Text('เข้าใช้งานในฐานะ',
                  style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: 8),
              Row(children: [
                _RoleChip(
                  label: 'นักศึกษา',
                  selected: _selectedRole == UserRole.student,
                  onTap: () => setState(() {
                    _selectedRole = UserRole.student;
                    _selectedUser = null;
                  }),
                ),
                 SizedBox(width: 8),
                _RoleChip(
                  label: 'อาจารย์',
                  selected: _selectedRole == UserRole.teacher,
                  onTap: () => setState(() {
                    _selectedRole = UserRole.teacher;
                    _selectedUser = null;
                  }),
                ),
              ]),
               SizedBox(height: 24),

              Text('เลือกผู้ใช้งาน',
                  style: Theme.of(context).textTheme.titleSmall),
               SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: _usersForRole.length,
                  separatorBuilder: (_, __) =>  SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final user = _usersForRole[i];
                    final selected = _selectedUser?.id == user.id;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: selected
                              ? scheme.primary
                              : Colors.grey.shade200,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      tileColor: selected
                          ? scheme.primary.withOpacity(0.05)
                          : Colors.white,
                      leading: CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: Text(
                          user.name.characters.first,
                          style: TextStyle(color: scheme.onPrimaryContainer),
                        ),
                      ),
                      title: Text(user.name),
                      subtitle: user.studentCode != null
                          ? Text(user.studentCode!)
                          : Text(user.department),
                      trailing: selected
                          ? Icon(Icons.check_circle, color: scheme.primary)
                          : null,
                      onTap: () => setState(() => _selectedUser = user),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _selectedUser != null ? _login : null,
                  child: const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RoleChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: selected ? scheme.primary : Colors.grey.shade300),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}