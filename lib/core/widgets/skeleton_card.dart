import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(height: 16, width: double.infinity, color: baseColor, borderRadius: BorderRadius.circular(8)),
                const SizedBox(height: 8),
                Container(height: 12, width: double.infinity, color: baseColor, borderRadius: BorderRadius.circular(8)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: Container(height: 12, color: baseColor, borderRadius: BorderRadius.circular(8))),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 12, color: baseColor, borderRadius: BorderRadius.circular(8))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fade(begin: 0.3, end: 1, duration: const Duration(milliseconds: 800));
  }
}
