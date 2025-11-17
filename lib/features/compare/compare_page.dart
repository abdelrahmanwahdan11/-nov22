import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../common/controllers/items_controller.dart';
import '../common/models/item.dart';
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
    final attributes = [
      _CompareAttribute(title: t.translate('price'), value: (item) => item.price),
      _CompareAttribute(title: t.translate('location'), value: (item) => item.location),
      _CompareAttribute(title: t.translate('type'), value: (item) => item.type),
      _CompareAttribute(title: t.translate('rooms'), value: (item) => item.rooms.toString()),
      _CompareAttribute(title: t.translate('ai_info'), value: (item) => item.description ?? t.translate('ai_info_placeholder')),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('compare'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 140),
                    ...items.map(
                      (item) => _CompareHeaderCell(
                        item: item,
                        onRemove: () => itemsController.removeFromCompare(item.id),
                        onOpen: () => Navigator.of(context).pushNamed(ItemDetailsPage.route, arguments: item),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...attributes.map(
                (attr) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AttributeTitle(title: attr.title),
                      ...items.map((item) => _AttributeValue(value: attr.value(item))).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 140),
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(ItemDetailsPage.route, arguments: item),
                        icon: const Icon(IconlyLight.arrow_right_2),
                        label: Text(t.translate('compare_now')),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _CompareAttribute {
  _CompareAttribute({required this.title, required this.value});

  final String title;
  final String Function(Item item) value;
}

class _CompareHeaderCell extends StatelessWidget {
  const _CompareHeaderCell({required this.item, required this.onRemove, required this.onOpen});

  final Item item;
  final VoidCallback onRemove;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
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
              Expanded(
                child: Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(onPressed: onRemove, icon: const Icon(IconlyLight.delete)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(item.image, height: 120, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(item.type, style: Theme.of(context).textTheme.bodySmall),
          Text(item.location, style: Theme.of(context).textTheme.bodyMedium),
          TextButton(onPressed: onOpen, child: Text(AppLocalizations.of(context).translate('view_all')))
        ],
      ),
    );
  }
}

class _AttributeTitle extends StatelessWidget {
  const _AttributeTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

class _AttributeValue extends StatelessWidget {
  const _AttributeValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
