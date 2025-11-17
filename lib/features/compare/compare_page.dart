import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../common/controllers/items_controller.dart';
import '../item_details/item_details_page.dart';
import '../home/home_page.dart';

class ComparePage extends StatelessWidget {
  const ComparePage({super.key, required this.itemsController});
  static const route = '/compare';

  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final items = itemsController.comparedItems;
    if (items.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t.translate('empty_compare_title'), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(HomePage.route),
                child: Text(t.translate('go_home')),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('compare'))),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items
              .map(
                (item) => Container(
                  width: 260,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
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
                      Row(
                        children: [
                          Expanded(child: Text(item.name, style: Theme.of(context).textTheme.titleMedium)),
                          IconButton(
                            onPressed: () => itemsController.removeFromCompare(item.id),
                            icon: const Icon(IconlyLight.delete),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${t.translate('price')}: ${item.price}'),
                      Text('${t.translate('location')}: ${item.location}'),
                      Text('${t.translate('type')}: ${item.type}'),
                      Text('${t.translate('rooms')}: ${item.rooms}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pushNamed(ItemDetailsPage.route, arguments: item),
                        child: Text(t.translate('compare_now')),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
