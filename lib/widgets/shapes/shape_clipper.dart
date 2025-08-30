import "package:flutter/widgets.dart";

class ShapeClipper extends CustomClipper<Path> {
  final ShapeBorder shape;
  final Rect? rectOverride;

  ShapeClipper({required this.shape, this.rectOverride});

  @override
  Path getClip(Size size) {
    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final innerPath = shape.getOuterPath(rectOverride ?? Rect.fromLTWH(0, 0, size.width, size.height));
    return Path.combine(PathOperation.difference, outerPath, innerPath);
  }

  @override
  bool shouldReclip(ShapeClipper oldClipper) => shape != oldClipper.shape;
}
