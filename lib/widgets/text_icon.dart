import "package:flutter/material.dart";

class TextIcon extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final Alignment alignment;

  const TextIcon({
    required this.text,
    this.size,
    this.color,
    this.alignment = Alignment.center,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final iconTheme = Theme.of(context).iconTheme;
    final adjustedSize = size ?? getIconEffectiveSize(context, size: iconTheme.size);
    return Container(
      width: adjustedSize,
      height: adjustedSize,
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(0, -1),
        child: Text(
          text,
          style: TextStyle(
            fontSize: adjustedSize,
            color: color ?? iconTheme.color,
            height: 1,
          ),
        ),
      ),
    );
  }

  static double getIconEffectiveSize(BuildContext context, {double? size}) {
    final iconTheme = Theme.of(context).iconTheme;
    final adjustedSize = (size ?? iconTheme.size ?? kDefaultFontSize) * (24 / 14);
    return adjustedSize;
  }
}
