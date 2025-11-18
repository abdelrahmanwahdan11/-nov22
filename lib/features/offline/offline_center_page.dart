import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../settings/settings_page.dart';

class OfflineCenterPage extends StatelessWidget {
  const OfflineCenterPage({super.key});
  static const route = '/offline-center';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('offline_center')),
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: Text(t.translate('offline_mode')),
                subtitle: Text(t.translate('offline_mode_hint')),
                value: app.offlineMode,
                onChanged: app.setOfflineMode,
              ),
              SwitchListTile(
                title: Text(t.translate('auto_sync')),
                subtitle: Text(t.translate('auto_sync_hint')),
                value: app.autoSync,
                onChanged: app.setAutoSync,
              ),
              const SizedBox(height: 12),
              Text(t.translate('offline_collections'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Builder(builder: (context) {
                final labels = {
                  'favorites': t.translate('favorites'),
                  'visits': t.translate('upcoming_visits'),
                  'documents': t.translate('documents'),
                  'savedSearches': t.translate('saved_searches'),
                  'offers': t.translate('offers'),
                };
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: labels.keys
                      .map(
                        (entry) => FilterChip(
                          label: Text(labels[entry] ?? entry),
                          selected: app.offlineCollections.contains(entry),
                          onSelected: (selected) {
                            final updated = List<String>.from(app.offlineCollections);
                            if (selected) {
                              if (!updated.contains(entry)) updated.add(entry);
                            } else {
                              updated.remove(entry);
                            }
                            app.updateOfflineCollections(updated);
                          },
                        ),
                      )
                      .toList(),
                );
              }),
              const SizedBox(height: 16),
              ListTile(
                title: Text(t.translate('last_sync')),
                subtitle: Text(app.lastSyncAt != null
                    ? app.lastSyncAt!.toLocal().toString().substring(0, 16)
                    : t.translate('never')),
                trailing: FilledButton.icon(
                  onPressed: app.markSyncedNow,
                  icon: const Icon(Icons.sync),
                  label: Text(t.translate('sync_now')),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(t.translate('clear_offline')),
                subtitle: Text(t.translate('clear_offline_hint')),
                trailing: IconButton(
                  onPressed: app.clearOfflineCache,
                  icon: const Icon(Icons.delete_forever_outlined),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(t.translate('offline_summary')),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
