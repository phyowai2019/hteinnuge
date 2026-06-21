// lib/screens/students/students_screen.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/api.dart';
import '../../services/api_service.dart';
import '../../models/student.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});
  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _search = TextEditingController();
  String _grade = 'ALL', _gender = 'ALL';
  List<StudentModel> _students = [];
  bool _loading = false;
  int _male = 0, _female = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService().getStudents(
      query: _search.text.trim(),
      grade: _grade, gender: _gender,
    );
    if (r['ok'] == true) {
      final data = (r['data'] as List? ?? [])
          .map((e) => StudentModel.fromJson(e as Map<String,dynamic>)).toList();
      setState(() {
        _students = data;
        _male = data.where((s) => s.gender == 'ကျား').length;
        _female = data.where((s) => s.gender == 'မ').length;
      });
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ကျောင်းသားစာရင်း')),
      body: Column(children: [
        // Filters
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'ရှာပါ (နာမည်/ID/ဖခင်)...',
                hintStyle: const TextStyle(fontFamily: 'Padauk'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear),
                      onPressed: () { _search.clear(); _load(); })
                  : null,
              ),
              onSubmitted: (_) => _load(),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: _grade,
                decoration: const InputDecoration(labelText: 'အတန်း',
                  labelStyle: TextStyle(fontFamily: 'Padauk')),
                items: ['ALL', ...ApiConfig.grades].map((g) =>
                  DropdownMenuItem(value: g, child: Text(g == 'ALL' ? 'အားလုံး' : g,
                    style: const TextStyle(fontFamily: 'Padauk')))).toList(),
                onChanged: (v) { setState(() => _grade = v!); _load(); },
              )),
              const SizedBox(width: 10),
              Expanded(child: DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'ကျား/မ',
                  labelStyle: TextStyle(fontFamily: 'Padauk')),
                items: [
                  const DropdownMenuItem(value: 'ALL', child: Text('အားလုံး', style: TextStyle(fontFamily: 'Padauk'))),
                  const DropdownMenuItem(value: 'ကျား', child: Text('ကျား', style: TextStyle(fontFamily: 'Padauk'))),
                  const DropdownMenuItem(value: 'မ', child: Text('မ', style: TextStyle(fontFamily: 'Padauk'))),
                ],
                onChanged: (v) { setState(() => _gender = v!); _load(); },
              )),
            ]),
          ]),
        ),
        // Summary
        Container(
          color: AppTheme.bg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(children: [
            Text('စုစုပေါင်း: ${_students.length} ဦး',
              style: const TextStyle(fontFamily: 'Padauk', fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFF3b82f6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(99)),
              child: Text('ကျား: $_male', style: const TextStyle(fontSize: 11, fontFamily: 'Padauk',
                color: Color(0xFF3b82f6)))),
            const SizedBox(width: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFec4899).withOpacity(0.1),
                borderRadius: BorderRadius.circular(99)),
              child: Text('မ: $_female', style: const TextStyle(fontSize: 11, fontFamily: 'Padauk',
                color: Color(0xFFec4899)))),
          ]),
        ),
        // List
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
            ? const Center(child: Text('ကျောင်းသား မတွေ့ပါ',
                style: TextStyle(fontFamily: 'Padauk', color: AppTheme.textMuted)))
            : ListView.builder(
                itemCount: _students.length,
                itemBuilder: (ctx, i) => _StudentTile(_students[i]),
              )),
      ]),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final StudentModel s;
  const _StudentTile(this.s);

  @override
  Widget build(BuildContext context) {
    final isMale = s.gender == 'ကျား';
    final gColor = isMale ? const Color(0xFF3b82f6) : const Color(0xFFec4899);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: gColor.withOpacity(0.1),
          child: Text(s.name.isNotEmpty ? s.name[0] : '?',
            style: TextStyle(fontFamily: 'Padauk', color: gColor, fontWeight: FontWeight.w700)),
        ),
        title: Text(s.name, style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600)),
        subtitle: Row(children: [
          _Chip(s.grade, AppTheme.primary),
          const SizedBox(width: 6),
          _Chip(s.gender, gColor),
          const SizedBox(width: 6),
          if (s.age > 0) _Chip('${s.age}နှစ်', AppTheme.textMuted),
        ]),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(s.id, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontFamily: 'Padauk')),
          if (s.phone != null && s.phone!.isNotEmpty)
            const Icon(Icons.phone, size: 14, color: AppTheme.textMuted),
        ]),
        onTap: () => _showDetail(context),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.6, maxChildSize: 0.9,
        builder: (_, ctrl) => SingleChildScrollView(controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(99)))),
            const SizedBox(height: 20),
            Center(child: CircleAvatar(radius: 36,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: Text(s.name.isNotEmpty ? s.name[0] : '?',
                style: const TextStyle(fontSize: 28, fontFamily: 'Padauk', color: AppTheme.primary, fontWeight: FontWeight.w700)))),
            const SizedBox(height: 12),
            Center(child: Text(s.name, style: const TextStyle(fontSize: 20, fontFamily: 'Padauk', fontWeight: FontWeight.w700))),
            const SizedBox(height: 20),
            for (final row in [
              ['ID', s.id], ['အတန်း', s.grade], ['ကျား/မ', s.gender],
              ['မွေးနေ့', s.dob ?? '-'], ['ဖခင်', s.father ?? '-'],
              ['မိခင်', s.mother ?? '-'], ['ဖုန်း', s.phone ?? '-'],
              ['လိပ်စာ', s.address ?? '-'],
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  SizedBox(width: 80, child: Text(row[0] ?? '',
                    style: const TextStyle(fontFamily: 'Padauk', color: AppTheme.textMuted, fontSize: 13))),
                  const SizedBox(width: 10),
                  Expanded(child: Text(row[1] ?? '-',
                    style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600))),
                ]),
              ),
          ]),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label; final Color color;
  const _Chip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: TextStyle(fontSize: 10, fontFamily: 'Padauk', color: color)));
}
