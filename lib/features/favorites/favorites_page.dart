import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/skeleton_card.dart';
import '../../core/utils/app_scope.dart';
import '../common/controllers/items_controller.dart';
import '../item_details/item_details_page.dart';
import '../home/home_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key, required this.itemsController});
  static const route = '/favorites';

  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('favorites'))),
      body: AnimatedBuilder(
        animation: itemsController,
        builder: (context, _) {
          final favorites = itemsController.favoriteItems;
          final compactCards = AppScope.of(context).compactCards;
          if (itemsController.isLoading) {
            return ListView(children: List.generate(3, (index) => const SkeletonCard()));
          }
          if (favorites.isEmpty) {
            return _EmptyFavorites(t: t);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = favorites[index];
              final isFavorite = itemsController.favorites.contains(item.id);
              return ItemCard(
                item: item,
                onTap: () => Navigator.of(context).pushNamed(ItemDetailsPage.route, arguments: item),
                onToggleFavorite: () => itemsController.toggleFavorite(item.id),
                onToggleCompare: () => itemsController.toggleCompare(item.id),
                isFavorite: isFavorite,
                isInCompare: itemsController.compare.contains(item.id),
                note: itemsController.itemNotes[item.id],
                showNoteBadge: true,
                compact: compactCards,
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.t});

  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t.translate('favorites_empty_title'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              t.translate('favorites_empty_body'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed(HomePage.route),
              child: Text(t.translate('browse_catalog')),
            )
          ],
        ),
      ),
    );
  }
}
