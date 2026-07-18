import 'package:flutter/material.dart';

class IconButtonWidget extends StatelessWidget {
  const IconButtonWidget({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.iconColor,
    this.iconSize = 16,
    this.padding = const .all(4),
  });

  final void Function()? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? iconColor;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: .all(5.0),
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}
