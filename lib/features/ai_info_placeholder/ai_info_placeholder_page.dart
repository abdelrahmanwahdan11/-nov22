import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../settings/settings_page.dart';
import 'package:iconly/iconly.dart';

class AiInfoPlaceholderPage extends StatelessWidget {
  const AiInfoPlaceholderPage({super.key});
  static const route = '/ai-info-placeholder';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('ai_info')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.translate('ai_info_headline'), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(t.translate('ai_info_placeholder')),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.translate('ai_info_steps_title'), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...[
                      t.translate('ai_info_step_collect'),
                      t.translate('ai_info_step_summarize'),
                      t.translate('ai_info_step_translate'),
                    ].map((step) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(step)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t.translate('done')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
