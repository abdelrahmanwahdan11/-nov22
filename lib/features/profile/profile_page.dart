import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../ai_info_placeholder/ai_info_placeholder_page.dart';
import '../common/controllers/items_controller.dart';
import '../compare/compare_page.dart';
import '../favorites/favorites_page.dart';
import '../settings/settings_page.dart';
import '../auth/login/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.itemsController});
  static const route = '/profile';

  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('profile'))),
      body: AnimatedBuilder(
        animation: itemsController,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(IconlyBold.profile)),
                  title: const Text('Guest User'),
                  subtitle: const Text('guest@example.com'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatCard(
                      label: t.translate('favorites'),
                      value: itemsController.favorites.length.toString(),
                      icon: IconlyBold.heart,
                      onTap: () => Navigator.of(context).pushNamed(FavoritesPage.route),
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: t.translate('compare'),
                      value: itemsController.compare.length.toString(),
                      icon: IconlyBold.swap,
                      onTap: () => Navigator.of(context).pushNamed(ComparePage.route),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(IconlyLight.setting),
                  title: Text(t.translate('settings')),
                  onTap: () => Navigator.of(context).pushNamed(SettingsPage.route),
                ),
                ListTile(
                  leading: const Icon(IconlyLight.paper),
                  title: Text(t.translate('ai_info')),
                  onTap: () => Navigator.of(context).pushNamed(AiInfoPlaceholderPage.route),
                ),
                ListTile(
                  leading: const Icon(IconlyLight.heart),
                  title: Text(t.translate('favorites')),
                  onTap: () => Navigator.of(context).pushNamed(FavoritesPage.route),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await AppScope.of(context).setLoggedIn(false);
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed(LoginPage.route);
                      }
                    },
                    child: Text(t.translate('logout')),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, this.onTap});

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
