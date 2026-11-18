import 'package:flutter/material.dart';
import '../models/app_models.dart';

class HomeScreen extends StatelessWidget {
  final AppStateController state;
  final VoidCallback onChanged;
  final ValueChanged<int> onNavigateTab;

  const HomeScreen({
    super.key,
    required this.state,
    required this.onChanged,
    required this.onNavigateTab,
  });

  void _runSurveyDialog(BuildContext context, TaskItem task) {
    int step = 0;
    String? picked;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final q = task.questions[step];
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(task.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(q.question, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ...q.options.map((opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: picked == opt ? const Color(0xFFFAF5D8) : Colors.white,
                      side: BorderSide(color: picked == opt ? const Color(0xFF5B0E5B) : Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => setModalState(() => picked = opt),
                    child: Text(opt, style: const TextStyle(color: Color(0xFF141115))),
                  ),
                )),
              ],
            ),
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5B0E5B)),
                onPressed: picked == null
                    ? null
                    : () {
                        if (step < task.questions.length - 1) {
                          setModalState(() {
                            step += 1;
                            picked = null;
                          });
                        } else {
                          state.completeTask(task);
                          onChanged();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تم إضافة +${task.rewardEgp.toStringAsFixed(2)} ج.م. إلى رصيدك!')),
                          );
                        }
                      },
                child: Text(step < task.questions.length - 1 ? 'التالي' : 'إنهاء واستلام المكافأة'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTasks = state.tasks.where((t) => t.active).toList();
    final featured = activeTasks.isNotEmpty ? activeTasks.first : null;
    final quickTasks = activeTasks.skip(1).take(2).toList();
    final progress = (state.balanceEgp / state.targetGoalEgp).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // بطاقة الرصيد
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF5D8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_fire_department, color: Color(0xFFE85D04)),
                  SizedBox(width: 6),
                  Text('الرصيد', style: TextStyle(fontSize: 18, color: Color(0xFF736D63), fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${state.balanceEgp.toStringAsFixed(2)} ج.م.',
                style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Color(0xFF141115)),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  color: const Color(0xFF5B0E5B),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${state.points} نقطة', style: const TextStyle(fontSize: 12, color: Color(0xFF575148))),
                  Text('${state.targetGoalEgp.toStringAsFixed(2)} ج.م.', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // الاستبيان المميز
        if (featured != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFEFECEF), borderRadius: BorderRadius.circular(24)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 18),
                        const SizedBox(width: 4),
                        Text('${featured.durationMinutes} دقيقة', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (featured.isTopRated)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFF8CE10), borderRadius: BorderRadius.circular(99)),
                        child: const Text('الأعلى تقييمًا ☆', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('${featured.rewardEgp.toStringAsFixed(2)} ج.م.', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5B0E5B)),
                    onPressed: () => _runSurveyDialog(context, featured),
                    child: const Text('ابدأ الاستبيان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // مهام سريعة
        if (quickTasks.isNotEmpty)
          Row(
            children: quickTasks.map((t) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFEFECEF), borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    Text('${t.durationMinutes} دقيقة', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text('${t.rewardEgp.toStringAsFixed(2)} ج.م.', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5B0E5B)),
                        onPressed: () => _runSurveyDialog(context, t),
                        child: const Text('ابدأ الاستبيان', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),

        const SizedBox(height: 20),
        const Text('العب الألعاب واكسب المال', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFFECECEF), borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('اكسب حتى', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('1,020.67 ج.م.', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5B0E5B)),
                  onPressed: () => onNavigateTab(2),
                  child: const Text('اكتشف الألعاب', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
