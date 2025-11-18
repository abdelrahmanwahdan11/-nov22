import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../../core/widgets/primary_button.dart';
import '../common/controllers/items_controller.dart';
import '../common/models/item.dart';
import '../journey/journey_page.dart';
import '../settings/settings_page.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key, required this.itemsController});

  static const route = '/insights';

  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final snapshot = itemsController.snapshot();
    final allItems = itemsController.allItems;
    final topCity = _topCity(allItems);
    final avgRating = allItems.isEmpty
        ? 0
        : allItems.map((item) => item.rating).reduce((a, b) => a + b) / allItems.length;
    final visits = itemsController.visits;
    final recents = itemsController.recentlyViewedItems;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('insights')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.translate('insights_subtitle'), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(
                  label: t.translate('favorites'),
                  value: snapshot['favorites'].toString(),
                  icon: IconlyBold.heart,
                  color: Colors.pink,
                ),
                _StatCard(
                  label: t.translate('compare'),
                  value: snapshot['compare'].toString(),
                  icon: IconlyBold.swap,
                  color: Colors.blue,
                ),
                _StatCard(
                  label: t.translate('saved_searches'),
                  value: snapshot['savedSearches'].toString(),
                  icon: IconlyBold.discovery,
                  color: Colors.teal,
                ),
                _StatCard(
                  label: t.translate('notes_section'),
                  value: snapshot['notes'].toString(),
                  icon: IconlyBold.paper,
                  color: Colors.orange,
                ),
                _StatCard(
                  label: t.translate('upcoming_visits'),
                  value: snapshot['visits'].toString(),
                  icon: IconlyBold.calendar,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.place_outlined, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(t.translate('city_focus'),
                            style: Theme.of(context).textTheme.titleMedium),
                        const Spacer(),
                        Text(topCity?.$2.toString() ?? '0'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(topCity == null
                        ? t.translate('no_results_found')
                        : '${topCity.$1} • ${t.translate('listings_count').replaceAll('{count}', topCity.$2.toString())}'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.star_rate_rounded, color: Colors.amber.shade700),
                        const SizedBox(width: 6),
                        Text(t.translate('average_rating')),
                        const Spacer(),
                        Text(avgRating.toStringAsFixed(1)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics_outlined, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(t.translate('budget_vs_filters'),
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(t.translate('budget_alignment'),
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(t.translate('budget_target')),
                        const Spacer(),
                        Text('\$${app.budgetTarget.toStringAsFixed(0)}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(t.translate('price_window')),
                        const Spacer(),
                        Text('\$${itemsController.selectedPriceRange.start.toStringAsFixed(0)} - \$${itemsController.selectedPriceRange.end.toStringAsFixed(0)}'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (app.budgetTarget / itemsController.selectedPriceRange.end).clamp(0, 1),
                    ),
                    const SizedBox(height: 8),
                    Text(t.translate('budget_hint')), 
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(t.translate('recent_activity'),
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (recents.isEmpty) Text(t.translate('insights_empty_recent')),
              ],
            ),
            const SizedBox(height: 8),
            ...recents.take(4).map((item) => ListTile(
                  leading: const Icon(IconlyLight.time_circle),
                  title: Text(item.name),
                  subtitle: Text(item.location),
                )),
            const SizedBox(height: 12),
            Text(t.translate('upcoming_visits'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (visits.isEmpty)
              Text(t.translate('no_visits'), style: Theme.of(context).textTheme.bodyMedium)
            else
              ...visits.take(3).map((visit) => ListTile(
                    leading: const Icon(Icons.event_note_outlined),
                    title: Text(itemsController.findItem(visit.itemId)?.name ?? visit.itemId),
                    subtitle: Text('${visit.dateTime} • ${visit.notes ?? ''}'),
                  )),
            const SizedBox(height: 20),
            PrimaryButton(
              text: t.translate('launch_journey'),
              onPressed: () => Navigator.of(context).pushNamed(JourneyPage.route),
            ),
          ],
        ),
      ),
    );
  }

  (String, int)? _topCity(List<Item> items) {
    if (items.isEmpty) return null;
    final counts = <String, int>{};
    for (final item in items) {
      final city = item.city;
      counts[city] = (counts[city] ?? 0) + 1;
    }
    counts.removeWhere((key, value) => value == 0);
    if (counts.isEmpty) return null;
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    return (top.key, top.value);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const Spacer(),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
