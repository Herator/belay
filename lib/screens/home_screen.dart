import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../providers/app_provider.dart';
import '../models/generated_plan.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  DayMealPlan? _todayMeals(List<DayMealPlan> plan) {
    final today = DateFormat('EEEE').format(DateTime.now()); // e.g. "Monday"
    try {
      return plan.firstWhere((d) => d.day == today);
    } catch (_) {
      return plan.isNotEmpty ? plan.first : null;
    }
  }

  TrainingDay? _todayTraining(GeneratedPlan plan) {
    final today = DateFormat('EEEE').format(DateTime.now());
    final daysSince = DateTime.now().difference(plan.generatedAt).inDays;
    final weekIndex = (daysSince ~/ 7).clamp(0, plan.trainingPlan.length - 1);
    final week = plan.trainingPlan[weekIndex];
    try {
      return week.days.firstWhere((d) => d.day == today);
    } catch (_) {
      return null;
    }
  }

  int _currentWeek(GeneratedPlan plan) {
    final days = DateTime.now().difference(plan.generatedAt).inDays;
    return (days ~/ 7 + 1).clamp(1, 4);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final plan = provider.plan!;
    final profile = provider.profile!;
    final todayMeals = _todayMeals(plan.mealPlan);
    final todayTraining = _todayTraining(plan);
    final week = _currentWeek(plan);
    final today = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_greeting()},', style: Theme.of(context).textTheme.bodyMedium),
                      Text(profile.name, style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: BelayColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Week $week', style: const TextStyle(color: BelayColors.accent, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(today, style: Theme.of(context).textTheme.bodyMedium),

            // Weekly note
            if (plan.weeklyNote.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [BelayColors.accent.withOpacity(0.15), BelayColors.purple.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: BelayColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: BelayColors.accent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(plan.weeklyNote,
                          style: const TextStyle(color: BelayColors.textPrimary, fontSize: 13, height: 1.5)),
                    ),
                  ],
                ),
              ),
            ],

            // Today's Workout
            const SizedBox(height: 24),
            Text("Today's Workout", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _TrainingCard(day: todayTraining),

            // Today's Meals
            const SizedBox(height: 24),
            Text("Today's Meals", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (todayMeals != null) ...[
              _MealCard(label: 'Breakfast', icon: Icons.wb_sunny_outlined, color: BelayColors.gold, meal: todayMeals.breakfast),
              const SizedBox(height: 10),
              _MealCard(label: 'Lunch', icon: Icons.lunch_dining, color: BelayColors.teal, meal: todayMeals.lunch),
              const SizedBox(height: 10),
              _MealCard(label: 'Dinner', icon: Icons.dinner_dining, color: BelayColors.purple, meal: todayMeals.dinner),
            ] else
              const Text('No meal data for today.', style: TextStyle(color: BelayColors.textSecondary)),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  final TrainingDay? day;
  const _TrainingCard({this.day});

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return _card(context, icon: Icons.hotel, color: BelayColors.textSecondary,
          title: 'Rest Day', subtitle: 'Take it easy. Recovery is progress.');
    }
    if (day!.type == 'rest') {
      return _card(context, icon: Icons.hotel, color: BelayColors.textSecondary,
          title: 'Rest Day', subtitle: day!.notes ?? 'Active recovery recommended.');
    }
    if (day!.type == 'fixed') {
      return _card(context, icon: Icons.sports, color: BelayColors.teal,
          title: day!.activity ?? 'Activity',
          subtitle: '${day!.time ?? ''} — ${day!.notes ?? ''}');
    }
    // gym
    final exCount = day!.exercises?.length ?? 0;
    return _card(context, icon: Icons.fitness_center, color: BelayColors.accent,
        title: day!.focus ?? 'Gym Session',
        subtitle: '$exCount exercises');
  }

  Widget _card(BuildContext context, {required IconData icon, required Color color, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BelayColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: BelayColors.textPrimary, fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: BelayColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Meal meal;

  const _MealCard({required this.label, required this.icon, required this.color, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BelayColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: BelayColors.textSecondary, fontSize: 12)),
                Text(meal.name, style: const TextStyle(color: BelayColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 15)),
                if (meal.usageAlert != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 12, color: BelayColors.gold),
                        const SizedBox(width: 4),
                        Expanded(child: Text(meal.usageAlert!, style: const TextStyle(color: BelayColors.gold, fontSize: 11))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (meal.calories != null)
            Text('${meal.calories} cal', style: const TextStyle(color: BelayColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
