// lib/screens/timetable/timetable_screen.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/api.dart';
import '../../services/api_service.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});
  @override State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String _grade = 'Grade 1';
  List _rows = [];
  List<String> _periods = [];
  bool _loading = false;
  static const _days = ['တနင်္လာ','အင်္ဂါ','ဗုဒ္ဓဟူး','ကြာသပတေး','သောကြာ','စနေ'];

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService().getTimetable(_grade);
    if (r['ok'] == true) {
      setState(() {
        _rows = r['data'] as List? ?? [];
        _periods = (r['periods'] as List? ?? []).cast<String>();
        if (_periods.isEmpty) _periods = List.generate(7, (i) => 'ကာလ ${i+1}');
      });
    }
    setState(() => _loading = false);
  }

  Map<String, Map<String, dynamic>> _buildGrid() {
    final g = <String, Map<String, dynamic>>{};
    for (final row in _rows) {
      final r = row as Map;
      g['${r['Day']}_${r['Period']}'] = r.cast<String, dynamic>();
    }
    return g;
  }

  @override
  Widget build(BuildContext context) {
    final grid = _buildGrid();
    return Scaffold(
      appBar: AppBar(
        title: const Text('အချိန်ဇယား'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: DropdownButtonFormField<String>(
            value: _grade,
            decoration: const InputDecoration(
              labelText: 'အတန်း',
              labelStyle: TextStyle(fontFamily: 'Padauk'),
            ),
            items: ApiConfig.grades.map((g) => DropdownMenuItem(
              value: g,
              child: Text(g, style: const TextStyle(fontFamily: 'Padauk')),
            )).toList(),
            onChanged: (v) { setState(() => _grade = v!); _load(); },
          ),
        ),
        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Table(
                      border: TableBorder.all(color: AppTheme.border, width: 0.8),
                      defaultColumnWidth: const FixedColumnWidth(108),
                      children: [
                        // Header
                        TableRow(
                          decoration: const BoxDecoration(color: AppTheme.primary),
                          children: [
                            const _TH(''),
                            ..._periods.map((p) => _TH(p)),
                          ],
                        ),
                        // Day rows
                        ..._days.map((day) => TableRow(children: [
                          _TH(day, bg: const Color(0xFFf1f5f9), dark: true),
                          ..._periods.map((p) {
                            final c = grid['${day}_$p'];
                            return _GridCell(
                              subject: c?['Subject'] as String? ?? '',
                              teacher: c?['TeacherName'] as String? ?? '',
                              onTap: () => _showDialog(day, p, c),
                            );
                          }),
                        ])),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ]),
    );
  }

  void _showDialog(String day, String period, Map<String, dynamic>? c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$day · $period',
          style: const TextStyle(fontFamily: 'Padauk', fontSize: 14)),
        content: c != null && (c['Subject'] as String? ?? '').isNotEmpty
          ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row('ဘာသာ', c['Subject'] as String? ?? '-'),
                _Row('ဆရာ/မ', c['TeacherName'] as String? ?? '-'),
              ])
          : const Text('ဘာသာ မသတ်မှတ်ရသေး',
              style: TextStyle(fontFamily: 'Padauk', color: AppTheme.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            child: const Text('ပိတ်', style: TextStyle(fontFamily: 'Padauk')),
          ),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String text; final Color? bg; final bool dark;
  const _TH(this.text, {this.bg, this.dark = false});
  @override Widget build(BuildContext context) => Container(
    height: 36, color: bg ?? AppTheme.primary, alignment: Alignment.center,
    child: Text(text, textAlign: TextAlign.center,
      style: TextStyle(fontSize: 10, fontFamily: 'Padauk', fontWeight: FontWeight.w600,
        color: dark ? AppTheme.textMain : Colors.white)));
}

class _GridCell extends StatelessWidget {
  final String subject, teacher; final VoidCallback onTap;
  const _GridCell({required this.subject, required this.teacher, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(height: 52, padding: const EdgeInsets.all(3),
      color: subject.isNotEmpty ? AppTheme.accent.withOpacity(0.06) : null,
      alignment: Alignment.center,
      child: subject.isNotEmpty
        ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(subject, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9.5, fontFamily: 'Padauk',
                fontWeight: FontWeight.w700, color: AppTheme.primary)),
            if (teacher.isNotEmpty) Text(teacher, textAlign: TextAlign.center, maxLines: 1,
              style: const TextStyle(fontSize: 8.5, fontFamily: 'Padauk', color: AppTheme.textMuted)),
          ])
        : const Text('+', style: TextStyle(color: AppTheme.border, fontSize: 18))));
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 60, child: Text(label,
        style: const TextStyle(fontFamily: 'Padauk', color: AppTheme.textMuted, fontSize: 13))),
      const SizedBox(width: 8),
      Expanded(child: Text(value,
        style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600))),
    ]));
}
