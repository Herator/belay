import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';
import '../models/generated_plan.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final Set<String> _checked = {};

  @override
  Widget build(BuildContext context) {
    final grocery = context.watch<AppProvider>().plan!.groceryList;

    final sections = [
      ('Proteins', Icons.egg_alt_outlined, BelayColors.accent, grocery.proteins),
      ('Carbs', Icons.grain, BelayColors.gold, grocery.carbs),
      ('Vegetables', Icons.eco_outlined, BelayColors.success, grocery.vegetables),
      ('Dairy', Icons.water_drop_outlined, BelayColors.teal, grocery.dairy),
      ('Pantry', Icons.kitchen_outlined, BelayColors.purple, grocery.pantryItems),
      ('Other', Icons.shopping_basket_outlined, BelayColors.textSecondary, grocery.other),
    ];

    final total = sections.fold<int>(0, (sum, s) => sum + s.$4.length);
    final done = _checked.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _checked.clear()),
            child: const Text('Reset', style: TextStyle(color: BelayColors.accent)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$done / $total items', style: const TextStyle(color: BelayColors.textSecondary, fontSize: 13)),
                    if (done == total && total > 0)
                      const Text('All done!', style: TextStyle(color: BelayColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : done / total,
                    backgroundColor: BelayColors.border,
                    valueColor: const AlwaysStoppedAnimation(BelayColors.success),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: sections
                  .where((s) => s.$4.isNotEmpty)
                  .map((s) => _Section(
                        title: s.$1,
                        icon: s.$2,
                        color: s.$3,
                        items: s.$4,
                        checked: _checked,
                        onToggle: (item) => setState(() {
                          if (_checked.contains(item)) {
                            _checked.remove(item);
                          } else {
                            _checked.add(item);
                          }
                        }),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  final Set<String> checked;
  final void Function(String) onToggle;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: BelayColors.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final item = e.value;
              final isChecked = checked.contains(item);
              final isLast = e.key == items.length - 1;

              return Column(
                children: [
                  InkWell(
                    onTap: () => onToggle(item),
                    borderRadius: isLast
                        ? const BorderRadius.vertical(bottom: Radius.circular(14))
                        : BorderRadius.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isChecked ? color : Colors.transparent,
                              border: Border.all(color: isChecked ? color : BelayColors.border, width: 2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: isChecked
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                color: isChecked ? BelayColors.textSecondary : BelayColors.textPrimary,
                                decoration: isChecked ? TextDecoration.lineThrough : null,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast) const Divider(height: 1, indent: 50, color: BelayColors.border),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
