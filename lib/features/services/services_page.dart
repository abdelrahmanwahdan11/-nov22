import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../settings/settings_page.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  static const route = '/services';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final partners = _mockPartners(t);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('service_directory')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.translate('services'), style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(t.translate('services_intro'), style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(t.translate('recommended_partners'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final partner in partners) ...[
            _PartnerCard(partner: partner),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: const Icon(Icons.support_outlined),
            title: Text(t.translate('support_requests')),
            subtitle: Text(t.translate('support_requests_hint')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed('/support-requests'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _mockPartners(AppLocalizations t) {
    return [
      {
        'name': t.translate('service_inspector'),
        'city': 'Dubai',
        'rating': 4.8,
        'tags': [t.translate('service_tag_inspection'), t.translate('service_tag_fast')],
        'contact': 'inspector@example.com'
      },
      {
        'name': t.translate('service_mover'),
        'city': 'Abu Dhabi',
        'rating': 4.6,
        'tags': [t.translate('service_tag_moving'), t.translate('service_tag_support')],
        'contact': 'movers@example.com'
      },
      {
        'name': t.translate('service_legal'),
        'city': 'Riyadh',
        'rating': 4.9,
        'tags': [t.translate('service_tag_legal'), t.translate('service_tag_review')],
        'contact': 'legalteam@example.com'
      },
    ];
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.partner});

  final Map<String, dynamic> partner;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(partner['name'] as String, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(partner['city'] as String, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Chip(
                label: Text('${partner['rating']} ★'),
                avatar: const Icon(Icons.star_rate_rounded, size: 18),
              )
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final tag in partner['tags'] as List<String>) Chip(label: Text(tag)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.message_outlined),
                  label: Text(t.translate('service_request')),
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(t.translate('service_request_sent'))));
                  },
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.save_alt_outlined),
                tooltip: t.translate('save'),
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(t.translate('service_saved'))));
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: t.translate('settings'),
                onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${t.translate('service_contact')}: ${partner['contact']}',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
