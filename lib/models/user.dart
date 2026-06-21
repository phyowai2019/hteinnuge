class UserModel {
  final String id, username, name, role;
  final String? grade, email;

  UserModel({required this.id, required this.username, required this.name,
    required this.role, this.grade, this.email});

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'] ?? '', username: j['username'] ?? '',
    name: j['name'] ?? j['username'] ?? '',
    role: j['role'] ?? 'teacher',
    grade: j['grade'], email: j['email'],
  );

  bool get isAdmin => role == 'admin';
  bool get isTeacher => role == 'teacher';
}

// lib/models/student.dart