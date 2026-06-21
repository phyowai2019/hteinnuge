// lib/screens/attendance/rollcall_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/api.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/attendance.dart';

class RollCallScreen extends StatefulWidget {
  const RollCallScreen({super.key});
  @override
  State<RollCallScreen> createState() => _RollCallScreenState();
}

class _RollCallScreenState extends State<RollCallScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _selectedDate = ApiService().todayDate;
  String _selectedGrade = 'Grade 1';
  List<AttendanceEntry> _stuEntries = [];
  List<Map<String,dynamic>> _tchEntries = [];
  bool _loading = false;
  bool _alreadyTaken = false;
  bool _isTchTab = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() => _isTchTab = _tabs.index == 1));
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoll());
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _loadRoll() async {
    setState(() { _loading = true; _alreadyTaken = false; });
    final api = ApiService();
    final auth = context.read<AuthProvider>();
    final tg = (auth.user?.isTeacher ?? false) ? (auth.user?.grade ?? '') : '';

    if (!_isTchTab) {
      final r = await api.getDailyRoll(_selectedDate, _selectedGrade, tg);
      if (r['ok'] == true) {
        final data = r['data'] as List? ?? [];
        setState(() {
          _stuEntries = data.map((e) => AttendanceEntry.fromJson(e as Map<String,dynamic>)).toList();
          _alreadyTaken = r['alreadyTaken'] == true;
        });
      }
    } else {
      final r = await api.getTeacherDailyRoll(_selectedDate);
      if (r['ok'] == true) {
        setState(() {
          _tchEntries = (r['data'] as List? ?? []).cast<Map<String,dynamic>>();
          _alreadyTaken = r['alreadyTaken'] == true;
        });
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _saveRoll() async {
    setState(() => _loading = true);
    final api = ApiService();
    final auth = context.read<AuthProvider>();
    final tg = auth.user?.grade ?? '';
    Map<String,dynamic> r;
    if (!_isTchTab) {
      r = await api.saveDailyRoll(_selectedDate, _stuEntries.map((e) => e.toJson()).toList(), tg);
    } else {
      r = await api.saveTeacherDailyRoll(_selectedDate, _tchEntries);
    }
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(r['ok'] == true ? '✅ ${r['message']}' : '❌ ${r['error']}',
          style: const TextStyle(fontFamily: 'Padauk')),
        backgroundColor: r['ok'] == true ? AppTheme.accent : AppTheme.danger,
      ));
      if (r['ok'] == true) _loadRoll();
    }
  }

  void _markAll(String status) {
    setState(() {
      for (var e in _stuEntries) e.status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roll Call'),
        bottom: TabBar(controller: _tabs,
          labelColor: Colors.white, unselectedLabelColor: Colors.white60,
          indicatorColor: AppTheme.accent,
          tabs: const [Tab(text: 'ကျောင်းသား'), Tab(text: 'ဆရာ/မ')]),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRoll),
        ],
      ),
      body: Column(children: [
        // Date + Grade selector
        Container(
          color: AppTheme.primary,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(children: [
            // Date
            Expanded(child: GestureDetector(
              onTap: () async {
                final d = await showDatePicker(context: context,
                  initialDate: DateTime.parse(_selectedDate),
                  firstDate: DateTime(2020), lastDate: DateTime.now());
                if (d != null) {
                  setState(() => _selectedDate =
                    '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}');
                  _loadRoll();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(_selectedDate, style: const TextStyle(color: Colors.white, fontFamily: 'Padauk')),
                ]),
              ),
            )),
            if (!_isTchTab) ...[
              const SizedBox(width: 10),
              // Grade
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                  value: _selectedGrade,
                  dropdownColor: AppTheme.primary,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Padauk'),
                  iconEnabledColor: Colors.white,
                  items: ApiConfig.grades.map((g) => DropdownMenuItem(
                    value: g, child: Text(g))).toList(),
                  onChanged: (v) { setState(() => _selectedGrade = v!); _loadRoll(); },
                )),
              ),
            ],
          ]),
        ),
        // Already taken banner
        if (_alreadyTaken)
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFfef9c3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFca8a04))),
            child: Row(children: [
              const Icon(Icons.warning_amber, color: Color(0xFF854d0e), size: 20),
              const SizedBox(width: 8),
              const Expanded(child: Text('ဒီနေ့ Roll Call ပြီးသွားပြီ — ပြင်ဆင်ရန် ဆက်လုပ်နိုင်သည်',
                style: TextStyle(fontFamily: 'Padauk', fontSize: 12, color: Color(0xFF854d0e)))),
            ]),
          ),
        // Mark all buttons (student tab only)
        if (!_isTchTab && _stuEntries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(children: [
              const Text('အားလုံး:', style: TextStyle(fontSize: 12, fontFamily: 'Padauk', color: AppTheme.textMuted)),
              const SizedBox(width: 8),
              for (final s in ['တက်', 'ခွင့်', 'ပျက်'])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: TextButton(
                    onPressed: () => _markAll(s),
                    style: TextButton.styleFrom(
                      backgroundColor: _statusColor(s).withOpacity(0.1),
                      foregroundColor: _statusColor(s),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: Text(s, style: const TextStyle(fontSize: 12, fontFamily: 'Padauk')),
                  ),
                ),
              const Spacer(),
              Text('${_stuEntries.where((e) => e.isPresent).length}/${_stuEntries.length} တက်',
                style: const TextStyle(fontSize: 11, fontFamily: 'Padauk', color: AppTheme.accent,
                  fontWeight: FontWeight.w700)),
            ]),
          ),
        // List
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _isTchTab ? _buildTchList() : _buildStuList()),
        // Save button
        SafeArea(child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _loading ? null : _saveRoll,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: _alreadyTaken ? AppTheme.warning : AppTheme.accent,
            ),
            child: Text(_alreadyTaken ? '💾 ပြင်ဆင်သိမ်းဆည်း' : '💾 သိမ်းဆည်း',
              style: const TextStyle(fontFamily: 'Padauk', fontSize: 16)),
          ),
        )),
      ]),
    );
  }

  Widget _buildStuList() {
    if (_stuEntries.isEmpty) return const Center(child: Text('ကျောင်းသား မတွေ့ပါ',
      style: TextStyle(fontFamily: 'Padauk', color: AppTheme.textMuted)));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _stuEntries.length,
      itemBuilder: (ctx, i) {
        final e = _stuEntries[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              // Avatar
              CircleAvatar(backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(e.name.isNotEmpty ? e.name[0] : '?',
                  style: const TextStyle(fontFamily: 'Padauk', color: AppTheme.primary, fontWeight: FontWeight.w700))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.name, style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600)),
                Text('${e.studentId} · ${e.gender}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ])),
              // Status buttons
              Row(children: ['တက်', 'ခွင့်', 'ပျက်'].map((s) {
                final selected = e.status == s;
                final color = _statusColor(s);
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => e.status = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: selected ? color : color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: selected ? color : color.withOpacity(0.3)),
                      ),
                      child: Text(s, style: TextStyle(
                        fontSize: 11, fontFamily: 'Padauk',
                        color: selected ? Colors.white : color,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      )),
                    ),
                  ),
                );
              }).toList()),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildTchList() {
    if (_tchEntries.isEmpty) return const Center(child: Text('ဆရာ/မ မတွေ့ပါ',
      style: TextStyle(fontFamily: 'Padauk', color: AppTheme.textMuted)));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _tchEntries.length,
      itemBuilder: (ctx, i) {
        final e = _tchEntries[i];
        final status = e['status'] as String? ?? 'မမှတ်ရသေး';
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              CircleAvatar(backgroundColor: AppTheme.primary2.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppTheme.primary2)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e['name'] ?? '', style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600)),
                Text(e['id'] ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ])),
              Row(children: ['တက်', 'ခွင့်', 'ပျက်'].map((s) {
                final sel = status == s;
                final color = _statusColor(s);
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _tchEntries[i] = {...e, 'status': s}),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: sel ? color : color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: sel ? color : color.withOpacity(0.3))),
                      child: Text(s, style: TextStyle(
                        fontSize: 11, fontFamily: 'Padauk',
                        color: sel ? Colors.white : color,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                    ),
                  ),
                );
              }).toList()),
            ]),
          ),
        );
      },
    );
  }

  Color _statusColor(String s) {
    switch(s) {
      case 'တက်': return AppTheme.accent;
      case 'ခွင့်': return AppTheme.warning;
      case 'ပျက်': return AppTheme.danger;
      default: return AppTheme.textMuted;
    }
  }
}
