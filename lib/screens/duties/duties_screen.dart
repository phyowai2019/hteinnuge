// lib/screens/duties/duties_screen.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class DutiesScreen extends StatefulWidget {
  const DutiesScreen({super.key});
  @override State<DutiesScreen> createState() => _DutiesScreenState();
}

class _DutiesScreenState extends State<DutiesScreen> {
  List _duties = [];
  bool _loading = false;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService().getDuties();
    if (r['ok'] == true) setState(() => _duties = r['data'] as List? ?? []);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('တာဝန်ပေးမှတ်တမ်း'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _duties.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('📋', style: TextStyle(fontSize: 48)),
              SizedBox(height: 12),
              Text('တာဝန်မှတ်တမ်း မရှိသေးပါ',
                style: TextStyle(fontFamily: 'Padauk', color: AppTheme.textMuted)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _duties.length,
              itemBuilder: (ctx, i) {
                final d = _duties[i] as Map;
                final dateStr = d['Date'] as String? ?? '';
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      Container(width: 44, height: 44,
                        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.assignment_ind, color: AppTheme.primary)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(d['Task'] as String? ?? '',
                          style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.person, size: 13, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(d['TeacherName'] as String? ?? '',
                            style: const TextStyle(fontFamily: 'Padauk', fontSize: 12, color: AppTheme.textMuted)),
                          if ((d['Time'] as String? ?? '').isNotEmpty) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.schedule, size: 13, color: AppTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(d['Time'] as String? ?? '',
                              style: const TextStyle(fontFamily: 'Padauk', fontSize: 12, color: AppTheme.textMuted)),
                          ],
                        ]),
                        if ((d['Place'] as String? ?? '').isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.location_on, size: 13, color: AppTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(d['Place'] as String? ?? '',
                              style: const TextStyle(fontFamily: 'Padauk', fontSize: 12, color: AppTheme.textMuted)),
                          ]),
                        ],
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6)),
                          child: Text(dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr,
                            style: const TextStyle(fontSize: 10, fontFamily: 'Padauk', color: AppTheme.warning))),
                      ]),
                    ]),
                  ),
                );
              }),
    );
  }
}
