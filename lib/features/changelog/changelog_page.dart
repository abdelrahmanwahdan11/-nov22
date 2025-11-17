import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../settings/settings_page.dart';

class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});

  static const route = '/changelog';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final releases = [
      _Release(
        version: '0.9.0',
        date: t.translate('today') ?? '',
        notes: [
          t.translate('release_highlights'),
          t.translate('saved_searches'),
          t.translate('schedule_visit'),
          t.translate('ai_info'),
        ],
      ),
      _Release(
        version: '0.8.0',
        date: t.translate('recently_viewed'),
        notes: [
          t.translate('recent_searches'),
          t.translate('layout_mode'),
          t.translate('text_size'),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('whats_new')),
        actions: [
          IconButton(
            tooltip: t.translate('settings'),
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: releases.length,
        itemBuilder: (context, index) {
          final release = releases[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('v${release.version}', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    Text(release.date, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 8),
                Text(t.translate('release_notes'), style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 6),
                ...release.notes.map(
                  (note) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 18, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(note)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Release {
  _Release({required this.version, required this.date, required this.notes});

  final String version;
  final String date;
  final List<String> notes;
}
