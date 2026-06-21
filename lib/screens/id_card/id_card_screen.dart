// lib/screens/id_card/id_card_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/theme.dart';
import '../../models/student.dart';
import '../../services/api_service.dart';

class IdCardScreen extends StatefulWidget {
  const IdCardScreen({super.key});
  @override State<IdCardScreen> createState() => _IdCardScreenState();
}

class _IdCardScreenState extends State<IdCardScreen> {
  final _ctrl = TextEditingController();
  StudentModel? _student;
  bool _loading = false;
  String? _error;
  String _schoolName = 'မူလတန်းကျောင်း';
  String _year = '2026';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final r = await ApiService().getSettings();
    if (r['ok'] == true && r['data'] != null) {
      final d = r['data'] as Map;
      setState(() {
        _schoolName = d['School_Name'] as String? ?? 'မူလတန်းကျောင်း';
        _year = d['Academic_Year'] as String? ?? '2026';
      });
    }
  }

  Future<void> _search() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    setState(() { _loading = true; _error = null; _student = null; });
    final r = await ApiService().getStudents(query: q);
    setState(() => _loading = false);
    if (r['ok'] == true) {
      final data = r['data'] as List? ?? [];
      if (data.isEmpty) {
        setState(() => _error = 'ကျောင်းသား မတွေ့ပါ');
      } else {
        setState(() => _student = StudentModel.fromJson(data.first as Map<String, dynamic>));
      }
    } else {
      setState(() => _error = r['error'] as String?);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ID Card')),
      body: Column(children: [
        // Search
        Container(
          color: Colors.white, padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _ctrl,
              decoration: const InputDecoration(
                hintText: 'ကျောင်းသား ID သို့မဟုတ် နာမည် ရှာပါ...',
                hintStyle: TextStyle(fontFamily: 'Padauk'),
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _search(),
            )),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _search,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
              child: const Text('ရှာ', style: TextStyle(fontFamily: 'Padauk'))),
          ]),
        ),
        // Result
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
            ? Center(child: Text(_error!, style: const TextStyle(fontFamily: 'Padauk', color: AppTheme.danger)))
            : _student == null
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('🪪', style: TextStyle(fontSize: 56)),
                  SizedBox(height: 12),
                  Text('ကျောင်းသား ID ထည့်ပြီး ရှာပါ',
                    style: TextStyle(fontFamily: 'Padauk', color: AppTheme.textMuted)),
                ]))
              : SingleChildScrollView(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildCard(_student!),
                )),
        ),
      ]),
    );
  }

  Widget _buildCard(StudentModel s) {
    final qrData = '${s.id}|${s.name}|${s.grade}|$_year';
    return Column(children: [
      // ID Card
      Container(
        width: double.infinity, constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(color: AppTheme.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            child: Column(children: [
              Text('🏫 $_schoolName',
                style: const TextStyle(color: Colors.white, fontFamily: 'Padauk',
                  fontSize: 15, fontWeight: FontWeight.w700)),
              Text('ကျောင်းသားမှတ်ပုံတင် · $_year',
                style: const TextStyle(color: Colors.white70, fontFamily: 'Padauk', fontSize: 11)),
            ]),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Photo placeholder + QR
              Column(children: [
                Container(width: 80, height: 90,
                  decoration: BoxDecoration(color: AppTheme.bg,
                    borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.border)),
                  child: const Icon(Icons.person, size: 48, color: AppTheme.textMuted)),
                const SizedBox(height: 8),
                QrImageView(data: qrData, version: QrVersions.auto, size: 72),
              ]),
              const SizedBox(width: 16),
              // Info
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _InfoRow('အမည်', s.name, bold: true),
                _InfoRow('အတန်း', s.grade),
                _InfoRow('ကျောင်းသားအမှတ်', s.id),
                if (s.dob != null && s.dob!.isNotEmpty) _InfoRow('မွေးနေ့', s.dob!),
                if (s.father != null && s.father!.isNotEmpty) _InfoRow('ဖခင်', s.father!),
                if (s.phone != null && s.phone!.isNotEmpty) _InfoRow('ဖုန်း', s.phone!),
              ])),
            ]),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: AppTheme.bg,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: const Border(top: BorderSide(color: AppTheme.border))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('ကျောင်းအုပ်ကြီး: ............',
                style: TextStyle(fontSize: 11, fontFamily: 'Padauk', color: AppTheme.textMuted)),
              Text(s.id, style: const TextStyle(fontSize: 13, fontFamily: 'Padauk',
                fontWeight: FontWeight.w700, color: AppTheme.primary)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 20),
      // Actions
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Print feature - ၂.၀ တွင် ထည့်မည်',
              style: TextStyle(fontFamily: 'Padauk')))),
          icon: const Icon(Icons.print),
          label: const Text('Print', style: TextStyle(fontFamily: 'Padauk')),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Share feature - ၂.၀ တွင် ထည့်မည်',
              style: TextStyle(fontFamily: 'Padauk')))),
          icon: const Icon(Icons.share),
          label: const Text('Share', style: TextStyle(fontFamily: 'Padauk')),
        ),
      ]),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value; final bool bold;
  const _InfoRow(this.label, this.value, {this.bold = false});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 9, fontFamily: 'Padauk', color: AppTheme.textMuted)),
      Text(value, style: TextStyle(fontSize: 13, fontFamily: 'Padauk',
        fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
    ]));
}
