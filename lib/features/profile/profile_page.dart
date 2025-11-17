import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../ai_info_placeholder/ai_info_placeholder_page.dart';
import '../settings/settings_page.dart';
import '../auth/login/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  static const route = '/profile';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('profile'))),
      body: Padding(
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
            ListTile(
              leading: const Icon(IconlyLight.setting),
              title: Text(t.translate('settings')),
              onTap: () => Navigator.of(context).pushNamed(SettingsPage.route),
            ),
            ListTile(
              leading: const Icon(IconlyLight.paper),
              title: const Text('AI info'),
              onTap: () => Navigator.of(context).pushNamed(AiInfoPlaceholderPage.route),
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
      ),
    );
  }
}
