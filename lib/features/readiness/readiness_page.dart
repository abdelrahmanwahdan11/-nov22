import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/skeleton_card.dart';
import '../calculator/affordability_calculator_page.dart';
import '../common/controllers/items_controller.dart';
import '../item_details/item_details_page.dart';
import '../journey/journey_page.dart';
import '../settings/settings_page.dart';

class ReadinessPage extends StatelessWidget {
  const ReadinessPage({super.key, required this.itemsController});

  static const route = '/readiness';

  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final tasks = [
      (
        id: 'finance',
        title: t.translate('task_finance'),
        subtitle: t.translate('task_finance_desc'),
        icon: Icons.account_balance_wallet_outlined,
      ),
      (
        id: 'documents',
        title: t.translate('task_documents'),
        subtitle: t.translate('task_documents_desc'),
        icon: Icons.description_outlined,
      ),
      (
        id: 'visits',
        title: t.translate('task_visit_plan'),
        subtitle: t.translate('task_visit_plan_desc'),
        icon: Icons.event_available_outlined,
      ),
      (
        id: 'review',
        title: t.translate('task_review'),
        subtitle: t.translate('task_review_desc'),
        icon: Icons.verified_outlined,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('readiness_checklist')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: app,
        builder: (context, _) {
          final completed = app.readinessCompleted;
          final progress = tasks.isEmpty ? 0.0 : completed.length / tasks.length;
          final recent = itemsController.recentlyViewedItems.take(2).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.playlist_add_check_rounded,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(t.translate('checklist_progress'),
                              style: Theme.of(context).textTheme.titleMedium),
                          const Spacer(),
                          Text('${(progress * 100).round()}%'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: progress.clamp(0, 1)),
                      const SizedBox(height: 10),
                      Text(t.translate('readiness_intro'),
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.refresh, size: 18),
                            label: Text(t.translate('reset_checklist')),
                            onPressed: app.resetReadiness,
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.track_changes, size: 18),
                            label: Text(t.translate('journey_planner')),
                            onPressed: () => Navigator.of(context).pushNamed(JourneyPage.route),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.calculate_outlined, size: 18),
                            label: Text(t.translate('calculator_shortcut')),
                            onPressed: () => Navigator.of(context).pushNamed(AffordabilityCalculatorPage.route),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...tasks.map((task) {
                final isDone = completed.contains(task.id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(task.icon, color: Theme.of(context).colorScheme.primary),
                    title: Text(task.title),
                    subtitle: Text(task.subtitle),
                    trailing: Checkbox(
                      value: isDone,
                      onChanged: (_) => app.toggleReadiness(task.id),
                    ),
                    onTap: () => app.toggleReadiness(task.id),
                  ),
                );
              }),
              const SizedBox(height: 6),
              if (recent.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.translate('recently_viewed'),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...recent.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ItemCard(
                          item: item,
                          onTap: () => Navigator.of(context)
                              .pushNamed(ItemDetailsPage.route, arguments: item),
                          onToggleFavorite: () => itemsController.toggleFavorite(item.id),
                          onToggleCompare: () => itemsController.toggleCompare(item.id),
                          isFavorite: itemsController.favorites.contains(item.id),
                          isInCompare: itemsController.compare.contains(item.id),
                          note: itemsController.itemNotes[item.id],
                          compact: AppScope.of(context).compactCards,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.translate('recently_viewed_empty'),
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        const SkeletonCard(),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
