import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/filter_chip.dart';
import '../ai_info_placeholder/ai_info_placeholder_page.dart';
import '../common/controllers/items_controller.dart';
import '../common/models/item.dart';

class ItemDetailsPage extends StatefulWidget {
  const ItemDetailsPage({super.key, required this.item, required this.itemsController});
  static const route = '/item-details';

  final Item item;
  final ItemsController itemsController;

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  bool _flipped = false;
  int _galleryIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.itemsController.markViewed(widget.item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final gallery = [widget.item.image, widget.item.preview3d, widget.item.mapPreview];
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 260,
              child: PageView.builder(
                itemCount: gallery.length,
                onPageChanged: (i) => setState(() => _galleryIndex = i),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setState(() => _flipped = !_flipped),
                  child: Hero(
                    tag: widget.item.id,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _flipped
                          ? Container(
                              key: const ValueKey('back'),
                              color: Theme.of(context).cardColor,
                              alignment: Alignment.center,
                              child: Text(widget.item.description ?? 'Immersive 3D preview coming soon'),
                            )
                          : Image.network(gallery[i], fit: BoxFit.cover, key: ValueKey('front-$i')),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                gallery.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _galleryIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item.name, style: Theme.of(context).textTheme.headlineSmall),
                  Text(widget.item.location, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: widget.item.tags
                        .map((e) => AnimatedFilterChip(label: e, selected: true, onTap: () {}))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(icon: IconlyLight.wallet, label: t.translate('price'), value: widget.item.price),
                  _InfoRow(icon: IconlyLight.home, label: t.translate('type'), value: widget.item.type),
                  _InfoRow(icon: IconlyLight.user_1, label: t.translate('rooms'), value: widget.item.rooms.toString()),
                  const SizedBox(height: 16),
                  Text(t.translate('ai_info_placeholder')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => widget.itemsController.toggleFavorite(widget.item.id),
                          icon: Icon(widget.itemsController.favorites.contains(widget.item.id)
                              ? IconlyBold.heart
                              : IconlyLight.heart),
                          label: Text(t.translate('add_to_favorites')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.itemsController.toggleCompare(widget.item.id),
                          icon: const Icon(IconlyLight.swap),
                          label: Text(t.translate('add_to_compare')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => _AiInfoSheet(t: t),
                    ),
                    child: Text(t.translate('ai_info_button')),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text('$label: $value'),
        ],
      ),
    );
  }
}

class _AiInfoSheet extends StatelessWidget {
  const _AiInfoSheet({required this.t});

  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.translate('ai_info_headline'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(t.translate('ai_info_placeholder')),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.translate('done')),
          ),
        ],
      ),
    );
  }
}
