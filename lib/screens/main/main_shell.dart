// lib/screens/main/main_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../students/students_screen.dart';
import '../attendance/rollcall_screen.dart';
import '../attendance_history/attendance_history_screen.dart';
import '../timetable/timetable_screen.dart';
import '../scores/scores_screen.dart';
import '../teachers/teachers_screen.dart';
import '../duties/duties_screen.dart';
import '../committees/committees_screen.dart';
import '../finance/finance_screen.dart';
import '../id_card/id_card_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  static const _screens = <String, Widget>{
    'dashboard':  DashboardScreen(),
    'rollcall':   RollCallScreen(),
    'attendance': AttendanceHistoryScreen(),
    'students':   StudentsScreen(),
    'timetable':  TimetableScreen(),
    'scores':     ScoresScreen(),
    'teachers':   TeachersScreen(),
    'duties':     DutiesScreen(),
    'committees': CommitteesScreen(),
    'finance':    FinanceScreen(),
    'notif':      NotificationsScreen(),
    'profile':    ProfileScreen(),
    'settings':   SettingsScreen(),
  };

  static const _navAdmin = [
    _N('dashboard','ပင်မ',Icons.dashboard_outlined,Icons.dashboard),
    _N('rollcall','Roll Call',Icons.checklist_outlined,Icons.checklist),
    _N('students','ကျောင်းသား',Icons.people_outline,Icons.people),
    _N('timetable','အချိန်ဇယား',Icons.calendar_view_week_outlined,Icons.calendar_view_week),
    _N('finance','ငွေစာရင်း',Icons.account_balance_wallet_outlined,Icons.account_balance_wallet),
  ];
  static const _drawerAdmin = [
    _N('attendance','တက်ရောက်မှု',Icons.bar_chart_outlined,Icons.bar_chart),
    _N('scores','အမှတ်',Icons.assignment_outlined,Icons.assignment),
    _N('teachers','ဆရာ/မ',Icons.school_outlined,Icons.school),
    _N('duties','တာဝန်',Icons.work_outline,Icons.work),
    _N('committees','ကော်မတီ',Icons.groups_outlined,Icons.groups),
    _N('notif','အသိပေး',Icons.notifications_outlined,Icons.notifications),
    _N('settings','ဆက်တင်',Icons.settings_outlined,Icons.settings),
  ];
  static const _navTeacher = [
    _N('dashboard','ပင်မ',Icons.dashboard_outlined,Icons.dashboard),
    _N('rollcall','Roll Call',Icons.checklist_outlined,Icons.checklist),
    _N('students','ကျောင်းသား',Icons.people_outline,Icons.people),
    _N('timetable','အချိန်ဇယား',Icons.calendar_view_week_outlined,Icons.calendar_view_week),
    _N('profile','ကျွန်ုပ်',Icons.person_outline,Icons.person),
  ];
  static const _drawerTeacher = [
    _N('attendance','တက်ရောက်',Icons.bar_chart_outlined,Icons.bar_chart),
    _N('duties','တာဝန်',Icons.work_outline,Icons.work),
    _N('committees','ကော်မတီ',Icons.groups_outlined,Icons.groups),
    _N('notif','အသိပေး',Icons.notifications_outlined,Icons.notifications),
  ];
  static const _navParent = [
    _N('dashboard','ပင်မ',Icons.dashboard_outlined,Icons.dashboard),
    _N('attendance','တက်ရောက်',Icons.bar_chart_outlined,Icons.bar_chart),
    _N('notif','အသိပေး',Icons.notifications_outlined,Icons.notifications),
    _N('profile','ကျွန်ုပ်',Icons.person_outline,Icons.person),
  ];
  static const _navStudent = [
    _N('dashboard','ပင်မ',Icons.dashboard_outlined,Icons.dashboard),
    _N('timetable','အချိန်ဇယား',Icons.calendar_view_week_outlined,Icons.calendar_view_week),
    _N('scores','အမှတ်',Icons.assignment_outlined,Icons.assignment),
    _N('profile','ကျွန်ုပ်',Icons.person_outline,Icons.person),
  ];

  List<_N> _nav(String role) => switch(role) {
    'admin' => _navAdmin, 'teacher' => _navTeacher,
    'parent' => _navParent, 'student' => _navStudent, _ => _navTeacher,
  };
  List<_N> _drawer(String role) => switch(role) {
    'admin' => _drawerAdmin, 'teacher' => _drawerTeacher, _ => [],
  };

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?.role ?? 'teacher';
    final nav = _nav(role);
    final drawer = _drawer(role);
    final all = [...nav, ...drawer];
    if (_idx >= all.length) _idx = 0;

    return Scaffold(
      drawer: drawer.isEmpty ? null : _buildDrawer(drawer, all),
      body: IndexedStack(index: _idx,
        children: all.map((n) => _screens[n.key] ?? const SizedBox()).toList()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx < nav.length ? _idx : 0,
        onDestinationSelected: (i) => setState(() => _idx = i),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary.withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: nav.map((n) => NavigationDestination(
          icon: Icon(n.icon, color: AppTheme.textMuted),
          selectedIcon: Icon(n.activeIcon, color: AppTheme.primary),
          label: n.label,
        )).toList(),
      ),
    );
  }

  Widget _buildDrawer(List<_N> drawer, List<_N> all) => Drawer(child: Column(children: [
    DrawerHeader(decoration: const BoxDecoration(color: AppTheme.primary),
      child: Align(alignment: Alignment.bottomLeft, child: Column(
        mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🏫 SMS', style: TextStyle(color: Colors.white, fontSize: 22,
          fontFamily: 'Padauk', fontWeight: FontWeight.w700)),
        const Text('School Management System',
          style: TextStyle(color: Colors.white70, fontSize: 11)),
      ]))),
    Expanded(child: ListView(children: drawer.map((n) {
      final i = all.indexOf(n);
      return ListTile(
        leading: Icon(n.icon, color: i==_idx ? AppTheme.primary : AppTheme.textMuted),
        title: Text(n.label, style: TextStyle(fontFamily: 'Padauk',
          color: i==_idx ? AppTheme.primary : AppTheme.textMain,
          fontWeight: i==_idx ? FontWeight.w700 : FontWeight.w400)),
        selected: i==_idx,
        selectedTileColor: AppTheme.primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () { setState(() => _idx = i); Navigator.pop(context); },
      );
    }).toList())),
  ]));
}

class _N {
  final String key, label; final IconData icon, activeIcon;
  const _N(this.key, this.label, this.icon, this.activeIcon);
}
