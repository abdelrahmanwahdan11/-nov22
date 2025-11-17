import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/filter_chip.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/skeleton_card.dart';
import '../../core/utils/app_scope.dart';
import '../about/about_page.dart';
import '../common/controllers/items_controller.dart';
import '../common/models/visit_request.dart';
import '../favorites/favorites_page.dart';
import '../guides/guides_page.dart';
import '../help/help_center_page.dart';
import '../item_details/item_details_page.dart';
import '../notifications/notifications_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';
import '../feedback/feedback_page.dart';
import '../changelog/changelog_page.dart';
import '../safety/safety_tips_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.itemsController});
  static const route = '/home';

  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final categories = ['all', 'Apartment', 'Villa', 'Beach House'];
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('explore')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.search),
            onPressed: () => Navigator.of(context).pushNamed(SearchPage.route),
          ),
          IconButton(
            icon: const Icon(IconlyLight.heart),
            onPressed: () => Navigator.of(context).pushNamed(FavoritesPage.route),
          ),
          IconButton(
            icon: const Icon(IconlyLight.notification),
            onPressed: () => Navigator.of(context).pushNamed(NotificationsPage.route),
          ),
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: itemsController,
        builder: (context, _) {
          final recentlyViewed = itemsController.recentlyViewedItems;
          final nextVisit = itemsController.nextVisit;
          final compactCards = AppScope.of(context).compactCards;
          return RefreshIndicator(
            onRefresh: itemsController.refresh,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 12),
                if (nextVisit != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _NextVisitCard(visit: nextVisit, itemsController: itemsController),
                  ),
                _HeroCard(itemsController: itemsController),
                _MapPreview(itemsController: itemsController),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.translate('app_shortcuts'), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          ActionChip(
                            avatar: const Icon(IconlyLight.setting, size: 18),
                            label: Text(t.translate('settings_shortcut')),
                            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.help_center_outlined, size: 18),
                            label: Text(t.translate('help_center')),
                            onPressed: () => Navigator.of(context).pushNamed(HelpCenterPage.route),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.menu_book_outlined, size: 18),
                            label: Text(t.translate('guides')),
                            onPressed: () => Navigator.of(context).pushNamed(GuidesPage.route),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.info_outline, size: 18),
                            label: Text(t.translate('about_app')),
                            onPressed: () => Navigator.of(context).pushNamed(AboutPage.route),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.shield_outlined, size: 18),
                            label: Text(t.translate('safety_tips')),
                            onPressed: () => Navigator.of(context).pushNamed(SafetyTipsPage.route),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.auto_awesome_outlined, size: 18),
                            label: Text(t.translate('whats_new')),
                            onPressed: () => Navigator.of(context).pushNamed(ChangelogPage.route),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.rate_review_outlined, size: 18),
                            label: Text(t.translate('feedback')),
                            onPressed: () => Navigator.of(context).pushNamed(FeedbackPage.route),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Builder(builder: (context) {
                  final savedMatches = itemsController.savedSearches
                      .where((saved) => saved.alertsEnabled)
                      .map((saved) => MapEntry(saved, itemsController.matchesForSavedSearch(saved)))
                      .where((entry) => entry.value.isNotEmpty)
                      .toList();
                  if (savedMatches.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(t.translate('matches_for_you'),
                                style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            Text(t.translate('saved_searches'),
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 220,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: savedMatches.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final entry = savedMatches[index];
                              final match = entry.value.first;
                              return SizedBox(
                                width: 260,
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context)
                                      .pushNamed(ItemDetailsPage.route, arguments: match),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 6),
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(match.image,
                                              height: 110, width: double.infinity, fit: BoxFit.cover),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(entry.key.query,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.titleMedium),
                                        const SizedBox(height: 4),
                                        Text('${t.translate('saved_search_matches')}: ${entry.value.length}',
                                            style: Theme.of(context).textTheme.bodySmall),
                                        const Spacer(),
                                        Text(match.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text(match.location,
                                            style: Theme.of(context).textTheme.bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (recentlyViewed.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        Text(t.translate('recently_viewed'),
                            style: Theme.of(context).textTheme.titleMedium),
                        const Spacer(),
                        TextButton(
                          onPressed: itemsController.clearRecentlyViewed,
                          child: Text(t.translate('clear_history')),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 260,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        final item = recentlyViewed[index];
                        return SizedBox(
                          width: 280,
                          child: ItemCard(
                            item: item,
                            onTap: () {
                              Navigator.of(context).pushNamed(ItemDetailsPage.route, arguments: item);
                            },
                            onToggleFavorite: () => itemsController.toggleFavorite(item.id),
                            onToggleCompare: () => itemsController.toggleCompare(item.id),
                            isFavorite: itemsController.favorites.contains(item.id),
                            isInCompare: itemsController.compare.contains(item.id),
                            note: itemsController.itemNotes[item.id],
                            showNoteBadge: true,
                            compact: compactCards,
                            margin: EdgeInsets.zero,
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: recentlyViewed.length,
                    ),
                  ),
                ],
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final label = categories[index];
                      return AnimatedFilterChip(
                        label: label,
                        selected: itemsController.category == label,
                        onTap: () => itemsController.setCategory(label),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: categories.length,
                  ),
                ),
                const SizedBox(height: 8),
                if (itemsController.isLoading)
                  ...List.generate(3, (index) => const SkeletonCard())
                else
                  ...itemsController.items.map(
                    (item) => ItemCard(
                      item: item,
                      onTap: () {
                        Navigator.of(context).pushNamed(ItemDetailsPage.route, arguments: item);
                      },
                      onToggleFavorite: () => itemsController.toggleFavorite(item.id),
                      onToggleCompare: () => itemsController.toggleCompare(item.id),
                      isFavorite: itemsController.favorites.contains(item.id),
                      isInCompare: itemsController.compare.contains(item.id),
                      note: itemsController.itemNotes[item.id],
                      showNoteBadge: true,
                      compact: compactCards,
                    ),
                  ),
                if (itemsController.hasMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: itemsController.isLoadingMore
                          ? const CircularProgressIndicator()
                          : TextButton(
                              onPressed: itemsController.loadMore,
                              child: Text(t.translate('view_all')),
                            ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NextVisitCard extends StatelessWidget {
  const _NextVisitCard({required this.visit, required this.itemsController});

  final VisitRequest visit;
  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final item = itemsController.findItem(visit.itemId);
    if (item == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(item.image),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.translate('visit_reminder'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(visit.formatted(context), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            tooltip: t.translate('cancel_visit'),
            onPressed: () => itemsController.cancelVisit(visit.id),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.itemsController});

  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final item = itemsController.items.isNotEmpty ? itemsController.items.first : null;
    if (item == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(ItemDetailsPage.route, arguments: item),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).cardColor,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(item.preview3d, fit: BoxFit.cover),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(item.location, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                  ],
                ),
              )
            ],
          ),
        )
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 300))
            .slideY(begin: 0.05, end: 0, duration: const Duration(milliseconds: 300)),
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.itemsController});

  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final item = itemsController.items.isNotEmpty ? itemsController.items.first : null;
    if (item == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(item.mapPreview, fit: BoxFit.cover, width: double.infinity),
            ),
            Positioned(
              left: 80,
              top: 60,
              child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.secondary),
            ),
            Positioned(
              right: 80,
              bottom: 60,
              child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }
}
