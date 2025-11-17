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
    final cities = [
      'All',
      'Dubai',
      'Al Ula',
      'Muscat',
      'Riyadh',
      'Jeddah',
      'Abha',
      'Doha',
      'Manama',
      'Sharjah',
      'Alexandria',
      'Al Ain',
      'Kuwait City'
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('catalog')),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => itemsController.setSort(value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'recent', child: Text(t.translate('sort_recent'))),
              PopupMenuItem(value: 'priceLowHigh', child: Text(t.translate('sort_price_low_high'))),
              PopupMenuItem(value: 'priceHighLow', child: Text(t.translate('sort_price_high_low'))),
            ],
          ),
          IconButton(
            onPressed: () => _showFilters(context, t),
            icon: const Icon(Icons.filter_alt_outlined),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: itemsController,
        builder: (context, _) {
          String sortLabel(String value) {
            switch (value) {
              case 'priceLowHigh':
                return t.translate('sort_price_low_high');
              case 'priceHighLow':
                return t.translate('sort_price_high_low');
              default:
                return t.translate('sort_recent');
            }
          }
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
                      selected: itemsController.city == (label == 'All' ? null : label),
                      onTap: () => itemsController.setCity(label == 'All' ? null : label),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: cities.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Chip(
                      label: Text('${t.translate('sort')}: ${sortLabel(itemsController.sort)}'),
                      avatar: const Icon(Icons.sort, size: 18),
                    ),
                    const Spacer(),
                    if (itemsController.category != null ||
                        itemsController.city != null ||
                        itemsController.sort != 'recent')
                      TextButton(
                        onPressed: () {
                          itemsController.clearFilters();
                          itemsController.setSort('recent');
                        },
                        child: Text(t.translate('clear')),
                      ),
                  ],
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
                          note: itemsController.itemNotes[item.id],
                          showNoteBadge: true,
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

  void _showFilters(BuildContext context, AppLocalizations t) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final items = itemsController;
        return StatefulBuilder(
          builder: (context, setState) {
            final range = items.selectedPriceRange;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.translate('filters'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(t.translate('filter_price')),
                  RangeSlider(
                    values: range,
                    min: items.priceBounds.start,
                    max: items.priceBounds.end,
                    divisions: 6,
                    labels: RangeLabels(
                      '${range.start.toStringAsFixed(0)}',
                      '${range.end.toStringAsFixed(0)}',
                    ),
                    onChanged: (values) {
                      setState(() => items.setPriceRange(values));
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(t.translate('filter_city')),
                  DropdownButton<String?>(
                    value: items.city,
                    isExpanded: true,
                    items: cities
                        .map(
                          (city) => DropdownMenuItem(
                            value: city == 'All' ? null : city,
                            child: Text(city),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => items.setCity(value)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          items.clearFilters();
                          Navigator.of(context).pop();
                        },
                        child: Text(t.translate('clear')),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(t.translate('apply_filters')),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
