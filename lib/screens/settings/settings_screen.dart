// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map _settings = {};
  bool _loading = false;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService().getSettings();
    if (r['ok'] == true && r['data'] != null) setState(() => _settings = r['data'] as Map);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return Scaffold(
      appBar: AppBar(title: const Text('ဆက်တင်')),
      body: _loading ? const Center(child: CircularProgressIndicator())
        : ListView(padding: const EdgeInsets.all(16), children: [
          // User info
          Card(child: Padding(padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(radius: 28, backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text((user?.name ?? '?').isNotEmpty ? user!.name[0] : '?',
                  style: const TextStyle(fontSize: 24, fontFamily: 'Padauk', color: AppTheme.primary,
                    fontWeight: FontWeight.w700))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user?.name ?? '', style: const TextStyle(fontFamily: 'Padauk',
                  fontSize: 16, fontWeight: FontWeight.w700)),
                Text(user?.role ?? '', style: const TextStyle(fontFamily: 'Padauk',
                  fontSize: 12, color: AppTheme.textMuted)),
              ])),
            ]))),
          const SizedBox(height: 12),
          // School info
          if (_settings.isNotEmpty) Card(child: Column(children: [
            _Tile(Icons.school, 'ကျောင်းနာမည်', _settings['School_Name'] as String? ?? '-'),
            const Divider(height: 1),
            _Tile(Icons.calendar_today, 'ပညာသင်နှစ်', _settings['Academic_Year'] as String? ?? '-'),
          ])),
          const SizedBox(height: 12),
          // App info
          Card(child: Column(children: [
            _Tile(Icons.info_outline, 'App Version', '1.0.0 (Phase 2)'),
            const Divider(height: 1),
            _Tile(Icons.api, 'Backend', 'Google Apps Script'),
          ])),
          const SizedBox(height: 20),
          // Logout
          ElevatedButton.icon(
            onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
              title: const Text('ထွက်ရန်', style: TextStyle(fontFamily: 'Padauk')),
              content: const Text('တကယ်ထွက်မည်လား?', style: TextStyle(fontFamily: 'Padauk')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(_),
                  child: const Text('မလုပ်', style: TextStyle(fontFamily: 'Padauk'))),
                ElevatedButton(
                  onPressed: () { Navigator.pop(_); auth.logout(); },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                  child: const Text('ထွက်', style: TextStyle(fontFamily: 'Padauk')),
                ),
              ],
            )),
            icon: const Icon(Icons.logout),
            label: const Text('ထွက်ရန်', style: TextStyle(fontFamily: 'Padauk', fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger, minimumSize: const Size.fromHeight(48)),
          ),
        ]),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon; final String label, value;
  const _Tile(this.icon, this.label, this.value);
  @override Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppTheme.primary, size: 20),
    title: Text(label, style: const TextStyle(fontFamily: 'Padauk', fontSize: 12, color: AppTheme.textMuted)),
    subtitle: Text(value, style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600)),
  );
}
