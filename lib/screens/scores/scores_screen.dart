// lib/screens/scores/scores_screen.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/api.dart';
import '../../services/api_service.dart';

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({super.key});
  @override State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  String _grade = 'Grade 1';
  List _students = [];
  List<String> _examNames = ['Exam 1','Exam 2','Exam 3','Exam 4','Final'];
  bool _loading = false;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService().getStudents(grade: _grade);
    if (r['ok'] == true) setState(() => _students = r['data'] as List? ?? []);
    // Load exam names from settings
    final s = await ApiService().getSettings();
    if (s['ok'] == true && s['data'] != null) {
      final d = s['data'] as Map;
      setState(() => _examNames = [
        d['Exam_1_Name'] ?? 'Exam 1', d['Exam_2_Name'] ?? 'Exam 2',
        d['Exam_3_Name'] ?? 'Exam 3', d['Exam_4_Name'] ?? 'Exam 4',
        d['Final_Exam_Name'] ?? 'Final',
      ]);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('အမှတ်ထည့်သွင်း'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: Column(children: [
        Container(
          color: Colors.white, padding: const EdgeInsets.all(12),
          child: DropdownButtonFormField<String>(
            value: _grade,
            decoration: const InputDecoration(labelText: 'အတန်း',
              labelStyle: TextStyle(fontFamily: 'Padauk')),
            items: ApiConfig.grades.map((g) => DropdownMenuItem(
              value: g, child: Text(g, style: const TextStyle(fontFamily: 'Padauk')))).toList(),
            onChanged: (v) { setState(() => _grade = v!); _load(); },
          ),
        ),
        // Summary header
        Container(
          color: AppTheme.bg, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(children: [
            Text('ကျောင်းသား ${_students.length} ဦး',
              style: const TextStyle(fontFamily: 'Padauk', fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
            ? const Center(child: Text('ကျောင်းသား မတွေ့ပါ',
                style: TextStyle(fontFamily: 'Padauk', color: AppTheme.textMuted)))
            : ListView.builder(
                itemCount: _students.length,
                itemBuilder: (ctx, i) {
                  final s = _students[i] as Map;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        child: Text((s['Name'] as String? ?? '?').isNotEmpty
                          ? (s['Name'] as String)[0] : '?',
                          style: const TextStyle(fontFamily: 'Padauk', color: AppTheme.primary,
                            fontWeight: FontWeight.w700)),
                      ),
                      title: Text(s['Name'] as String? ?? '',
                        style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600)),
                      subtitle: Text(s['ID'] as String? ?? '',
                        style: const TextStyle(fontFamily: 'Padauk', fontSize: 11, color: AppTheme.textMuted)),
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                      onTap: () => _openScoreEntry(context, s),
                    ),
                  );
                }),
        ),
      ]),
    );
  }

  void _openScoreEntry(BuildContext context, Map student) {
    final controllers = List.generate(5, (_) => TextEditingController());
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(_).viewInsets.bottom),
        child: Container(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(99)))),
          const SizedBox(height: 16),
          Text(student['Name'] as String? ?? '',
            style: const TextStyle(fontSize: 18, fontFamily: 'Padauk', fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...List.generate(5, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextField(
              controller: controllers[i],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _examNames[i],
                labelStyle: const TextStyle(fontFamily: 'Padauk'),
                suffixText: '/ 100',
              ),
            ),
          )),
          ElevatedButton(
            onPressed: () => Navigator.pop(_),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            child: const Text('💾 သိမ်းဆည်း', style: TextStyle(fontFamily: 'Padauk')),
          ),
        ])),
      ),
    );
  }
}
