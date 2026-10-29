import 'package:flutter/material.dart';

enum AppButtonType { filled, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.filled,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.style, // null = theme default
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final onTap = isLoading ? null : onPressed;
    final child = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    final Widget button;
    if (icon != null && !isLoading) {
      final i = Icon(icon, size: 18);
      switch (type) {
        case AppButtonType.filled:
          button = FilledButton.icon(onPressed: onTap, style: style, icon: i, label: child);
        case AppButtonType.outlined:
          button = OutlinedButton.icon(onPressed: onTap, style: style, icon: i, label: child);
        case AppButtonType.text:
          button = TextButton.icon(onPressed: onTap, style: style, icon: i, label: child);
      }
    } else {
      switch (type) {
        case AppButtonType.filled:
          button = FilledButton(onPressed: onTap, style: style, child: child);
        case AppButtonType.outlined:
          button = OutlinedButton(onPressed: onTap, style: style, child: child);
        case AppButtonType.text:
          button = TextButton(onPressed: onTap, style: style, child: child);
      }
    }

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}