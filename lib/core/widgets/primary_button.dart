import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
  });

  final String label;
  final VoidCallback onPressed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        shadowColor: color.withOpacity(0.2),
        elevation: 3,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
    );
  }
}
