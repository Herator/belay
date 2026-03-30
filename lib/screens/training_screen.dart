import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';
import '../models/generated_plan.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int _selectedWeek = 0;

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<AppProvider>().plan!;
    final weeks = plan.trainingPlan;

    return Scaffold(
      appBar: AppBar(title: const Text('Training')),
      body: Column(
        children: [
          // Week selector
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: weeks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = _selectedWeek == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedWeek = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected ? BelayColors.accent : BelayColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? BelayColors.accent : BelayColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Week ${weeks[i].week}',
                      style: TextStyle(
                        color: selected ? Colors.white : BelayColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Week theme
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.flag_outlined, size: 14, color: BelayColors.accent),
                const SizedBox(width: 6),
                Text(weeks[_selectedWeek].theme,
                    style: const TextStyle(color: BelayColors.accent, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Divider(height: 1, color: BelayColors.border),
          // Days list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: weeks[_selectedWeek].days.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _DayCard(day: weeks[_selectedWeek].days[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatefulWidget {
  final TrainingDay day;
  const _DayCard({required this.day});

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  bool _expanded = false;

  Color get _color {
    switch (widget.day.type) {
      case 'fixed': return BelayColors.teal;
      case 'gym': return BelayColors.accent;
      default: return BelayColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (widget.day.type) {
      case 'fixed': return Icons.sports;
      case 'gym': return Icons.fitness_center;
      default: return Icons.hotel;
    }
  }

  String get _title {
    if (widget.day.type == 'fixed') return widget.day.activity ?? 'Activity';
    if (widget.day.type == 'gym') return widget.day.focus ?? 'Gym';
    return 'Rest';
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.day;
    final hasExercises = d.exercises?.isNotEmpty == true;

    return Container(
      decoration: BoxDecoration(
        color: BelayColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: hasExercises ? () => setState(() => _expanded = !_expanded) : null,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_icon, color: _color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(d.day,
                                style: const TextStyle(
                                    color: BelayColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                            if (d.time != null) ...[
                              const Text('  ·  ', style: TextStyle(color: BelayColors.textSecondary)),
                              Text(d.time!, style: const TextStyle(color: BelayColors.textSecondary, fontSize: 11)),
                            ],
                          ],
                        ),
                        Text(_title,
                            style: const TextStyle(
                                color: BelayColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                      ],
                    ),
                  ),
                  if (hasExercises) ...[
                    Text('${d.exercises!.length} ex', style: const TextStyle(color: BelayColors.textSecondary, fontSize: 12)),
                    const SizedBox(width: 4),
                    Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: BelayColors.textSecondary, size: 18),
                  ],
                ],
              ),
            ),
          ),
          if (d.notes != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                children: [
                  const SizedBox(width: 48),
                  Expanded(
                    child: Text(d.notes!,
                        style: const TextStyle(color: BelayColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
          if (_expanded && hasExercises) ...[
            const Divider(height: 1, color: BelayColors.border),
            ...d.exercises!.map((ex) => _ExerciseRow(exercise: ex)),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseRow({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(62, 10, 14, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name,
                    style: const TextStyle(color: BelayColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                if (exercise.notes != null)
                  Text(exercise.notes!, style: const TextStyle(color: BelayColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${exercise.sets} × ${exercise.reps}',
                  style: const TextStyle(color: BelayColors.accent, fontWeight: FontWeight.w600, fontSize: 13)),
              Text(exercise.rest, style: const TextStyle(color: BelayColors.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
