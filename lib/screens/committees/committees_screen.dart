// lib/screens/committees/committees_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class CommitteesScreen extends StatefulWidget {
  const CommitteesScreen({super.key});
  @override State<CommitteesScreen> createState() => _CommitteesScreenState();
}

class _CommitteesScreenState extends State<CommitteesScreen> {
  List _committees = [];
  bool _loading = false;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService().getCommittees();
    if (r['ok'] == true) setState(() => _committees = r['data'] as List? ?? []);
    setState(() => _loading = false);
  }

  List<dynamic> _parseMembers(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw;
    try { return jsonDecode(raw as String) as List; } catch (_) { return []; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ကော်မတီစာရင်း'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _committees.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('🏛️', style: TextStyle(fontSize: 48)),
              SizedBox(height: 12),
              Text('ကော်မတီ မရှိသေးပါ',
                style: TextStyle(fontFamily: 'Padauk', color: AppTheme.textMuted)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _committees.length,
              itemBuilder: (ctx, i) {
                final c = _committees[i] as Map;
                final members = _parseMembers(c['Members']);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ExpansionTile(
                    leading: Container(width: 42, height: 42,
                      decoration: BoxDecoration(color: AppTheme.primary2.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.groups, color: AppTheme.primary2)),
                    title: Text(c['Name'] as String? ?? '',
                      style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w700)),
                    subtitle: (c['Purpose'] as String? ?? '').isNotEmpty
                      ? Text(c['Purpose'] as String? ?? '',
                          style: const TextStyle(fontFamily: 'Padauk', fontSize: 12, color: AppTheme.textMuted))
                      : null,
                    children: [
                      if (members.isNotEmpty) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: members.asMap().entries.map((e) {
                              final m = e.value as Map;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(children: [
                                  CircleAvatar(radius: 16,
                                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                                    child: Text('${e.key + 1}',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.primary,
                                        fontWeight: FontWeight.w700))),
                                  const SizedBox(width: 12),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(m['name'] as String? ?? '',
                                      style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600)),
                                    if ((m['role'] as String? ?? '').isNotEmpty)
                                      Text(m['role'] as String? ?? '',
                                        style: const TextStyle(fontFamily: 'Padauk', fontSize: 11, color: AppTheme.primary2)),
                                  ])),
                                  if ((m['duty'] as String? ?? '').isNotEmpty)
                                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(5)),
                                      child: Text(m['duty'] as String? ?? '',
                                        style: const TextStyle(fontSize: 10, fontFamily: 'Padauk', color: AppTheme.accent))),
                                ]),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
    );
  }
}
