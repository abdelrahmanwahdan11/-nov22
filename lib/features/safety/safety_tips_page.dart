import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../settings/settings_page.dart';

class SafetyTipsPage extends StatelessWidget {
  const SafetyTipsPage({super.key});

  static const route = '/safety-tips';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final tips = [
      t.translate('safety_point_1'),
      t.translate('safety_point_2'),
      t.translate('safety_point_3'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('safety_tips')),
        actions: [
          IconButton(
            tooltip: t.translate('settings'),
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.translate('safety_title'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(t.translate('support_hours')),
            const SizedBox(height: 14),
            ...tips.map(
              (tip) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
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
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(tip)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
