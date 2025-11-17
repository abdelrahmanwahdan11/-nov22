import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconly/iconly.dart';

import '../../features/common/models/item.dart';
import '../localization/app_localizations.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onToggleCompare,
    this.note,
    this.isFavorite = false,
    this.isInCompare = false,
    this.showNoteBadge = false,
    this.compact = false,
    this.margin,
  });

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleCompare;
  final String? note;
  final bool isFavorite;
  final bool isInCompare;
  final bool showNoteBadge;
  final bool compact;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    final hasNote = (note ?? '').isNotEmpty;
    final imageHeight = compact ? 150.0 : 180.0;
    final contentPadding = compact ? 10.0 : 12.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: item.id,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    Image.network(
                      item.image,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: CircleAvatar(
                        backgroundColor: theme.cardColor.withOpacity(0.85),
                        child: IconButton(
                          onPressed: onToggleFavorite,
                          icon: Icon(
                            isFavorite ? IconlyBold.heart : IconlyLight.heart,
                            color: isFavorite ? theme.colorScheme.primary : theme.iconTheme.color,
                          ),
                        ),
                      ),
                    ),
                    if (item.isNew)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            t.translate('new'),
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    if (hasNote && showNoteBadge)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.cardColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.sticky_note_2_outlined, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                t.translate('note'),
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(IconlyLight.location, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.location,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 6 : 8),
                  Wrap(
                    spacing: compact ? 8 : 12,
                    runSpacing: compact ? 4 : 6,
                    children: [
                      _Attribute(icon: IconlyLight.wallet, label: item.price),
                      _Attribute(icon: IconlyLight.home, label: item.type),
                      _Attribute(icon: IconlyLight.user_1, label: '${item.rooms}'),
                      _Attribute(icon: Icons.bathtub_outlined, label: '${item.baths}'),
                      _Attribute(icon: Icons.square_foot, label: '${item.area.toStringAsFixed(0)} m²'),
                      _Attribute(icon: Icons.star_rounded, label: item.rating.toStringAsFixed(1)),
                    ],
                  ),
                  if (hasNote) ...[
                    SizedBox(height: compact ? 4 : 6),
                    Row(
                      children: [
                        const Icon(Icons.sticky_note_2_outlined, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            note!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: compact ? 6 : 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: onToggleCompare,
                        icon: Icon(
                          isInCompare ? IconlyBold.swap : IconlyLight.swap,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(
                          isInCompare ? t.translate('added') : t.translate('compare'),
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ),
                      const Spacer(),
                      const Icon(IconlyLight.arrow_right_2),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: const Duration(milliseconds: 250))
          .slideY(begin: 0.05, end: 0, duration: const Duration(milliseconds: 250)),
    );
  }
}

class _Attribute extends StatelessWidget {
  const _Attribute({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
