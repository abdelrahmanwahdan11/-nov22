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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: t.translate('search'),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() => _loading = false);
                widget.itemsController.search('');
              },
            ),
          ),
          onChanged: (value) async {
            setState(() => _loading = true);
            await Future.delayed(const Duration(milliseconds: 300));
            widget.itemsController.search(value);
            setState(() => _loading = false);
          },
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.itemsController,
        builder: (context, _) {
          if (_loading) {
            return ListView(children: List.generate(4, (index) => const SkeletonCard()));
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
