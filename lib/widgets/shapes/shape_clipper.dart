import "dart:math";

import "package:collection/equality.dart";
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

class MultiShapeClipper extends CustomClipper<Path> {
  final List<(ShapeBorder, Rect?)> shapes;
  final bool contain;

  MultiShapeClipper({
    required this.shapes,
    this.contain = true,
  }) : assert(shapes.isNotEmpty);

  @override
  Path getClip(Size size) {
    Path outerPath;
    if (contain) {
      outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      outerPath = Path()..addRect(Rect.fromLTRB(-10000000, -10000000, 10000000, 10000000));
    }

    for (final e in shapes) {
      final shape = e.$1;
      final rectOverride = e.$2;

      final innerPath = shape.getOuterPath(rectOverride ?? Rect.fromLTWH(0, 0, size.width, size.height));
      outerPath = Path.combine(PathOperation.difference, outerPath, innerPath);
    }
    return outerPath;
  }

  @override
  bool shouldReclip(MultiShapeClipper oldClipper) =>
      DeepCollectionEquality.unordered().equals(shapes, oldClipper.shapes);
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
  final Color color;
  final Offset offset;
  final double elevation;

  ShapeShadowPainter({
    super.repaint,
    required this.shape,
    required this.offset,
    required this.elevation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Path of the shape (container) that we want to draw a shadow on
    final shapePath = shape.getOuterPath(Rect.fromLTWH(0, 0, size.width, size.height));

    // Calculate the path of the shadow, by progressively translating the original path in
    // the direction of the offset and getting the union of all steps. This can probably be
    // done in a better way, but this is what I came up with and it works.
    var shadowPath = shapePath;
    final steps = max(offset.dx, offset.dy);
    for (int i = 1; i <= steps; i++) {
      final adjustedOffset = offset * (i / steps);
      final offsetPath = shapePath.shift(adjustedOffset);
      shadowPath = Path.combine(PathOperation.union, shadowPath, offsetPath);
    }

    // Caclulate shapeClipPath, which is the inverse of shapePath, used to clip shadow below
    // the container, so it works properly for containers with transparent background
    final outerPath = Path()..addRect(Rect.fromLTRB(-10000000, -10000000, 10000000, 10000000));
    final shapeClipPath = Path.combine(PathOperation.difference, outerPath, shapePath);

    // Save the canvas state
    canvas.save();

    // Apply clipping
    canvas.clipPath(shapeClipPath);

    // Paint with solid color and blur
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, Shadow.convertRadiusToSigma(elevation));

    // Draw the main path
    canvas.drawPath(shadowPath, paint);

    // Restore the canvas to remove clipping
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ShapeShadowPainter oldDelegate) {
    return oldDelegate.shape != shape || oldDelegate.elevation != elevation || oldDelegate.color != color;
  }
}
