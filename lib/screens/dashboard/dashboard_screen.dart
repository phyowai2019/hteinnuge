// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      context.read<AppProvider>().loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app  = context.watch<AppProvider>();
    final stats = app.dashStats;
    final today = app.todayAtt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh),
            onPressed: () => app.loadDashboard()),
          const SizedBox(width: 8),
        ],
      ),
      body: app.loadingDash
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => app.loadDashboard(),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              // Welcome banner
              _WelcomeBanner(name: auth.user?.name ?? '', role: auth.user?.role ?? ''),
              const SizedBox(height: 16),
              // Stat cards row 1
              Row(children: [
                _StatCard('ကျောင်းသား', '${stats?['totalStudents'] ?? 0}',
                  Icons.people, AppTheme.primary),
                const SizedBox(width: 12),
                _StatCard('ဆရာ/မ', '${stats?['totalTeachers'] ?? 0}',
                  Icons.school, AppTheme.primary2),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _StatCard('ယနေ့တက်', '${today?['students']?['present'] ?? 0}',
                  Icons.how_to_reg, AppTheme.accent),
                const SizedBox(width: 12),
                _StatCard('ယနေ့ပျက်', '${today?['students']?['absent'] ?? 0}',
                  Icons.person_off, AppTheme.danger),
              ]),
              const SizedBox(height: 20),
              // Grade bar chart
              const Text('အတန်းလိုက်ကျောင်းသား',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  fontFamily: 'Padauk', color: AppTheme.textMain)),
              const SizedBox(height: 10),
              if (stats != null) _GradeChart(gradeCount: stats['gradeCount'] ?? {},
                gradeGender: stats['gradeGender'] ?? {}),
              const SizedBox(height: 20),
              // Today attendance by grade
              if (today != null) ...[
                const Text('ယနေ့ တက်ရောက်မှု',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    fontFamily: 'Padauk', color: AppTheme.textMain)),
                const SizedBox(height: 10),
                _TodayAttCard(data: today),
              ],
            ]),
          ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final String name, role;
  const _WelcomeBanner({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String greeting;
    if (now.hour < 12) greeting = 'မင်္ဂလာ မနက်ခင်း';
    else if (now.hour < 17) greeting = 'မင်္ဂလာ နေ့ခင်း';
    else greeting = 'မင်္ဂလာ ညနေ';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF2d5f9e)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        const Text('🏫', style: TextStyle(fontSize: 36)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(greeting,
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Padauk')),
          Text(name,
            style: const TextStyle(color: Colors.white, fontSize: 17,
              fontWeight: FontWeight.w700, fontFamily: 'Padauk')),
          Container(margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(99)),
            child: Text(role.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Padauk'))),
        ])),
        Text('${now.day}/${now.month}/${now.year}',
          style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Card(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, fontFamily: 'Padauk',
            color: AppTheme.textMuted)),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        ]),
      ]),
    )));
  }
}

class _GradeChart extends StatelessWidget {
  final Map gradeCount, gradeGender;
  const _GradeChart({required this.gradeCount, required this.gradeGender});

  @override
  Widget build(BuildContext context) {
    final grades = ['KG','Grade 1','Grade 2','Grade 3','Grade 4','Grade 5',
                    'Grade 6','Grade 7','Grade 8','Grade 9'];
    final maxVal = grades.map((g) => (gradeCount[g] ?? 0) as int).reduce((a,b) => a>b?a:b);
    if (maxVal == 0) return const SizedBox();

    return Card(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: grades.asMap().entries.map((e) {
          final g = e.value;
          final total = (gradeCount[g] ?? 0) as int;
          final gg = gradeGender[g] as Map? ?? {};
          final male = (gg['male'] ?? 0) as int;
          final female = (gg['female'] ?? 0) as int;
          final pct = maxVal > 0 ? total / maxVal : 0.0;
          final color = AppTheme.gradeColors[e.key % AppTheme.gradeColors.length];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(children: [
              SizedBox(width: 48, child: Text(g.replaceAll('Grade ', 'G'),
                style: const TextStyle(fontSize: 11, fontFamily: 'Padauk',
                  color: AppTheme.textMuted))),
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct, minHeight: 22,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              )),
              const SizedBox(width: 8),
              SizedBox(width: 80, child: total > 0
                ? RichText(text: TextSpan(
                    style: const TextStyle(fontSize: 10, fontFamily: 'Padauk'),
                    children: [
                      TextSpan(text: '♂$male ', style: const TextStyle(color: Color(0xFF3b82f6))),
                      TextSpan(text: '♀$female', style: const TextStyle(color: Color(0xFFec4899))),
                    ]))
                : const Text('0', style: TextStyle(fontSize: 11, color: AppTheme.textMuted))),
            ]),
          );
        }).toList(),
      ),
    ));
  }
}

class _TodayAttCard extends StatelessWidget {
  final Map data;
  const _TodayAttCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final stu = data['students'] as Map? ?? {};
    final tch = data['teachers'] as Map? ?? {};
    return Card(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _AttBadge('ကျောင်းသား တက်', stu['present'] ?? 0, AppTheme.accent),
          const SizedBox(width: 8),
          _AttBadge('ခွင့်', stu['leave'] ?? 0, AppTheme.warning),
          const SizedBox(width: 8),
          _AttBadge('ပျက်', stu['absent'] ?? 0, AppTheme.danger),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _AttBadge('ဆရာ တက်', tch['present'] ?? 0, AppTheme.primary),
          const SizedBox(width: 8),
          _AttBadge('ခွင့်', tch['leave'] ?? 0, AppTheme.warning),
          const SizedBox(width: 8),
          _AttBadge('ပျက်', tch['absent'] ?? 0, AppTheme.danger),
        ]),
      ]),
    ));
  }
}

class _AttBadge extends StatelessWidget {
  final String label; final int count; final Color color;
  const _AttBadge(this.label, this.count, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3))),
    child: Column(children: [
      Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: const TextStyle(fontSize: 9, fontFamily: 'Padauk', color: AppTheme.textMuted)),
    ]),
  );
}
