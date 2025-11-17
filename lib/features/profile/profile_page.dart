import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../ai_info_placeholder/ai_info_placeholder_page.dart';
import '../common/controllers/items_controller.dart';
import '../compare/compare_page.dart';
import '../favorites/favorites_page.dart';
import '../item_details/item_details_page.dart';
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
          final recentViewed = itemsController.recentlyViewedItems;
          final visits = itemsController.visits;
          final notes = itemsController.itemNotes.entries
              .map((entry) => MapEntry(itemsController.findItem(entry.key), entry.value))
              .where((entry) => entry.key != null)
              .toList();
          return ListView(
            padding: const EdgeInsets.all(16),
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
                  const SizedBox(width: 12),
                  _StatCard(
                    label: t.translate('saved_searches'),
                    value: itemsController.savedSearches.length.toString(),
                    icon: IconlyBold.search,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(t.translate('activity'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _ActivityPill(icon: IconlyBold.heart, label: t.translate('favorites'), value: itemsController.favorites.length),
                    _ActivityPill(icon: IconlyBold.swap, label: t.translate('compare'), value: itemsController.compare.length),
                    _ActivityPill(icon: IconlyBold.paper, label: t.translate('saved_searches'), value: itemsController.savedSearches.length),
                    _ActivityPill(icon: IconlyBold.calendar, label: t.translate('upcoming_visits'), value: visits.length),
                    _ActivityPill(icon: Icons.sticky_note_2_rounded, label: t.translate('notes'), value: notes.length),
                  ],
                ),
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
              const SizedBox(height: 8),
              Text(t.translate('upcoming_visits'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (visits.isEmpty)
                Text(t.translate('no_upcoming_visits'))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final visit = visits[index];
                    final item = itemsController.findItem(visit.itemId);
                    if (item == null) return const SizedBox.shrink();
                    return Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 4),
                                    Text(visit.formatted(context),
                                        style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => itemsController.cancelVisit(visit.id),
                                icon: const Icon(Icons.close),
                                tooltip: t.translate('cancel_visit'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(item.location, style: Theme.of(context).textTheme.bodySmall),
                          if (visit.note != null && visit.note!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(visit.note!, style: Theme.of(context).textTheme.bodyMedium),
                          ]
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: visits.length,
                ),
              const SizedBox(height: 8),
              Text(t.translate('recently_viewed'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (recentViewed.isEmpty)
                Text(t.translate('recently_viewed_empty'))
              else
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final item = recentViewed[index];
                      return Container(
                        width: 200,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(item.image, height: 90, width: double.infinity, fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 8),
                            Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(item.location, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(ItemDetailsPage.route, arguments: item),
                              child: Text(t.translate('view_all')),
                            )
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: recentViewed.length,
                  ),
                ),
              const SizedBox(height: 16),
              Text(t.translate('my_notes'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (notes.isEmpty)
                Text(t.translate('note_hint'))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = notes[index].key!;
                    final note = notes[index].value;
                    return ListTile(
                      leading: const Icon(Icons.sticky_note_2_outlined),
                      title: Text(item.name),
                      subtitle: Text(note, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_note),
                        onPressed: () => Navigator.of(context)
                            .pushNamed(ItemDetailsPage.route, arguments: item),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: notes.length,
                ),
              const SizedBox(height: 24),
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

class _ActivityPill extends StatelessWidget {
  const _ActivityPill({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text('$value'),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
