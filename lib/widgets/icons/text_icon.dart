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
    final iconTheme = IconTheme.of(context);
    final adjustedSize = size ?? getIconEffectiveSize(context, iconTheme: iconTheme);
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

  static const fontToIconSizeRatio = 24 / 14;

  static double getIconEffectiveSize(BuildContext context, {double? size, IconThemeData? iconTheme}) {
    if (size != null) {
      return size * fontToIconSizeRatio;
    }
    iconTheme ??= IconTheme.of(context);
    if (iconTheme.size != null) {
      return iconTheme.size!;
    }
    return kDefaultFontSize * fontToIconSizeRatio;
  }
}
