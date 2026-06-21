// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(title: const Text('ကိုယ်ရေးအချက်အလက်')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Avatar
        Center(child: CircleAvatar(radius: 48,
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: Text(user.name.isNotEmpty ? user.name[0] : '?',
            style: const TextStyle(fontSize: 40, fontFamily: 'Padauk', color: AppTheme.primary,
              fontWeight: FontWeight.w700)))),
        const SizedBox(height: 12),
        Center(child: Text(user.name,
          style: const TextStyle(fontSize: 20, fontFamily: 'Padauk', fontWeight: FontWeight.w700))),
        Center(child: Container(margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(99)),
          child: Text(user.role.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontFamily: 'Padauk', color: AppTheme.primary,
              fontWeight: FontWeight.w700)))),
        const SizedBox(height: 24),
        // Info card
        Card(child: Column(children: [
          _InfoTile(Icons.badge, 'Username', user.username),
          const Divider(height: 1),
          _InfoTile(Icons.person, 'အမည်', user.name),
          if (user.grade != null) ...[
            const Divider(height: 1),
            _InfoTile(Icons.school, 'အတန်း', user.grade!),
          ],
          if (user.email != null && user.email!.isNotEmpty) ...[
            const Divider(height: 1),
            _InfoTile(Icons.email, 'Email', user.email!),
          ],
        ])),
        const SizedBox(height: 16),
        // Logout button
        ElevatedButton.icon(
          onPressed: () => _confirmLogout(context),
          icon: const Icon(Icons.logout),
          label: const Text('ထွက်ရန်', style: TextStyle(fontFamily: 'Padauk', fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.danger,
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ]),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('ထွက်ရန်', style: TextStyle(fontFamily: 'Padauk')),
      content: const Text('တကယ်ထွက်မည်လား?', style: TextStyle(fontFamily: 'Padauk')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(_),
          child: const Text('မလုပ်', style: TextStyle(fontFamily: 'Padauk'))),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(_);
            context.read<AuthProvider>().logout();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
          child: const Text('ထွက်', style: TextStyle(fontFamily: 'Padauk')),
        ),
      ],
    ));
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon; final String label, value;
  const _InfoTile(this.icon, this.label, this.value);
  @override Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppTheme.primary, size: 20),
    title: Text(label, style: const TextStyle(fontFamily: 'Padauk', fontSize: 12, color: AppTheme.textMuted)),
    subtitle: Text(value, style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600, fontSize: 14)),
  );
}
