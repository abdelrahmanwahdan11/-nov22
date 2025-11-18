import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../common/controllers/items_controller.dart';
import '../compare/compare_page.dart';
import '../favorites/favorites_page.dart';
import '../settings/settings_page.dart';

class GuidesPage extends StatelessWidget {
  const GuidesPage({super.key, required this.itemsController});
  static const route = '/guides';

  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final guides = [
      _Guide(icon: Icons.explore_outlined, title: t.translate('guide_explore'), body: t.translate('help_tip')),
      _Guide(icon: IconlyLight.swap, title: t.translate('guide_compare'), body: t.translate('guides_tip')),
      _Guide(icon: Icons.calendar_month_outlined, title: t.translate('guide_visits'), body: t.translate('visit_saved')),
      _Guide(icon: Icons.sticky_note_2_outlined, title: t.translate('guide_notes'), body: t.translate('note_hint')),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('guides')),
        actions: [
          IconButton(
            tooltip: t.translate('settings_shortcut'),
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.translate('support_articles'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...guides.map(
            (guide) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(guide.icon, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(guide.title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text(guide.body),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(t.translate('more_to_explore'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          _ActionTile(
            icon: Icons.favorite_border,
            title: t.translate('favorites'),
            subtitle: t.translate('favorites_empty_body'),
            onTap: () => Navigator.of(context).pushNamed(FavoritesPage.route),
          ),
          _ActionTile(
            icon: Icons.compare_arrows_outlined,
            title: t.translate('compare'),
            subtitle: t.translate('faq_compare_ans'),
            onTap: () => Navigator.of(context).pushNamed(ComparePage.route),
          ),
          _ActionTile(
            icon: Icons.calendar_today,
            title: t.translate('upcoming_visits'),
            subtitle: t.translate('visit_reminder'),
            onTap: () {
              if (itemsController.visits.isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(t.translate('no_upcoming_visits'))));
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Guide {
  const _Guide({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
