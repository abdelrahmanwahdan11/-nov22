import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../../core/utils/app_controller.dart';
import '../common/controllers/items_controller.dart';
import '../settings/settings_page.dart';

class ActivityTimelinePage extends StatelessWidget {
  const ActivityTimelinePage({super.key, required this.itemsController});
  static const route = '/activity-timeline';

  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('activity_timeline')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([itemsController, app]),
        builder: (context, _) {
          final entries = _buildEntries(context, itemsController, app);
          if (entries.isEmpty) {
            return Center(child: Text(t.translate('activity_empty')));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
                leading: CircleAvatar(
                  backgroundColor: entry.color.withOpacity(0.15),
                  foregroundColor: entry.color,
                  child: Icon(entry.icon),
                ),
                title: Text(entry.title),
                subtitle: Text('${entry.subtitle}\n${DateFormat.yMMMd().add_jm().format(entry.date)}'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }

  List<_ActivityEntry> _buildEntries(
    BuildContext context,
    ItemsController items,
    AppController app,
  ) {
    final t = AppLocalizations.of(context);
    final entries = <_ActivityEntry>[];

    for (final visit in items.visits) {
      final item = items.findItem(visit.itemId);
      entries.add(
        _ActivityEntry(
          title: t.translate('activity_visit'),
          subtitle: item != null
              ? '${item.name} — ${DateFormat.yMMMd().add_jm().format(visit.dateTime)}'
              : DateFormat.yMMMd().add_jm().format(visit.dateTime),
          date: visit.dateTime,
          icon: Icons.event_note,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    for (final saved in items.savedSearches) {
      entries.add(
        _ActivityEntry(
          title: t.translate('activity_saved_search'),
          subtitle: saved.query,
          date: saved.createdAt,
          icon: Icons.bookmark_added_outlined,
          color: Colors.indigo,
        ),
      );
    }

    for (final offer in items.offers) {
      final item = items.findItem(offer.itemId);
      entries.add(
        _ActivityEntry(
          title: t.translate('offers'),
          subtitle: '${item?.name ?? t.translate('catalog')} — ${t.translate('offer_status_${offer.status}')} ',
          date: offer.createdAt,
          icon: Icons.handshake_outlined,
          color: Colors.green,
        ),
      );
    }

    for (final doc in app.documents) {
      entries.add(
        _ActivityEntry(
          title: t.translate('activity_document'),
          subtitle: '${doc.title} (${doc.status})',
          date: doc.updatedAt,
          icon: Icons.description_outlined,
          color: Colors.orange,
        ),
      );
    }

    for (final message in app.supportMessages) {
      entries.add(
        _ActivityEntry(
          title: t.translate('activity_support'),
          subtitle: message.title,
          date: message.createdAt,
          icon: Icons.support_agent,
          color: Colors.teal,
        ),
      );
    }

    if (app.feedbackUpdatedAt != null) {
      entries.add(
        _ActivityEntry(
          title: t.translate('activity_feedback'),
          subtitle: t.translate('feedback'),
          date: app.feedbackUpdatedAt!,
          icon: Icons.reviews_outlined,
          color: Colors.pink,
        ),
      );
    }

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }
}

class _ActivityEntry {
  _ActivityEntry({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final DateTime date;
  final IconData icon;
  final Color color;
}
