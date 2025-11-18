import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../common/controllers/items_controller.dart';
import '../guides/guides_page.dart';
import '../notifications/notifications_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key, required this.itemsController});
  static const route = '/help-center';

  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final faqs = [
      _Faq(t.translate('faq_search'), t.translate('faq_search_ans')),
      _Faq(t.translate('faq_compare'), t.translate('faq_compare_ans')),
      _Faq(t.translate('faq_visits'), t.translate('faq_visits_ans')),
      _Faq(t.translate('faq_data'), t.translate('faq_data_ans')),
    ];
    final articles = [
      t.translate('guide_explore'),
      t.translate('guide_compare'),
      t.translate('guide_visits'),
      t.translate('guide_notes'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('help_center')),
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
          Text(t.translate('support_desc'), style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 10),
          Row(
            children: [
              _Stat(label: t.translate('favorites'), value: itemsController.favorites.length),
              const SizedBox(width: 8),
              _Stat(label: t.translate('saved_searches'), value: itemsController.savedSearches.length),
              const SizedBox(width: 8),
              _Stat(label: t.translate('upcoming_visits'), value: itemsController.visits.length),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ShortcutChip(
                icon: Icons.settings_outlined,
                label: t.translate('open_settings'),
                onTap: () => Navigator.of(context).pushNamed(SettingsPage.route),
              ),
              _ShortcutChip(
                icon: Icons.menu_book_outlined,
                label: t.translate('view_guides'),
                onTap: () => Navigator.of(context).pushNamed(GuidesPage.route),
              ),
              _ShortcutChip(
                icon: Icons.search,
                label: t.translate('search'),
                onTap: () => Navigator.of(context).pushNamed(SearchPage.route),
              ),
              _ShortcutChip(
                icon: IconlyLight.notification,
                label: t.translate('notifications'),
                onTap: () => Navigator.of(context).pushNamed(NotificationsPage.route),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(Icons.shield_moon_outlined, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.translate('app_health'), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(t.translate('support_status')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(t.translate('contact_support'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.email_outlined),
                    title: Text(t.translate('support_email')),
                    subtitle: Text(t.translate('support_hours')),
                    trailing: TextButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: t.translate('support_email')));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(t.translate('email_copied'))));
                        }
                      },
                      child: Text(t.translate('copy_email')),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.chat_outlined),
                    title: Text(t.translate('send_feedback')),
                    subtitle: Text(t.translate('feedback_stub')),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.of(context).pushNamed(GuidesPage.route),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(t.translate('faq'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...faqs.map((faq) => _FaqTile(faq: faq)),
          const SizedBox(height: 12),
          Text(t.translate('support_articles'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          ...articles.map(
            (article) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.menu_book_rounded),
              title: Text(article),
              trailing: TextButton(
                onPressed: () => Navigator.of(context).pushNamed(GuidesPage.route),
                child: Text(t.translate('read_more')),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(GuidesPage.route),
            icon: const Icon(Icons.tips_and_updates_outlined),
            label: Text(t.translate('guides')),
          )
        ],
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

class _Faq {
  const _Faq(this.question, this.answer);
  final String question;
  final String answer;
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});
  final _Faq faq;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline),
        title: Text(faq.question),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          Text(faq.answer),
        ],
      ),
    );
  }
}
