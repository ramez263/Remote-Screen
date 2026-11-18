import 'package:flutter/material.dart';
import '../models/app_models.dart';

class TasksScreen extends StatelessWidget {
  final AppStateController state;
  final VoidCallback onChanged;

  const TasksScreen({super.key, required this.state, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final activeTasks = state.tasks.where((t) => t.active).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFFFAF5D8), borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('سلسلة المواظبة: ${state.streakDays} / 7 أيام', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text('نقاط الخبرة: ${state.xp} XP · مضاعف الأرباح: ${((state.multiplier - 1) * 100).round()}%+'),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5B0E5B)),
                onPressed: () {
                  state.streakDays = (state.streakDays % 7) + 1;
                  state.points += state.streakDays * 20;
                  state.balanceEgp += 1.5;
                  onChanged();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم استلام مكافأة المواظبة اليومية!')),
                  );
                },
                child: const Text('استلم مكافأة اليوم'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...activeTasks.map((task) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFFEFECEF), borderRadius: BorderRadius.circular(24)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('${task.durationMinutes} دقيقة · +${task.rewardPoints} نقطة'),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${task.rewardEgp.toStringAsFixed(2)} ج.م.', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  const SizedBox(height: 6),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5B0E5B)),
                    onPressed: () {
                      state.completeTask(task);
                      onChanged();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ربحت +${task.rewardEgp.toStringAsFixed(2)} ج.م.')),
                      );
                    },
                    child: const Text('إتمام'),
                  ),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }
}
