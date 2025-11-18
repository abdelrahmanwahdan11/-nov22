import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../settings/settings_page.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});
  static const route = '/legal';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('legal_and_privacy')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LegalCard(
            title: t.translate('privacy_policy'),
            body: t.translate('privacy_body'),
            points: [
              t.translate('privacy_local'),
              t.translate('privacy_saved'),
              t.translate('privacy_contact'),
            ],
          ),
          const SizedBox(height: 12),
          _LegalCard(
            title: t.translate('terms_of_use'),
            body: t.translate('terms_body'),
            points: [
              t.translate('terms_usage'),
              t.translate('terms_content'),
              t.translate('terms_changes'),
            ],
          ),
          const SizedBox(height: 12),
          _LegalCard(
            title: t.translate('safety_and_trust'),
            body: t.translate('safety_body'),
            points: [
              t.translate('safety_expectations'),
              t.translate('safety_reporting'),
              t.translate('safety_updates'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegalCard extends StatelessWidget {
  const _LegalCard({required this.title, required this.body, required this.points});

  final String title;
  final String body;
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(body),
            const SizedBox(height: 10),
            ...points
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }
}
