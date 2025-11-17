import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/filter_chip.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/skeleton_card.dart';
import '../common/controllers/items_controller.dart';
import '../favorites/favorites_page.dart';
import '../item_details/item_details_page.dart';
import '../notifications/notifications_page.dart';
import '../search/search_page.dart';

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
        ],
      ),
      body: AnimatedBuilder(
        animation: itemsController,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: itemsController.refresh,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 12),
                _HeroCard(itemsController: itemsController),
                _MapPreview(itemsController: itemsController),
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
