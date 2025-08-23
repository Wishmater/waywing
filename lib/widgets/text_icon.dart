import "package:flutter/material.dart";

class TextIcon extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;

  const TextIcon({
    required this.text,
    this.size,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final iconTheme = Theme.of(context).iconTheme;
    final adjustedSize = (size ?? iconTheme.size ?? kDefaultFontSize) * (24 / 14);
    return SizedBox(
      width: adjustedSize,
      height: adjustedSize,
      child: Text(
        text,
        style: TextStyle(
          fontSize: adjustedSize,
          color: color ?? iconTheme.color,
          height: 1,
        ),
      ),
    );
  }
}
