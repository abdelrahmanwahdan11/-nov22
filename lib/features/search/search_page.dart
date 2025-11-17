import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/skeleton_card.dart';
import '../common/controllers/items_controller.dart';
import '../item_details/item_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.itemsController});
  static const route = '/search';

  final ItemsController itemsController;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _loading = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String value) async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    widget.itemsController.search(value);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: t.translate('search'),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() => _loading = false);
                _controller.clear();
                widget.itemsController.search('');
              },
            ),
          ),
          onChanged: _performSearch,
          onSubmitted: _performSearch,
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.itemsController,
        builder: (context, _) {
          final recents = widget.itemsController.recentSearches;
          final viewed = widget.itemsController.recentlyViewedItems;
          if (_loading) {
            return ListView(children: List.generate(4, (index) => const SkeletonCard()));
          }
          if (_controller.text.isEmpty && recents.isNotEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Text(t.translate('recent_searches'), style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    TextButton(
                      onPressed: widget.itemsController.clearRecentSearches,
                      child: Text(t.translate('clear_history')),
                    )
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: recents
                      .map(
                        (query) => InputChip(
                          label: Text(query),
                          onPressed: () {
                            _controller.text = query;
                            _performSearch(query);
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text(t.translate('recently_viewed'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (viewed.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(t.translate('recently_viewed_empty')),
                  )
                else
                  SizedBox(
                    height: 260,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: viewed.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = viewed[index];
                        return SizedBox(
                          width: 280,
                          child: ItemCard(
                            item: item,
                            onTap: () => Navigator.of(context)
                                .pushNamed(ItemDetailsPage.route, arguments: item),
                            onToggleFavorite: () => widget.itemsController.toggleFavorite(item.id),
                            onToggleCompare: () => widget.itemsController.toggleCompare(item.id),
                            isFavorite: widget.itemsController.favorites.contains(item.id),
                            isInCompare: widget.itemsController.compare.contains(item.id),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          }
          if (widget.itemsController.items.isEmpty) {
            return Center(child: Text(t.translate('no_results_found')));
          }
          return ListView(
            children: widget.itemsController.items
                .map(
                  (item) => ItemCard(
                    item: item,
                    onTap: () => Navigator.of(context).pushNamed(ItemDetailsPage.route, arguments: item),
                    onToggleFavorite: () => widget.itemsController.toggleFavorite(item.id),
                    onToggleCompare: () => widget.itemsController.toggleCompare(item.id),
                    isFavorite: widget.itemsController.favorites.contains(item.id),
                    isInCompare: widget.itemsController.compare.contains(item.id),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
