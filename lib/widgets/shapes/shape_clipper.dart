import "dart:math";

import "package:flutter/material.dart";
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

/// TODO create a benchmark to compare implementations
class ShapeShadowPainter extends CustomPainter {
  final ShapeBorder shape;
  final Shadow shadow;
  final Rect? rectOverride;

  const ShapeShadowPainter({required this.shape, required this.shadow, this.rectOverride});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Path innerPath = shape.getOuterPath(rect);

    final double dx = shadow.offset.dx;
    final double dy = shadow.offset.dy;
    final int steps = max(dx.abs(), dy.abs()).ceil();

    if (steps == 0) {
      // No offset, draw the original path
      canvas.drawPath(innerPath, shadow.toPaint());
      return;
    }

    // Create a union of all incremental offset paths
    // Path totalPath = innerPath;
    // for (int i = 1; i <= steps; i++) {
    //   final stepOffset =  shadow.offset * (i / steps);
    //   final shiftedPath = innerPath.shift(stepOffset);
    //   totalPath = Path.combine(PathOperation.union, totalPath, shiftedPath);
    // }

    /// TODO try different BlurStyle?
    canvas.drawPath(innerPath.shift(shadow.offset), shadow.toPaint());
  }

  @override
  bool shouldRepaint(covariant ShapeShadowPainter oldDelegate) {
    return this != oldDelegate;
  }

  @override
  bool operator==(covariant ShapeShadowPainter other) {
    return shape != other.shape || shadow != other.shadow || rectOverride != other.rectOverride;
  }

  @override
  int get hashCode => Object.hashAll([shape, shadow, rectOverride]);
}
