import 'package:flutter/material.dart';
import '../models/app_models.dart';

class AdminScreen extends StatefulWidget {
  final AppStateController state;
  final VoidCallback onMutate;

  const AdminScreen({super.key, required this.state, required this.onMutate});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _titleCtrl = TextEditingController();
  final _rewardCtrl = TextEditingController(text: '5.50');

  @override
  Widget build(BuildContext context) {
    final totalCompleted = widget.state.tasks.fold<int>(0, (s, t) => s + t.completedCount);
    final pendingWd = widget.state.withdrawals.where((w) => w.status == 'pending').length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('لوحة الإدارة والتقارير الإحصائية')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _kpiCard('إجمالي المهام المنجزة', '$totalCompleted'),
                const SizedBox(width: 10),
                _kpiCard('طلبات سحب معلقة', '$pendingWd'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFEFECEF), borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('إضافة مهمة جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(controller: _titleCtrl, decoration: const InputDecoration(filled: true, fillColor: Colors.white, hintText: 'عنوان المهمة')),
                  const SizedBox(height: 8),
                  TextField(controller: _rewardCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(filled: true, fillColor: Colors.white, hintText: 'المكافأة ج.م.')),
                  const SizedBox(height: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5B0E5B)),
                    onPressed: () {
                      if (_titleCtrl.text.trim().isEmpty) return;
                      widget.state.tasks.insert(
                        0,
                        TaskItem(
                          id: 't-${DateTime.now().millisecondsSinceEpoch}',
                          title: _titleCtrl.text.trim(),
                          description: 'مهمة مضافة من لوحة الإدارة',
                          category: 'survey',
                          durationMinutes: 4,
                          rewardEgp: double.tryParse(_rewardCtrl.text) ?? 5.0,
                          rewardPoints: 40,
                          questions: const [SurveyQuestion(question: 'ما تقييمك؟', options: ['ممتاز', 'جيد'])],
                        ),
                      );
                      _titleCtrl.clear();
                      widget.onMutate();
                      setState(() {});
                    },
                    child: const Text('إضافة المهمة'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('طلبات السحب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ...widget.state.withdrawals.map((wd) => Card(
              child: ListTile(
                title: Text('${wd.userName} · ${wd.method}'),
                subtitle: Text('${wd.accountInfo} — ${wd.amountEgp.toStringAsFixed(2)} ج.م.'),
                trailing: wd.status == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () {
                              wd.status = 'approved';
                              widget.onMutate();
                              setState(() {});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              wd.status = 'rejected';
                              widget.onMutate();
                              setState(() {});
                            },
                          ),
                        ],
                      )
                    : Text(wd.status == 'approved' ? 'معتمد' : 'مرفوض'),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFFAF5D8), borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
