import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/filter_chip.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/skeleton_card.dart';
import '../common/controllers/items_controller.dart';
import '../item_details/item_details_page.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key, required this.itemsController});
  static const route = '/catalog';

  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final categories = ['all', 'Apartment', 'Villa', 'Beach House'];
    final cities = ['Dubai', 'Al Ula', 'Muscat'];
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('catalog')),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_alt_outlined),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: itemsController,
        builder: (context, _) {
          return Column(
            children: [
              SizedBox(
                height: 50,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
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
              SizedBox(
                height: 50,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final label = cities[index];
                    return AnimatedFilterChip(
                      label: label,
                      selected: itemsController.city == label,
                      onTap: () => itemsController.setCity(label),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: cities.length,
                ),
              ),
              Expanded(
                child: itemsController.isLoading
                    ? ListView(children: List.generate(4, (i) => const SkeletonCard()))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: itemsController.items.length,
                        itemBuilder: (context, index) {
                          final item = itemsController.items[index];
                          return ItemCard(
                            item: item,
                            onTap: () => Navigator.of(context).pushNamed(ItemDetailsPage.route, arguments: item),
                            onToggleFavorite: () => itemsController.toggleFavorite(item.id),
                            onToggleCompare: () => itemsController.toggleCompare(item.id),
                            isFavorite: itemsController.favorites.contains(item.id),
                            isInCompare: itemsController.compare.contains(item.id),
                          );
                        },
                      ),
              ),
              if (itemsController.hasMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: itemsController.isLoadingMore
                      ? const CircularProgressIndicator()
                      : TextButton(
                          onPressed: itemsController.loadMore,
                          child: Text(t.translate('view_all')),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}
