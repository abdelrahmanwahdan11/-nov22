import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/primary_button.dart';
import '../common/controllers/items_controller.dart';
import '../item_details/item_details_page.dart';
import '../settings/settings_page.dart';
import '../insights/insights_page.dart';

class JourneyPage extends StatelessWidget {
  const JourneyPage({super.key, required this.itemsController});

  static const route = '/journey';

  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final steps = [
      (
        id: 'research',
        title: t.translate('step_research'),
        description: t.translate('step_research_desc'),
        icon: Icons.explore_outlined,
      ),
      (
        id: 'shortlist',
        title: t.translate('step_shortlist'),
        description: t.translate('step_shortlist_desc'),
        icon: Icons.star_border,
      ),
      (
        id: 'schedule',
        title: t.translate('step_schedule'),
        description: t.translate('step_schedule_desc'),
        icon: Icons.event_available_outlined,
      ),
      (
        id: 'notes',
        title: t.translate('step_notes'),
        description: t.translate('step_notes_desc'),
        icon: Icons.note_alt_outlined,
      ),
      (
        id: 'finalize',
        title: t.translate('step_finalize'),
        description: t.translate('step_finalize_desc'),
        icon: Icons.verified_outlined,
      ),
    ];
    final completed = app.journeyStepsCompleted;
    final progress = steps.isEmpty ? 0.0 : completed.length / steps.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('journey_planner')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: app,
        builder: (context, _) {
          final recent = itemsController.recentlyViewedItems.take(3).toList();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                            Icon(Icons.track_changes, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(t.translate('journey_progress'),
                                style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            Text('${(progress * 100).round()}%'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: progress.clamp(0, 1)),
                        const SizedBox(height: 12),
                        Text(t.translate('journey_progress_hint'),
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            Chip(
                              label: Text(t.translate('journey_steps_completed') + ' ${completed.length}/${steps.length}'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.refresh, size: 18),
                              label: Text(t.translate('reset_plan')),
                              onPressed: app.resetJourneySteps,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(t.translate('journey_actions'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...steps.map((step) {
                  final isDone = completed.contains(step.id);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: CheckboxListTile(
                      value: isDone,
                      onChanged: (_) => app.toggleJourneyStep(step.id),
                      title: Row(
                        children: [
                          Icon(step.icon, color: isDone ? Theme.of(context).colorScheme.primary : null),
                          const SizedBox(width: 10),
                          Expanded(child: Text(step.title)),
                        ],
                      ),
                      subtitle: Text(step.description),
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: isDone ? const Icon(Icons.check_circle, color: Colors.green) : null,
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(t.translate('budget_planner'),
                                style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(t.translate('budget_hint'),
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(t.translate('budget_target')),
                            const Spacer(),
                            Text('\$${app.budgetTarget.toStringAsFixed(0)}'),
                          ],
                        ),
                        Slider(
                          value: app.budgetTarget,
                          min: 1000,
                          max: 20000,
                          divisions: 19,
                          label: '\$${app.budgetTarget.round()}',
                          onChanged: (value) => app.setBudgetTarget(value),
                        ),
                        Text(t.translate('budget_cta'),
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (recent.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(t.translate('recent_progress'),
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Text(t.translate('recently_viewed')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...recent.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed(ItemDetailsPage.route, arguments: item),
                          child: ItemCard(item: item, itemsController: itemsController, compact: true),
                        ),
                      )),
                ],
                const SizedBox(height: 12),
                PrimaryButton(
                  text: t.translate('open_insights'),
                  onPressed: () => Navigator.of(context).pushNamed(InsightsPage.route),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
