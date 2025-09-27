import "dart:math";
import "dart:ui";

import "package:dartx/dartx.dart";
import "package:flutter/material.dart";

class GradientBorderSide {
  final List<Color> colors;
  final double width;

  const GradientBorderSide({required this.colors, this.width = 1});

  const GradientBorderSide.none() : this(colors: const [Colors.transparent], width: 0);

  GradientBorderSide copyWith({
    List<Color>? colors,
    double? width,
  }) {
    return GradientBorderSide(
      colors: colors ?? this.colors,
      width: width ?? this.width,
    );
  }

  static GradientBorderSide lerp(GradientBorderSide a, GradientBorderSide b, double t) {
    return GradientBorderSide(
      colors: List.generate(
        max(a.colors.length, b.colors.length),
        (i) => Color.lerp(a.colors.elementAtOrNull(i), b.colors.elementAtOrNull(i), t)!,
      ),
      width: lerpDouble(a.width, a.width, t)!,
    );
  }

  GradientBorderSide operator *(num multiplier) {
    return copyWith(width: width * multiplier);
  }
}

/// Similar to RoundedRectangleBorder, but allows negative BorderRadius values
/// to create corners rounding outwards
class ExternalRoundedCornersBorder extends ShapeBorder {
  final BorderRadius borderRadius;
  final GradientBorderSide borderSide;

  const ExternalRoundedCornersBorder({
    this.borderRadius = BorderRadius.zero,
    this.borderSide = const GradientBorderSide.none(),
  });

  /// Receives the possitive BorderRadius values, and turns them negative appropriately
  /// so that the shape looks "docked" into the selected sides
  ExternalRoundedCornersBorder.docked({
    BorderRadius borderRadius = BorderRadius.zero,
    bool isDockedTop = false,
    bool isDockedBottom = false,
    bool isDockedLeft = false,
    bool isDockedRight = false,
    this.borderSide = const GradientBorderSide.none(),
  }) : assert(
         !borderRadius.topLeft.x.isNegative &&
             !borderRadius.topLeft.y.isNegative &&
             !borderRadius.topRight.x.isNegative &&
             !borderRadius.topRight.y.isNegative &&
             !borderRadius.bottomLeft.x.isNegative &&
             !borderRadius.bottomLeft.y.isNegative &&
             !borderRadius.bottomRight.x.isNegative &&
             !borderRadius.bottomRight.y.isNegative,
         "ExternalRoundedCornersBorder.docked receives the possitive BorderRadius values,"
         " and turns them negative appropriately so that the shape looks \"docked\" into the selected sides."
         " to manually pass in the negative radius, use the default constructor.",
       ),
       borderRadius = BorderRadius.only(
         topLeft: isDockedTop && isDockedLeft
             ? Radius.zero
             : Radius.elliptical(
                 borderRadius.topLeft.x * (isDockedTop ? -1 : 1),
                 borderRadius.topLeft.y * (isDockedLeft ? -1 : 1),
               ),
         topRight: isDockedTop && isDockedRight
             ? Radius.zero
             : Radius.elliptical(
                 borderRadius.topRight.x * (isDockedTop ? -1 : 1),
                 borderRadius.topRight.y * (isDockedRight ? -1 : 1),
               ),
         bottomLeft: isDockedBottom && isDockedLeft
             ? Radius.zero
             : Radius.elliptical(
                 borderRadius.bottomLeft.x * (isDockedBottom ? -1 : 1),
                 borderRadius.bottomLeft.y * (isDockedLeft ? -1 : 1),
               ),
         bottomRight: isDockedBottom && isDockedRight
             ? Radius.zero
             : Radius.elliptical(
                 borderRadius.bottomRight.x * (isDockedBottom ? -1 : 1),
                 borderRadius.bottomRight.y * (isDockedRight ? -1 : 1),
               ),
       );

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.only(
      left: max(
        borderRadius.topLeft.x.isNegative ? borderRadius.topLeft.x.abs() : 0,
        borderRadius.bottomLeft.x.isNegative ? borderRadius.bottomLeft.x.abs() : 0,
      ),
      right: max(
        borderRadius.topRight.x.isNegative ? borderRadius.topRight.x.abs() : 0,
        borderRadius.bottomRight.x.isNegative ? borderRadius.bottomRight.x.abs() : 0,
      ),
      top: max(
        borderRadius.topLeft.y.isNegative ? borderRadius.topLeft.y.abs() : 0,
        borderRadius.topRight.y.isNegative ? borderRadius.topRight.y.abs() : 0,
      ),
      bottom: max(
        borderRadius.bottomRight.y.isNegative ? borderRadius.bottomRight.y.abs() : 0,
        borderRadius.bottomLeft.y.isNegative ? borderRadius.bottomLeft.y.abs() : 0,
      ),
    );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // TODO: 2 if radius*2 > size, this missclips in a weird way. Clamp the radius somehow
    final width = rect.width;
    final height = rect.height;
    final padding = dimensions as EdgeInsets;
    final left = rect.left + padding.left;
    final right = rect.left + width - padding.right;
    final top = rect.top + padding.top;
    final bottom = rect.top + height - padding.bottom;
    final path = Path();
    // Top-left corner
    path.moveTo(left, top + borderRadius.topLeft.y);
    path.quadraticBezierTo(left, top, left + borderRadius.topLeft.x, top);
    // Top-right corner
    path.lineTo(right - borderRadius.topRight.x, top);
    path.quadraticBezierTo(right, top, right, top + borderRadius.topRight.y);
    // Bottom-right corner
    path.lineTo(right, bottom - borderRadius.bottomRight.y);
    path.quadraticBezierTo(right, bottom, right - borderRadius.bottomRight.x, bottom);
    // Bottom-left corner
    path.lineTo(left + borderRadius.bottomLeft.x, bottom);
    path.quadraticBezierTo(left, bottom, left, bottom - borderRadius.bottomLeft.y);
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (borderSide.width == 0) return;
    if (borderSide.colors.isEmpty) return;
    if (borderSide.colors.all((e) => e.a == 0)) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderSide.width * 2;
    if (borderSide.colors.length == 1) {
      paint.color = borderSide.colors.first;
    } else {
      paint.shader = LinearGradient(
        colors: borderSide.colors,
        begin: Alignment.topLeft, // TODO: 2 allow customizing border gradient alignment
        end: Alignment.bottomRight,
      ).createShader(rect);
    }
    final path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return ExternalRoundedCornersBorder(
      borderRadius: borderRadius * t,
      borderSide: borderSide * t,
    );
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b == null) {
      return super.lerpTo(b, t);
    }
    if (b is ExternalRoundedCornersBorder) {
      return null; // defer to lerpFrom of b
    }
    if (b is RoundedRectangleBorder) {
      return ExternalRoundedCornersBorder(
        borderRadius: BorderRadiusGeometry.lerp(borderRadius, b.borderRadius, t)!.resolve(TextDirection.ltr),
        borderSide: GradientBorderSide(
          colors: borderSide.colors.map((e) => Color.lerp(e, b.side.color, t)!).toList(),
          width: lerpDouble(borderSide.width, b.side.width, t)!,
        ),
      );
    }
    if (t < 0.5) {
      return scale(1 - (t * 2));
    }
    return b.scale((t - 0.5) * 2);
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a == null) {
      return super.lerpFrom(a, t);
    }
    if (a is ExternalRoundedCornersBorder) {
      return ExternalRoundedCornersBorder(
        borderRadius: BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t)!.resolve(TextDirection.ltr),
        borderSide: GradientBorderSide.lerp(a.borderSide, borderSide, t),
      );
    }
    if (a is RoundedRectangleBorder) {
      return ExternalRoundedCornersBorder(
        borderRadius: BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t)!.resolve(TextDirection.ltr),
        borderSide: GradientBorderSide(
          colors: borderSide.colors.map((e) => Color.lerp(a.side.color, e, t)!).toList(),
          width: lerpDouble(a.side.width, borderSide.width, t)!,
        ),
      );
    }
    if (t < 0.5) {
      return a.scale(1 - (t * 2));
    }
    return scale((t - 0.5) * 2);
  }
}
