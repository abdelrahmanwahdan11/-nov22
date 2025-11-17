import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconly/iconly.dart';

import '../../features/common/models/item.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onToggleCompare,
    this.isFavorite = false,
    this.isInCompare = false,
  });

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleCompare;
  final bool isFavorite;
  final bool isInCompare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                      height: 180,
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Attribute(icon: IconlyLight.wallet, label: item.price),
                      const SizedBox(width: 12),
                      _Attribute(icon: IconlyLight.home, label: item.type),
                      const SizedBox(width: 12),
                      _Attribute(icon: IconlyLight.user_1, label: '${item.rooms}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: onToggleCompare,
                        icon: Icon(
                          isInCompare ? IconlyBold.swap : IconlyLight.swap,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(
                          isInCompare ? 'Added' : 'Compare',
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
