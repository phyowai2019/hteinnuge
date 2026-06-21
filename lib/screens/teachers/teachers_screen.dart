// lib/screens/teachers/teachers_screen.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});
  @override State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  List _teachers = [];
  bool _loading = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService().getAllTeachers();
    if (r['ok'] == true) setState(() => _teachers = r['data'] as List? ?? []);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ဆရာ/မ စာရင်း'),
      actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)]),
    body: _loading ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
          itemCount: _teachers.length,
          itemBuilder: (ctx, i) {
            final t = _teachers[i] as Map;
            return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFe0e7ff),
                  child: Icon(Icons.person, color: AppTheme.primary2)),
                title: Text(t['Name'] ?? '', style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600)),
                subtitle: Text('${t['TeacherID'] ?? ''} · ${t['Position'] ?? ''}',
                  style: const TextStyle(fontFamily: 'Padauk', fontSize: 12)),
                trailing: Text(t['Status'] ?? '', style: const TextStyle(fontSize: 11, fontFamily: 'Padauk', color: AppTheme.accent)),
              ));
          }),
  );
}

