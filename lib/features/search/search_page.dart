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

  void _toggleSave() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    final t = AppLocalizations.of(context);
    final wasSaved = widget.itemsController.isSearchSaved(query);
    widget.itemsController.toggleSaveSearch(query);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(wasSaved ? t.translate('remove_saved_search') : t.translate('search_saved')),
      ),
    );
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
          final saved = widget.itemsController.savedSearches;
          final isSaved = widget.itemsController.isSearchSaved(_controller.text);
          if (_loading) {
            return ListView(children: List.generate(4, (index) => const SkeletonCard()));
          }
          final saveBar = Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.translate('save_search_hint'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _controller.text.isEmpty ? null : _toggleSave,
                  icon: Icon(isSaved ? Icons.bookmark_remove : Icons.bookmark_add_outlined),
                  label: Text(isSaved ? t.translate('remove_saved_search') : t.translate('save_search')),
                ),
              ],
            ),
          );
          if (_controller.text.isEmpty && recents.isNotEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                saveBar,
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
                if (saved.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(t.translate('saved_searches'), style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          for (final entry in List.of(saved)) {
                            widget.itemsController.removeSavedSearch(entry.id);
                          }
                        },
                        child: Text(t.translate('clear_history')),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: saved
                        .map(
                          (entry) => InputChip(
                            label: Text(entry.query),
                            onPressed: () {
                              _controller.text = entry.query;
                              widget.itemsController.applySavedSearch(entry);
                            },
                            onDeleted: () => widget.itemsController.removeSavedSearch(entry.id),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
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
            children: [
              saveBar,
              if (saved.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: saved
                        .map(
                          (entry) => ActionChip(
                            label: Text(entry.query),
                            avatar: const Icon(Icons.history, size: 18),
                            onPressed: () {
                              _controller.text = entry.query;
                              widget.itemsController.applySavedSearch(entry);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ...widget.itemsController.items
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
            ],
          );
        },
      ),
    );
  }
}
