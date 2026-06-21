// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List _notifs = [];
  bool _loading = false;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    // Use generic post since getNotifications may not exist
    final r = await ApiService().post('getNotifications', {});
    if (r['ok'] == true) setState(() => _notifs = r['data'] as List? ?? []);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('အသိပေးချက်'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _notifs.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('🔔', style: TextStyle(fontSize: 56)),
              SizedBox(height: 12),
              Text('အသိပေးချက် မရှိသေးပါ',
                style: TextStyle(fontFamily: 'Padauk', color: AppTheme.textMuted)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notifs.length,
              itemBuilder: (ctx, i) {
                final n = _notifs[i] as Map;
                final type = n['Type'] as String? ?? '';
                final icon = type == 'warning' ? Icons.warning_amber
                  : type == 'success' ? Icons.check_circle
                  : Icons.info_outline;
                final color = type == 'warning' ? AppTheme.warning
                  : type == 'success' ? AppTheme.accent : AppTheme.primary;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Container(width: 40, height: 40,
                      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(icon, color: color, size: 20)),
                    title: Text(n['Title'] as String? ?? '',
                      style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(n['Message'] as String? ?? '',
                        style: const TextStyle(fontFamily: 'Padauk', fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(n['Date'] as String? ?? '',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                    ]),
                    isThreeLine: true,
                  ),
                );
              }),
    );
  }
}
