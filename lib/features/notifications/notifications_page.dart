import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../common/controllers/items_controller.dart';
import '../item_details/item_details_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.itemsController});
  static const route = '/notifications';

  final ItemsController itemsController;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _cleared = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('notifications')),
        actions: [
          TextButton(
            onPressed: () => setState(() => _cleared = true),
            child: Text(t.translate('mark_all_read')),
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.itemsController,
        builder: (context, _) {
          final visits = widget.itemsController.visits;
          final savedSearches = widget.itemsController.savedSearches;
          final hasContent = !_cleared && (visits.isNotEmpty || savedSearches.isNotEmpty);
          if (!hasContent) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(IconlyLight.tick_square, size: 56, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(t.translate('all_caught_up'), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(t.translate('all_caught_up_desc'), textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (visits.isNotEmpty && !_cleared) ...[
                Row(
                  children: [
                    Icon(IconlyBold.calendar, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(t.translate('visit_reminder'), style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 8),
                ...visits.map((visit) {
                  final item = widget.itemsController.findItem(visit.itemId);
                  if (item == null) return const SizedBox.shrink();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(IconlyLight.calendar),
                      title: Text(item.name),
                      subtitle: Text(visit.formatted(context)),
                      trailing: IconButton(
                        tooltip: t.translate('cancel_visit'),
                        icon: const Icon(Icons.close),
                        onPressed: () => widget.itemsController.cancelVisit(visit.id),
                      ),
                      onTap: () => Navigator.of(context).pushNamed(
                        ItemDetailsPage.route,
                        arguments: item,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
              ],
              if (savedSearches.isNotEmpty && !_cleared) ...[
                Row(
                  children: [
                    Icon(IconlyBold.search, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(t.translate('saved_searches'), style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 8),
                ...savedSearches.map(
                  (saved) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(saved.query),
                            subtitle: Text(
                              [
                                if ((saved.city ?? '').isNotEmpty) saved.city!,
                                if ((saved.category ?? '').isNotEmpty) saved.category!,
                                if (saved.minPrice != null && saved.maxPrice != null)
                                  '${saved.minPrice?.toStringAsFixed(0)} - ${saved.maxPrice?.toStringAsFixed(0)}',
                              ].where((value) => value.isNotEmpty).join(' • '),
                            ),
                            trailing: Switch(
                              value: saved.alertsEnabled,
                              onChanged: (_) => widget.itemsController.toggleSavedSearchAlerts(saved.id),
                              activeColor: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  widget.itemsController.applySavedSearch(saved);
                                  Navigator.of(context).maybePop();
                                },
                                icon: const Icon(IconlyLight.arrow_right_2),
                                label: Text(t.translate('apply_filters')),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: () => widget.itemsController.removeSavedSearch(saved.id),
                                child: Text(t.translate('remove_saved_search')),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ]
            ],
          );
        },
      ),
    );
  }
}
