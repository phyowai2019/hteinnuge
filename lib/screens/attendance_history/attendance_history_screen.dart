// lib/screens/attendance_history/attendance_history_screen.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/api.dart';
import '../../services/api_service.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});
  @override State<AttendanceHistoryScreen> createState() => _AHState();
}

class _AHState extends State<AttendanceHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _grade = 'Grade 1';
  Map _todayData = {};
  bool _loading = false;

  @override void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }
  @override void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService().getTodayAttendanceSummary();
    if (r['ok'] == true) setState(() => _todayData = r as Map);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final stu = (_todayData['students'] as Map?) ?? {};
    final tch = (_todayData['teachers'] as Map?) ?? {};
    final byGrade = (stu['byGrade'] as Map?) ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('တက်ရောက်မှု မှတ်တမ်း'),
        bottom: TabBar(controller: _tabs,
          labelColor: Colors.white, unselectedLabelColor: Colors.white60,
          indicatorColor: AppTheme.accent,
          tabs: const [Tab(text: 'ကျောင်းသား'), Tab(text: 'ဆရာ/မ')]),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator())
        : TabBarView(controller: _tabs, children: [
          // Student attendance
          ListView(padding: const EdgeInsets.all(16), children: [
            // Summary cards
            Row(children: [
              _SumCard('တက်', stu['present'] ?? 0, AppTheme.accent),
              const SizedBox(width: 10),
              _SumCard('ခွင့်', stu['leave'] ?? 0, AppTheme.warning),
              const SizedBox(width: 10),
              _SumCard('ပျက်', stu['absent'] ?? 0, AppTheme.danger),
            ]),
            const SizedBox(height: 16),
            // Gender summary
            if ((stu['present'] ?? 0) > 0)
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                const Icon(Icons.people, color: AppTheme.primary, size: 20),
                const SizedBox(width: 10),
                Text('ကျား: ${stu['male_present'] ?? 0}  မ: ${stu['female_present'] ?? 0}',
                  style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600)),
              ]))),
            const SizedBox(height: 16),
            // By grade
            const Text('အတန်းလိုက်', style: TextStyle(fontSize: 15, fontFamily: 'Padauk',
              fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...ApiConfig.grades.map((g) {
              final gd = byGrade[g] as Map? ?? {};
              if ((gd['total'] ?? 0) == 0) return const SizedBox();
              return Card(margin: const EdgeInsets.symmetric(vertical: 3),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    Expanded(child: Text(g, style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600))),
                    _Badge('တက် ${gd['present'] ?? 0}', AppTheme.accent),
                    const SizedBox(width: 6),
                    _Badge('ခွင့် ${gd['leave'] ?? 0}', AppTheme.warning),
                    const SizedBox(width: 6),
                    _Badge('ပျက် ${gd['absent'] ?? 0}', AppTheme.danger),
                  ])));
            }),
          ]),
          // Teacher attendance
          ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [
              _SumCard('တက်', tch['present'] ?? 0, AppTheme.accent),
              const SizedBox(width: 10),
              _SumCard('ခွင့်', tch['leave'] ?? 0, AppTheme.warning),
              const SizedBox(width: 10),
              _SumCard('ပျက်', tch['absent'] ?? 0, AppTheme.danger),
            ]),
            const SizedBox(height: 16),
            ...((tch['rows'] as List?) ?? []).map((r) {
              final row = r as Map;
              final status = row['status'] as String? ?? '';
              final color = status == 'တက်' ? AppTheme.accent
                : status == 'ခွင့်' ? AppTheme.warning : AppTheme.danger;
              return Card(margin: const EdgeInsets.symmetric(vertical: 3),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFe0e7ff),
                    child: Icon(Icons.person, color: AppTheme.primary2)),
                  title: Text(row['name'] as String? ?? '',
                    style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600)),
                  trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withOpacity(0.4))),
                    child: Text(status, style: TextStyle(color: color, fontFamily: 'Padauk', fontSize: 12))),
                ));
            }),
          ]),
        ]),
    );
  }
}

class _SumCard extends StatelessWidget {
  final String label; final int count; final Color color;
  const _SumCard(this.label, this.count, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Card(child: Padding(
    padding: const EdgeInsets.all(14),
    child: Column(children: [
      Text('$count', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: const TextStyle(fontSize: 12, fontFamily: 'Padauk', color: AppTheme.textMuted)),
    ]))));
}

class _Badge extends StatelessWidget {
  final String text; final Color color;
  const _Badge(this.text, this.color);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
    child: Text(text, style: TextStyle(fontSize: 10, fontFamily: 'Padauk', color: color)));
}
