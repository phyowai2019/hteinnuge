// lib/screens/finance/finance_screen.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});
  @override State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  List _groups = [];
  Map? _curGroup;
  Map? _data;
  bool _loading = false;

  @override void initState() { super.initState(); _loadGroups(); }

  Future<void> _loadGroups() async {
    setState(() => _loading = true);
    final r = await ApiService().getFinanceGroups();
    if (r['ok'] == true) {
      final groups = r['data'] as List? ?? [];
      setState(() { _groups = groups; });
      if (groups.isNotEmpty) {
        _curGroup = (_groups.first as Map).cast<String,dynamic>();
        await _loadData(_curGroup!['ID'] as String);
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _loadData(String groupId) async {
    setState(() => _loading = true);
    final r = await ApiService().getFinanceData(groupId);
    if (r['ok'] == true) setState(() => _data = r);
    setState(() => _loading = false);
  }

  String _fmt(dynamic n) => (n as num? ?? 0).round().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ငွေစာရင်းရှင်းတမ်း'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGroups),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showGroupDialog(),
          ),
        ],
      ),
      body: _loading && _groups.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('💰', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  const Text('စာရင်း မရှိသေး', style: TextStyle(fontFamily: 'Padauk', color: AppTheme.textMuted)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showGroupDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('စာရင်းအမည် ဖန်တီးရန်', style: TextStyle(fontFamily: 'Padauk')),
                  ),
                ]))
              : Column(children: [
                  // Group tabs
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(children: [
                      Expanded(child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: _groups.map((g) {
                          final gm = g as Map;
                          final active = _curGroup?['ID'] == gm['ID'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              InkWell(
                                onTap: () {
                                  setState(() => _curGroup = gm.cast<String,dynamic>());
                                  _loadData(gm['ID'] as String);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: active ? AppTheme.primary : AppTheme.bg,
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
                                    border: Border.all(color: active ? AppTheme.primary : AppTheme.border),
                                  ),
                                  child: Text(gm['GroupName'] as String? ?? '',
                                    style: TextStyle(fontFamily: 'Padauk', fontSize: 13,
                                      color: active ? Colors.white : AppTheme.textMain,
                                      fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
                                ),
                              ),
                              // Delete tab button
                              InkWell(
                                onTap: () => _confirmDeleteGroup(gm),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFfee2e2),
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: const Icon(Icons.delete_outline, size: 15, color: AppTheme.danger),
                                ),
                              ),
                            ]),
                          );
                        }).toList()),
                      )),
                    ]),
                  ),
                  // Content
                  Expanded(child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContent()),
                ]),
      floatingActionButton: _curGroup != null
          ? FloatingActionButton.extended(
              onPressed: () => _showIncomeDialog(),
              icon: const Icon(Icons.add),
              label: const Text('ဝင်ငွေ ထည့်', style: TextStyle(fontFamily: 'Padauk')),
              backgroundColor: AppTheme.accent,
            )
          : null,
    );
  }

  Widget _buildContent() {
    if (_data == null) return const SizedBox();
    final totalIncome = (_data!['totalIncome'] as num?)?.toDouble() ?? 0;
    final totalExpense = (_data!['totalExpense'] as num?)?.toDouble() ?? 0;
    final balance = (_data!['balance'] as num?)?.toDouble() ?? 0;
    final items = _data!['data'] as List? ?? [];

    return ListView(padding: const EdgeInsets.all(12), children: [
      // Summary row
      Row(children: [
        _SumCard('ဝင်ငွေပေါင်း', _fmt(totalIncome), AppTheme.accent),
        const SizedBox(width: 8),
        _SumCard('သုံးစွဲငွေပေါင်း', _fmt(totalExpense), AppTheme.danger),
        const SizedBox(width: 8),
        _SumCard('ကျန်ငွေ', _fmt(balance), balance >= 0 ? AppTheme.primary : AppTheme.danger),
      ]),
      const SizedBox(height: 12),
      // Income items
      if (items.isEmpty)
        Card(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: Column(children: [
            const Text('📋', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            const Text('ဝင်ငွေ မရှိသေး', style: TextStyle(fontFamily: 'Padauk', color: AppTheme.textMuted)),
          ])),
        ))
      else
        ...items.map((inc) => _IncomeCard(
          inc: inc as Map,
          fmt: _fmt,
          groupName: _curGroup?['GroupName'] as String? ?? '',
          onAddExpense: (incId) => _showExpenseDialog(incId),
          onEditIncome: (inc) => _showIncomeDialog(existing: inc),
          onDeleteIncome: (id) => _deleteIncome(id),
          onEditExpense: (exp, incId) => _showExpenseDialog(incId, existing: exp),
          onDeleteExpense: (id) => _deleteExpense(id),
        )),
      const SizedBox(height: 80),
    ]);
  }

  void _confirmDeleteGroup(Map g) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('ဖျက်ရန်', style: TextStyle(fontFamily: 'Padauk')),
      content: Text('"${g['GroupName']}" နှင့် ဝင်ငွေ၊ သုံးစွဲမှတ်တမ်း အားလုံး ဖျက်မည်။ တကယ်ဖျက်မည်လား?',
        style: const TextStyle(fontFamily: 'Padauk')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: const Text('မလုပ်', style: TextStyle(fontFamily: 'Padauk'))),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            final r = await ApiService().deleteFinanceGroup(g['ID'] as String);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(r['ok']==true ? 'ဖျက်ပြီး' : r['error']??'Error',
                  style: const TextStyle(fontFamily: 'Padauk')),
                backgroundColor: r['ok']==true ? AppTheme.accent : AppTheme.danger,
              ));
              if (r['ok']==true) { _curGroup=null; _data=null; _loadGroups(); }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
          child: const Text('ဖျက်', style: TextStyle(fontFamily: 'Padauk')),
        ),
      ],
    ));
  }

  void _showGroupDialog([Map? existing]) {
    final ctrl = TextEditingController(text: existing?['GroupName'] as String? ?? '');
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(existing != null ? 'စာရင်းအမည် ပြင်ရန်' : 'စာရင်းအမည်သစ်',
        style: const TextStyle(fontFamily: 'Padauk')),
      content: TextField(controller: ctrl,
        decoration: const InputDecoration(labelText: 'စာရင်းအမည်',
          labelStyle: TextStyle(fontFamily: 'Padauk'))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: const Text('မလုပ်', style: TextStyle(fontFamily: 'Padauk'))),
        ElevatedButton(onPressed: () async {
          Navigator.pop(context);
          final r = await ApiService().saveFinanceGroup({
            'id': existing?['ID'] ?? '', 'name': ctrl.text.trim()});
          if (mounted && r['ok']==true) _loadGroups();
        }, child: const Text('သိမ်း', style: TextStyle(fontFamily: 'Padauk'))),
      ],
    ));
  }

  void _showIncomeDialog({Map? existing}) {
    final titleCtrl = TextEditingController(text: existing?['title'] as String? ?? '');
    final amtCtrl = TextEditingController(text: existing != null ? '${existing['amount']}' : '');
    final noteCtrl = TextEditingController(text: existing?['note'] as String? ?? '');
    String date = existing?['date'] as String? ?? ApiService().today;

    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16, right: 16, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(existing != null ? 'ဝင်ငွေ ပြင်ရန်' : 'ဝင်ငွေ ထည့်',
            style: const TextStyle(fontFamily: 'Padauk', fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          TextField(controller: titleCtrl,
            decoration: const InputDecoration(labelText: 'ဝင်ငွေ အကြောင်းအရာ',
              labelStyle: TextStyle(fontFamily: 'Padauk'))),
          const SizedBox(height: 10),
          TextField(controller: amtCtrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ပမာဏ (ကျပ်)',
              labelStyle: TextStyle(fontFamily: 'Padauk'))),
          const SizedBox(height: 10),
          TextField(controller: noteCtrl,
            decoration: const InputDecoration(labelText: 'မှတ်ချက်',
              labelStyle: TextStyle(fontFamily: 'Padauk'))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final r = await ApiService().saveFinanceIncome({
                'id': existing?['id'] ?? '',
                'groupId': _curGroup?['ID'] ?? '',
                'groupName': _curGroup?['GroupName'] ?? '',
                'title': titleCtrl.text.trim(),
                'amount': amtCtrl.text.trim(),
                'date': date, 'note': noteCtrl.text,
              });
              if (mounted && r['ok']==true) _loadData(_curGroup!['ID'] as String);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            child: const Text('💾 သိမ်းဆည်း', style: TextStyle(fontFamily: 'Padauk')),
          ),
        ]),
      ));
  }

  void _showExpenseDialog(String incomeId, {Map? existing}) {
    final descCtrl = TextEditingController(text: existing?['description'] as String? ?? '');
    final amtCtrl = TextEditingController(text: existing != null ? '${existing['amount']}' : '');
    final noteCtrl = TextEditingController(text: existing?['note'] as String? ?? '');
    String date = existing?['date'] as String? ?? ApiService().today;

    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16, right: 16, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(existing != null ? 'သုံးစွဲငွေ ပြင်ရန်' : 'သုံးစွဲငွေ ထည့်',
            style: const TextStyle(fontFamily: 'Padauk', fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          TextField(controller: descCtrl,
            decoration: const InputDecoration(labelText: 'အကြောင်းအရာ',
              labelStyle: TextStyle(fontFamily: 'Padauk'))),
          const SizedBox(height: 10),
          TextField(controller: amtCtrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ပမာဏ (ကျပ်)',
              labelStyle: TextStyle(fontFamily: 'Padauk'))),
          const SizedBox(height: 10),
          TextField(controller: noteCtrl,
            decoration: const InputDecoration(labelText: 'မှတ်ချက်',
              labelStyle: TextStyle(fontFamily: 'Padauk'))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final r = await ApiService().saveFinanceExpense({
                'id': existing?['id'] ?? '',
                'incomeId': incomeId,
                'groupName': _curGroup?['GroupName'] ?? '',
                'description': descCtrl.text.trim(),
                'amount': amtCtrl.text.trim(),
                'date': date, 'note': noteCtrl.text,
              });
              if (mounted && r['ok']==true) _loadData(_curGroup!['ID'] as String);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            child: const Text('💾 သိမ်းဆည်း', style: TextStyle(fontFamily: 'Padauk')),
          ),
        ]),
      ));
  }

  Future<void> _deleteIncome(String id) async {
    final r = await ApiService().deleteFinanceIncome(id);
    if (mounted && r['ok']==true) _loadData(_curGroup!['ID'] as String);
  }

  Future<void> _deleteExpense(String id) async {
    final r = await ApiService().deleteFinanceExpense(id);
    if (mounted && r['ok']==true) _loadData(_curGroup!['ID'] as String);
  }
}

class _SumCard extends StatelessWidget {
  final String label, value; final Color color;
  const _SumCard(this.label, this.value, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Card(
    child: Padding(padding: const EdgeInsets.all(12), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontFamily: 'Padauk', fontSize: 10, color: AppTheme.textMuted)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontFamily: 'Padauk', fontSize: 16,
          fontWeight: FontWeight.w800, color: color)),
      ]))));
}

class _IncomeCard extends StatelessWidget {
  final Map inc;
  final String Function(dynamic) fmt;
  final String groupName;
  final Function(String) onAddExpense, onDeleteIncome;
  final Function(Map) onEditIncome;
  final Function(Map, String) onEditExpense;
  final Function(String) onDeleteExpense;

  const _IncomeCard({required this.inc, required this.fmt, required this.groupName,
    required this.onAddExpense, required this.onEditIncome, required this.onDeleteIncome,
    required this.onEditExpense, required this.onDeleteExpense});

  @override
  Widget build(BuildContext context) {
    final expenses = inc['expenses'] as List? ?? [];
    final expTotal = (inc['expTotal'] as num?)?.toDouble() ?? 0;
    final amount = (inc['amount'] as num?)?.toDouble() ?? 0;
    final remaining = (inc['remaining'] as num?)?.toDouble() ?? 0;
    final pct = amount > 0 ? (expTotal / amount).clamp(0.0, 1.0) : 0.0;
    final barColor = pct >= 0.9 ? AppTheme.danger : pct >= 0.7 ? AppTheme.warning : AppTheme.accent;

    return Card(margin: const EdgeInsets.only(bottom: 12), child: Column(children: [
      // Header
      Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(inc['title'] as String? ?? '',
                style: const TextStyle(color: Colors.white, fontFamily: 'Padauk',
                  fontSize: 16, fontWeight: FontWeight.w800)),
              Text('ဝင်ငွေ: ${fmt(amount)} ကျပ်${(inc['date'] as String? ?? '').isNotEmpty ? ' · ${inc['date']}' : ''}',
                style: const TextStyle(color: Colors.white70, fontFamily: 'Padauk', fontSize: 12)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('ကျန်ငွေ', style: TextStyle(color: Colors.white70, fontFamily: 'Padauk', fontSize: 11)),
              Text(fmt(remaining),
                style: TextStyle(fontFamily: 'Padauk', fontSize: 18, fontWeight: FontWeight.w800,
                  color: remaining >= 0 ? const Color(0xFF86efac) : const Color(0xFFfca5a5))),
            ]),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _HBtn('+ သုံးစွဲ', 0.18, () => onAddExpense(inc['id'] as String)),
            const SizedBox(width: 6),
            _HBtn('✏️', 0.1, () => onEditIncome(inc)),
            const SizedBox(width: 6),
            _HBtn('🗑', 0.15, () => onDeleteIncome(inc['id'] as String), isRed: true),
          ]),
        ]),
      ),
      // Progress bar
      LinearProgressIndicator(value: pct, minHeight: 4,
        backgroundColor: const Color(0xFFe2e8f0),
        valueColor: AlwaysStoppedAnimation(barColor)),
      // Expenses
      if (expenses.isEmpty)
        const Padding(padding: EdgeInsets.all(12),
          child: Text('သုံးစွဲမှု မရှိသေး',
            style: TextStyle(fontFamily: 'Padauk', fontSize: 12, color: AppTheme.textMuted)))
      else
        Column(children: [
          ...expenses.map((exp) {
            final e = exp as Map;
            return ListTile(dense: true,
              title: Text(e['description'] as String? ?? '',
                style: const TextStyle(fontFamily: 'Padauk', fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text('${e['date'] ?? ''}${(e['note'] as String? ?? '').isNotEmpty ? ' · ${e['note']}' : ''}',
                style: const TextStyle(fontFamily: 'Padauk', fontSize: 11)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(fmt(e['amount']),
                  style: const TextStyle(fontFamily: 'Padauk', color: AppTheme.danger,
                    fontWeight: FontWeight.w700)),
                IconButton(icon: const Icon(Icons.edit, size: 16, color: AppTheme.textMuted),
                  onPressed: () => onEditExpense(e, inc['id'] as String)),
                IconButton(icon: const Icon(Icons.delete, size: 16, color: AppTheme.danger),
                  onPressed: () => onDeleteExpense(e['id'] as String)),
              ]),
            );
          }),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('စုစုပေါင်း', style: TextStyle(fontFamily: 'Padauk',
                fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
              Text(fmt(expTotal), style: const TextStyle(fontFamily: 'Padauk',
                fontWeight: FontWeight.w800, color: AppTheme.danger, fontSize: 15)),
            ])),
        ]),
    ]));
  }
}

class _HBtn extends StatelessWidget {
  final String label; final double opacity; final VoidCallback onTap; final bool isRed;
  const _HBtn(this.label, this.opacity, this.onTap, {this.isRed=false});
  @override Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isRed ? Colors.red.withOpacity(0.35) : Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'Padauk', fontSize: 12))));
}
