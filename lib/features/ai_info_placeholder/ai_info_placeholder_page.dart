import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

class AiInfoPlaceholderPage extends StatelessWidget {
  const AiInfoPlaceholderPage({super.key});
  static const route = '/ai-info-placeholder';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('ai_info'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.translate('ai_info_headline'), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(t.translate('ai_info_placeholder')),
          ],
        ),
      ),
    );
  }
}
