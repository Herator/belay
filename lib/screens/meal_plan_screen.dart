import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';
import '../models/generated_plan.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<AppProvider>().plan!;

    return Scaffold(
      appBar: AppBar(title: const Text('Meal Plan')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: plan.mealPlan.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, i) => _DayCard(day: plan.mealPlan[i]),
      ),
    );
  }
}

class _DayCard extends StatefulWidget {
  final DayMealPlan day;
  const _DayCard({required this.day});

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.day;
    return Container(
      decoration: BoxDecoration(
        color: BelayColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(d.day, style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  _totalCalories(d),
                  const SizedBox(width: 8),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: BelayColors.textSecondary),
                ],
              ),
            ),
          ),
          // Summary row (always visible)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _MiniMeal(label: 'B', name: d.breakfast.name, color: BelayColors.gold),
                const SizedBox(width: 8),
                _MiniMeal(label: 'L', name: d.lunch.name, color: BelayColors.teal),
                const SizedBox(width: 8),
                _MiniMeal(label: 'D', name: d.dinner.name, color: BelayColors.purple),
              ],
            ),
          ),
          // Expanded detail
          if (_expanded) ...[
            const Divider(height: 1, color: BelayColors.border),
            _MealDetail(label: 'Breakfast', icon: Icons.wb_sunny_outlined, color: BelayColors.gold, meal: d.breakfast),
            const Divider(height: 1, indent: 16, endIndent: 16, color: BelayColors.border),
            _MealDetail(label: 'Lunch', icon: Icons.lunch_dining, color: BelayColors.teal, meal: d.lunch),
            const Divider(height: 1, indent: 16, endIndent: 16, color: BelayColors.border),
            _MealDetail(label: 'Dinner', icon: Icons.dinner_dining, color: BelayColors.purple, meal: d.dinner),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _totalCalories(DayMealPlan d) {
    final total = (d.breakfast.calories ?? 0) + (d.lunch.calories ?? 0) + (d.dinner.calories ?? 0);
    if (total == 0) return const SizedBox();
    return Text('$total cal', style: const TextStyle(color: BelayColors.textSecondary, fontSize: 13));
  }
}

class _MiniMeal extends StatelessWidget {
  final String label;
  final String name;
  final Color color;
  const _MiniMeal({required this.label, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
            Text(name, style: const TextStyle(color: BelayColors.textPrimary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _MealDetail extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Meal meal;
  const _MealDetail({required this.label, required this.icon, required this.color, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              Text('${meal.prepTime} min', style: const TextStyle(color: BelayColors.textSecondary, fontSize: 12)),
              if (meal.calories != null)
                Text('  •  ${meal.calories} cal', style: const TextStyle(color: BelayColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Text(meal.name, style: const TextStyle(color: BelayColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: meal.ingredients
                .map((i) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: BelayColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: BelayColors.border),
                      ),
                      child: Text(i, style: const TextStyle(color: BelayColors.textSecondary, fontSize: 12)),
                    ))
                .toList(),
          ),
          if (meal.usageAlert != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BelayColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: BelayColors.gold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.recycling, color: BelayColors.gold, size: 14),
                  const SizedBox(width: 6),
                  Expanded(child: Text(meal.usageAlert!, style: const TextStyle(color: BelayColors.gold, fontSize: 12))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
