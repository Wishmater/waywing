import "dart:math";

import "package:collection/collection.dart";
import "package:dartx/dartx.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:waywing/widgets/shapes/external_rounded_corners_shape.dart";

class ShapeInteriorClipper extends CustomClipper<Path> {
  final ShapeBorder shape;
  final Rect? rectOverride;
  final bool useInnerPath;

  ShapeInteriorClipper({
    required this.shape,
    this.rectOverride,
    this.useInnerPath = false,
  });

  @override
  Path getClip(Size size) {
    if (useInnerPath) {
      return shape.getInnerPath(rectOverride ?? Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      return shape.getOuterPath(rectOverride ?? Rect.fromLTWH(0, 0, size.width, size.height));
    }
  }

  @override
  bool shouldReclip(ShapeInteriorClipper oldClipper) => shape != oldClipper.shape;
}

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
  bool shouldReclip(ShapeClipper oldClipper) =>
      shape != oldClipper.shape || rectOverride != oldClipper.rectOverride || contain != oldClipper.contain;
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
      !DeepCollectionEquality.unordered().equals(shapes, oldClipper.shapes) || contain != oldClipper.contain;
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
  bool shouldReclip(ShapeShadowClipper oldClipper) =>
      shape != oldClipper.shape || rectOverride != oldClipper.rectOverride || offset != oldClipper.offset;
}

class ShapeBorderAndShadowPainter extends CustomPainter {
  final ShapeBorder shape;
  final GradientBorderSide? border;
  final Color shadowColor;
  final Offset shadowOffset;
  final double elevation;

  ShapeBorderAndShadowPainter({
    super.repaint,
    required this.shape,
    required this.border,
    required Offset shadowOffset,
    required this.elevation,
    required this.shadowColor,
  }) : shadowOffset = border == null || border.width <= 0
           ? shadowOffset
           : Offset(shadowOffset.dx + border.width, shadowOffset.dy + border.width);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // Path of the shape (container) that we want to draw a shadow on
    final shapePath = shape.getOuterPath(rect);

    // Caclulate shapeClipPath, which is the inverse of shapePath, used to clip shadow below
    // the container, so it works properly for containers with transparent background
    final outerPath = Path()..addRect(Rect.fromLTRB(-10000000, -10000000, 10000000, 10000000));
    final shapeClipPath = Path.combine(PathOperation.difference, outerPath, shapePath);

    // Save the canvas state
    canvas.save();

    // Apply clipping
    canvas.clipPath(shapeClipPath);

    if (elevation > 0) {
      // Calculate the path of the shadow, by progressively translating the original path in
      // the direction of the offset and getting the union of all steps. This can probably be
      // done in a better way, but this is what I came up with and it works.
      var shadowPath = shapePath;
      final steps = max(shadowOffset.dx, shadowOffset.dy);
      for (int i = 1; i <= steps; i++) {
        final adjustedOffset = shadowOffset * (i / steps);
        final offsetPath = shapePath.shift(adjustedOffset);
        shadowPath = Path.combine(PathOperation.union, shadowPath, offsetPath);
      }
      // Paint shadow with solid color and blur
      Paint paint = Paint()
        ..color = shadowColor
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, Shadow.convertRadiusToSigma(elevation));
      canvas.drawPath(shadowPath, paint);
    }

    // Paint border
    if (border case final border?) {
      if (border.width != 0 && border.colors.isNotEmpty && !border.colors.all((e) => e.a == 0)) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = border.width * 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        // ..blendMode = BlendMode.src; // make it so that it "overrides" the shadow
        if (border.colors.length == 1) {
          paint.color = border.colors.first;
        } else {
          paint.shader = LinearGradient(
            colors: border.colors,
            begin: border.alignmentBegin,
            end: border.alignmentEnd,
          ).createShader(rect);
        }
        canvas.drawPath(shapePath, paint);
      }
    }

    // Restore the canvas to remove clipping
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ShapeBorderAndShadowPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.elevation != elevation ||
        oldDelegate.shadowColor != shadowColor ||
        shadowOffset != oldDelegate.shadowOffset;
  }
}
