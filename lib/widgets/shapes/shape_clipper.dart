import "dart:math";

import "package:flutter/widgets.dart";

class ShapeClipper extends CustomClipper<Path> {
  final ShapeBorder shape;
  final Rect? rectOverride;
  final bool contain;

  ShapeClipper({
    required this.shape,
    this.rectOverride,
    this.contain = true,
  });

  @override
  Path getClip(Size size) {
    Path outerPath;
    if (contain) {
      outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      outerPath = Path()..addRect(Rect.fromLTRB(-10000000, -10000000, 10000000, 10000000));
    }
    final innerPath = shape.getOuterPath(rectOverride ?? Rect.fromLTWH(0, 0, size.width, size.height));
    return Path.combine(PathOperation.difference, outerPath, innerPath);
  }

  @override
  bool shouldReclip(ShapeClipper oldClipper) => shape != oldClipper.shape;
}

class ShapeShadowClipper extends CustomClipper<Path> {
  final ShapeBorder shape;
  final Rect? rectOverride;
  final Offset offset;

  ShapeShadowClipper({
    required this.shape,
    required this.offset,
    this.rectOverride,
  });

  @override
  Path getClip(Size size) {
    final innerPath = shape.getOuterPath(rectOverride ?? Rect.fromLTWH(0, 0, size.width, size.height));
    var resultPath = innerPath;
    final steps = max(offset.dx, offset.dy);
    for (int i = 1; i <= steps; i++) {
      final adjustedOffset = offset * (i / steps);
      final offsetPath = innerPath.shift(adjustedOffset);
      resultPath = Path.combine(PathOperation.union, resultPath, offsetPath);
    }
    return resultPath;
    // final offsetPath = innerPath.shift(offset);
    // return Path.combine(PathOperation.difference, offsetPath, innerPath);
  }

  @override
  bool shouldReclip(ShapeShadowClipper oldClipper) => shape != oldClipper.shape;
}
