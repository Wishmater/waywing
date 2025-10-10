import "dart:math";
import "dart:ui";

import "package:collection/collection.dart" as collection show DeepCollectionEquality;
import "package:dartx/dartx.dart";
import "package:flutter/material.dart";

class GradientBorderSide {
  final List<Color> colors;
  final double width;
  final double angle;
  late final double angleRadians = angle * pi / 180;
  late final Alignment alignmentBegin = Alignment(-cos(angleRadians), -sin(angleRadians));
  late final Alignment alignmentEnd = Alignment(cos(angleRadians), sin(angleRadians));

  // TODO: 3 make this const somehow. The problem is that sin() and cos() can't be called
  GradientBorderSide({
    required this.colors,
    this.width = 1,
    required this.angle,
  }) : assert(colors.isNotEmpty, "At least one color is needed. Maybe just pass [Colors.transparent].");

  // TODO: 3 make this const if we can make GradientBorderSide const
  static final none = GradientBorderSide(
    colors: const [Colors.transparent],
    width: 0,
    angle: 0,
  );

  GradientBorderSide copyWith({
    List<Color>? colors,
    double? width,
    double? angle,
  }) {
    return GradientBorderSide(
      colors: colors ?? this.colors,
      width: width ?? this.width,
      angle: angle ?? this.angle,
    );
  }

  static GradientBorderSide lerp(GradientBorderSide a, GradientBorderSide b, double t) {
    return GradientBorderSide(
      colors: List.generate(
        max(a.colors.length, b.colors.length),
        (i) => Color.lerp(a.colors.elementAtOrNull(i), b.colors.elementAtOrNull(i), t)!,
      ),
      width: lerpDouble(a.width, a.width, t)!,
      angle: lerpDouble(a.angle, b.angle, t)!,
    );
  }

  GradientBorderSide operator *(num multiplier) {
    return copyWith(width: width * multiplier);
  }

  @override
  bool operator ==(Object other) {
    return other is GradientBorderSide &&
        other.width == width &&
        other.angle == angle &&
        collection.DeepCollectionEquality().equals(other.colors, colors);
  }

  @override
  int get hashCode => Object.hashAll([width, angle, ...colors]);

  @override
  String toString() {
    return "$runtimeType($width, $angle, $colors)";
  }
}

/// Similar to RoundedRectangleBorder, but allows negative BorderRadius values
/// to create corners rounding outwards
class ExternalRoundedCornersBorder extends ShapeBorder {
  final BorderRadius borderRadius;
  final GradientBorderSide borderSide;

  // TODO: 3 make this const if we can make GradientBorderSide const
  ExternalRoundedCornersBorder({
    this.borderRadius = BorderRadius.zero,
    GradientBorderSide? borderSide,
  }) : borderSide = borderSide ?? GradientBorderSide.none;

  @override
  EdgeInsets get dimensions {
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

  /// Similar to dimensions, but returns size taken by normal rounded borders, which isn't
  /// actually applied as padding to content, but is useful for other calculations
  EdgeInsets get innerDimensions {
    return EdgeInsets.only(
      left: max(
        !borderRadius.topLeft.x.isNegative ? borderRadius.topLeft.x : 0,
        !borderRadius.bottomLeft.x.isNegative ? borderRadius.bottomLeft.x : 0,
      ),
      right: max(
        !borderRadius.topRight.x.isNegative ? borderRadius.topRight.x : 0,
        !borderRadius.bottomRight.x.isNegative ? borderRadius.bottomRight.x : 0,
      ),
      top: max(
        !borderRadius.topLeft.y.isNegative ? borderRadius.topLeft.y : 0,
        !borderRadius.topRight.y.isNegative ? borderRadius.topRight.y : 0,
      ),
      bottom: max(
        !borderRadius.bottomRight.y.isNegative ? borderRadius.bottomRight.y : 0,
        !borderRadius.bottomLeft.y.isNegative ? borderRadius.bottomLeft.y : 0,
      ),
    );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // TODO: 1 if radius*2 > size, this missclips in a weird way. Clamp the radius somehow
    final width = rect.width;
    final height = rect.height;
    final padding = dimensions;
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
    path.lineTo(left, top + borderRadius.topLeft.y);
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // TODO: 1 right now, the border paints on top of the container background color. This will warp
    // the intended border colors if they have transparency. We probably need to implement proper getInnerPath
    // to fix this
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
        begin: borderSide.alignmentBegin,
        end: borderSide.alignmentEnd,
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
          angle: borderSide.angle,
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
          angle: borderSide.angle,
        ),
      );
    }
    if (t < 0.5) {
      return a.scale(1 - (t * 2));
    }
    return scale((t - 0.5) * 2);
  }

  @override
  bool operator ==(Object other) {
    return other is ExternalRoundedCornersBorder &&
        other.borderRadius == borderRadius &&
        other.borderSide == borderSide;
  }

  @override
  int get hashCode => Object.hash(borderRadius, borderSide);

  @override
  String toString() {
    return "$runtimeType($borderRadius, $borderSide)";
  }

  ExternalRoundedCornersBorder copyWith({
    BorderRadius? borderRadius,
    GradientBorderSide? borderSide,
  }) {
    return ExternalRoundedCornersBorder(
      borderRadius: borderRadius ?? this.borderRadius,
      borderSide: borderSide ?? this.borderSide,
    );
  }

  /// Receives the possitive BorderRadius values, and turns them negative appropriately
  /// so that the shape looks "docked" into the selected sides. If you have the exact
  /// container position and screen bounds, prefer using .positioned instead.
  ExternalRoundedCornersBorder.docked({
    BorderRadius borderRadius = BorderRadius.zero,
    bool isDockedTop = false,
    bool isDockedBottom = false,
    bool isDockedLeft = false,
    bool isDockedRight = false,
    GradientBorderSide? borderSide,
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
       borderSide = borderSide ?? GradientBorderSide.none,
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

  /// Receives the possitive BorderRadius values, and turns them negative appropriately
  /// so that the shape looks "docked" into the selected sides
  ExternalRoundedCornersBorder.positioned({
    BorderRadius borderRadius = BorderRadius.zero,
    required Rect position,
    required Rect bounds,
    List<Rect> parentContainers = const [],
    GradientBorderSide? borderSide,
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
       borderSide = borderSide ?? GradientBorderSide.none,
       borderRadius = _getPositionedBorderRadius(borderRadius, position, bounds, parentContainers);
}

BorderRadius _getPositionedBorderRadius(
  BorderRadius borderRadius,
  Rect position,
  Rect bounds,
  List<Rect> parentContainers,
) {
  // print("=============================================================");
  return BorderRadius.only(
    topLeft: _getCornerRadius(
      borderRadius.topLeft,
      position,
      bounds,
      parentContainers,
      Side.top,
      Side.left,
    ),
    topRight: _getCornerRadius(
      borderRadius.topRight,
      position,
      bounds,
      parentContainers,
      Side.top,
      Side.right,
    ),
    bottomLeft: _getCornerRadius(
      borderRadius.bottomLeft,
      position,
      bounds,
      parentContainers,
      Side.bottom,
      Side.left,
    ),
    bottomRight: _getCornerRadius(
      borderRadius.bottomRight,
      position,
      bounds,
      parentContainers,
      Side.bottom,
      Side.right,
    ),
  );
}

_getCornerRadius(
  Radius radius,
  Rect position,
  Rect bounds,
  List<Rect> parentContainers,
  Side y,
  Side x,
) {
  // print("Calculating corner $y $x");
  final positionX = _getRectSide(position, x);
  final positionY = _getRectSide(position, y);
  final potentialPositionX = (positionX + _getPotentialRadiusAdjustment(radius, x)).clamp(bounds.left, bounds.right);
  final potentialPositionY = (positionY + _getPotentialRadiusAdjustment(radius, y)).clamp(bounds.top, bounds.bottom);
  // print("  position = $positionX, $positionY");
  final closestBoundX = _getClosestBound(bounds, parentContainers, x, positionX, potentialPositionY);
  final closestBoundY = _getClosestBound(bounds, parentContainers, y, positionY, potentialPositionX);
  // print("  closestBoundX = $closestBoundX");
  // print("  closestBoundY = $closestBoundY");
  final isDockedX = closestBoundX == positionX;
  final isDockedY = closestBoundY == positionY;
  if (isDockedX && isDockedY) {
    return Radius.zero;
  }
  final result = Radius.elliptical(
    !isDockedY ? radius.x : -radius.x,
    !isDockedX ? radius.y : -radius.y,
    // !isDockedY ? radius.x : (positionX - closestBoundX).negative.clamp(-radius.x, 0),
    // !isDockedX ? radius.y : (positionY - closestBoundY).negative.clamp(-radius.y, 0),
  );
  // print("  result = $result");
  return result;
}

double _getClosestBound(
  Rect bounds,
  List<Rect> parentContainers,
  Side side,
  double mainPoint,
  double crossPoint,
) {
  var result = _getRectSide(bounds, side);
  var diff = (mainPoint - result).abs();
  for (final e in parentContainers) {
    if (_getRectSide(e, side.adjacent) > crossPoint || //
        _getRectSide(e, side.adjacent.opposite) < crossPoint) {
      continue;
    }
    final containerBound = _getRectSide(e, side.opposite);
    final containerDiff = (mainPoint - containerBound).abs();
    if (containerDiff < diff) {
      result = containerBound;
      diff = containerDiff;
    }
  }
  return result;
}

double _getRectSide(Rect rect, Side side) {
  return switch (side) {
    Side.left => rect.left,
    Side.right => rect.right,
    Side.top => rect.top,
    Side.bottom => rect.bottom,
  };
}

double _getPotentialRadiusAdjustment(Radius radius, Side side) {
  return switch (side) {
    Side.left => -radius.x,
    Side.right => radius.x,
    Side.top => -radius.y,
    Side.bottom => radius.y,
  };
}

enum Side {
  left,
  right,
  top,
  bottom;

  Side get opposite {
    return switch (this) {
      Side.left => Side.right,
      Side.right => Side.left,
      Side.top => Side.bottom,
      Side.bottom => Side.top,
    };
  }

  Side get adjacent {
    return switch (this) {
      Side.left => Side.top,
      Side.right => Side.top,
      Side.top => Side.left,
      Side.bottom => Side.left,
    };
  }
}

extension Negative on double {
  double get negative => isNegative ? this : this * -1;
}
