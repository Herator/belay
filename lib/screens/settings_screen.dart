import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profile = provider.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (profile != null) ...[
            _SectionHeader('Profile'),
            _InfoCard(items: [
              ('Name', profile.name),
              ('Gym sessions/week', '${profile.gymSessionsPerWeek}'),
              ('Shopping day', profile.shoppingDay),
              ('Max meal prep', '${profile.maxWeekdayMealTime} min'),
              ('Breakfast', profile.sameBreakfastEveryDay ? 'Same daily' : 'Varied'),
            ]),
            const SizedBox(height: 8),
            if (profile.fixedActivities.isNotEmpty) ...[
              _InfoCard(items: profile.fixedActivities
                  .map((a) => (a.name, '${a.day} at ${a.time}'))
                  .toList()),
            ],
            const SizedBox(height: 24),
            _SectionHeader('Food Preferences'),
            if (profile.foodLikes.isNotEmpty)
              _ChipsCard(label: 'Likes', items: profile.foodLikes, color: BelayColors.success),
            if (profile.foodDislikes.isNotEmpty) ...[
              const SizedBox(height: 8),
              _ChipsCard(label: 'Dislikes', items: profile.foodDislikes, color: BelayColors.error),
            ],
            if (profile.foodNeutral.isNotEmpty) ...[
              const SizedBox(height: 8),
              _ChipsCard(label: 'Neutral', items: profile.foodNeutral, color: BelayColors.textSecondary),
            ],
          ],

          // Pantry
          if (provider.plan != null) ...[
            const SizedBox(height: 24),
            _SectionHeader('Pantry Status'),
            _PantryCard(
              label: 'Still in pantry',
              items: provider.plan!.pantryUpdate.leftover,
              color: BelayColors.success,
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 8),
            _PantryCard(
              label: 'Fully used',
              items: provider.plan!.pantryUpdate.depleted,
              color: BelayColors.textSecondary,
              icon: Icons.remove_circle_outline,
            ),
          ],

          const SizedBox(height: 32),
          _SectionHeader('Actions'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _confirmRegenerate(context, provider),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Regenerate Plan'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _confirmReset(context, provider),
            icon: const Icon(Icons.restart_alt, color: BelayColors.error),
            label: const Text('Reset & Start Over', style: TextStyle(color: BelayColors.error)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: BelayColors.error)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _confirmRegenerate(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: BelayColors.surface,
        title: const Text('Regenerate Plan?'),
        content: const Text('This will create a new meal and training plan using your current profile.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.regeneratePlan();
            },
            child: const Text('Regenerate', style: TextStyle(color: BelayColors.accent)),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: BelayColors.surface,
        title: const Text('Reset App?'),
        content: const Text('This will delete all your data and restart onboarding.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.resetApp();
            },
            child: const Text('Reset', style: TextStyle(color: BelayColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: const TextStyle(color: BelayColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<(String, String)> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: BelayColors.card, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(e.value.$1, style: const TextStyle(color: BelayColors.textSecondary, fontSize: 14)),
                    const Spacer(),
                    Text(e.value.$2, style: const TextStyle(color: BelayColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 16, color: BelayColors.border),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ChipsCard extends StatelessWidget {
  final String label;
  final List<String> items;
  final Color color;
  const _ChipsCard({required this.label, required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: BelayColors.card, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items
                .map((f) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(f, style: TextStyle(color: color, fontSize: 12)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PantryCard extends StatelessWidget {
  final String label;
  final List<String> items;
  final Color color;
  final IconData icon;
  const _PantryCard({required this.label, required this.items, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: BelayColors.card, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $i', style: TextStyle(color: color.withOpacity(0.8), fontSize: 13)),
              )),
        ],
      ),
    );
  }
}
