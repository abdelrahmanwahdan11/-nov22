import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_scope.dart';
import '../common/controllers/items_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.itemsController});
  static const route = '/settings';

  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final colors = [
      AppTheme.defaultPrimary,
      Colors.teal,
      Colors.deepPurple,
      Colors.orange,
      Colors.pink,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.translate('language_title'), style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: [
              ChoiceChip(
                label: const Text('العربية'),
                selected: app.locale.languageCode == 'ar',
                onSelected: (_) => app.setLocale(const Locale('ar')),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('English'),
                selected: app.locale.languageCode == 'en',
                onSelected: (_) => app.setLocale(const Locale('en')),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(t.translate('theme_mode'), style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(
            title: Text(t.translate('dark_mode')),
            value: app.themeMode == ThemeMode.dark,
            onChanged: (value) => app.setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
          ),
          const SizedBox(height: 16),
          Text(t.translate('primary_color_title'), style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 12,
            children: colors
                .map(
                  (color) => GestureDetector(
                    onTap: () => app.setPrimaryColor(color),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: app.primaryColor == color ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Text(t.translate('data_and_storage'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(t.translate('clear_cached_data_desc')),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              await itemsController.clearSavedState();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(t.translate('data_cleared'))));
              }
            },
            icon: const Icon(Icons.cleaning_services_outlined),
            label: Text(t.translate('clear_cached_data')),
          )
        ],
      ),
    );
  }
}
