import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../settings/settings_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  static const route = '/about';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final roadmap = [
      t.translate('roadmap_ai'),
      t.translate('roadmap_personalization'),
      t.translate('roadmap_offline'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('about_app')),
        actions: [
          IconButton(
            tooltip: t.translate('settings'),
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              child: Icon(Icons.apartment, color: Theme.of(context).colorScheme.primary),
            ),
            title: Text(t.translate('app_title'), style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(t.translate('about_story')),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.translate('about_values'), style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text(t.translate('about_team')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Pill(label: t.translate('app_health')),
                      const SizedBox(width: 8),
                      _Pill(label: t.translate('support_status')),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(t.translate('roadmap'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...roadmap.map((item) => ListTile(
                leading: const Icon(Icons.star_rate_outlined),
                title: Text(item),
              )),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(t.translate('about_version')),
            subtitle: const Text('v1.0.0 (offline-first preview)'),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: Text(t.translate('send_feedback')),
            subtitle: Text(t.translate('feedback_stub')),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
