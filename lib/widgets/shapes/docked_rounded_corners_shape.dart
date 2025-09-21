import "dart:ui";

import "package:dartx/dartx.dart";
import "package:fl_linux_window_manager/models/screen_edge.dart";
import "package:flutter/widgets.dart";

Path getDockedRoundCornersPathForDirection({
  required ScreenEdge dockedSide,
  required Rect rect,
  required double radiusInCross,
  required double radiusInMain,
  double radiusOutCross = 0,
  double radiusOutMain = 0,
  bool? isVertical,
}) {
  final double radiusInX, radiusInY, radiusOutX, radiusOutY;
  if (isVertical ?? (rect.width < rect.height)) {
    radiusOutX = radiusOutCross;
    radiusOutY = radiusOutMain;
    radiusInX = radiusInCross;
    radiusInY = radiusInMain + radiusOutY;
  } else {
    radiusOutX = radiusOutMain;
    radiusOutY = radiusOutCross;
    radiusInX = radiusInMain + radiusOutX;
    radiusInY = radiusInCross;
  }
  return getDockedRoundCornersPath(
    dockedSide: dockedSide,
    rect: rect,
    radiusInX: radiusInX,
    radiusInY: radiusInY,
    radiusOutX: radiusOutX,
    radiusOutY: radiusOutY,
  );
}

Path getDockedRoundCornersPathPercForDirection({
  required ScreenEdge dockedSide,
  required Rect rect,
  required double radiusInPercCross,
  required double radiusInPercMain,
  double radiusOutPercCross = 0,
  double radiusOutPercMain = 0,
  bool? isVertical,
}) {
  final width = rect.width;
  final height = rect.height;
  final double radiusInX, radiusInY, radiusOutX, radiusOutY;
  if (isVertical ?? (width < height)) {
    radiusOutX = width * radiusOutPercCross;
    radiusOutY = width * radiusOutPercMain;
    radiusInX = width * radiusInPercCross;
    radiusInY = width * radiusInPercMain + radiusOutY;
  } else {
    radiusOutX = height * radiusOutPercMain;
    radiusOutY = height * radiusOutPercCross;
    radiusInX = height * radiusInPercMain + radiusOutX;
    radiusInY = height * radiusInPercCross;
  }
  return getDockedRoundCornersPath(
    dockedSide: dockedSide,
    rect: rect,
    radiusInX: radiusInX,
    radiusInY: radiusInY,
    radiusOutX: radiusOutX,
    radiusOutY: radiusOutY,
  );
}

Path getDockedRoundCornersPath({
  required ScreenEdge dockedSide,
  required Rect rect,
  required double radiusInX,
  required double radiusInY,
  double radiusOutX = 0,
  double radiusOutY = 0,
}) {
  final width = rect.width;
  final height = rect.height;
  final path = Path();

  // do not allow negative values (would probably cause a lot of breakage)
  if (radiusInX < 0) radiusInX = 0;
  if (radiusInY < 0) radiusInY = 0;
  if (radiusOutX < 0) radiusOutX = 0;
  if (radiusOutY < 0) radiusOutY = 0;

  // don't allow radius to exceed size (would probably cause a lot of breakage)
  if (dockedSide == ScreenEdge.left || dockedSide == ScreenEdge.right) {
    // vertical
    if ((radiusInX + radiusOutX) > rect.width) {
      final ratio = radiusInX / (radiusInX + radiusOutX);
      radiusInX = rect.width * ratio;
      radiusOutX = rect.width * (1 - ratio);
    }
    if (radiusInY * 2 > rect.height) {
      final ratio = rect.height / (radiusInY * 2);
      radiusInY *= ratio;
      radiusOutY *= ratio;
    }
  } else {
    // horizontal
    if (radiusInX * 2 > rect.width) {
      final ratio = rect.width / (radiusInX * 2);
      radiusInX *= ratio;
      radiusOutX *= ratio;
    }
    if ((radiusInY + radiusOutY) > rect.height) {
      final ratio = (radiusInY / (radiusInY + radiusOutY));
      radiusInY = rect.height * ratio;
      radiusOutY = rect.height * (1 - ratio);
    }
  }
  final x = rect.left;
  final y = rect.top;

  switch (dockedSide) {
    case ScreenEdge.right:
      // Top-left corner
      path.moveTo(x, y + radiusInY);
      path.quadraticBezierTo(x, y + radiusOutY, x + radiusInX, y + radiusOutY);
      // Top-right corner
      path.lineTo(x + width - radiusOutX, y + radiusOutY);
      path.quadraticBezierTo(x + width, y + radiusOutY, x + width, y);
      // Bottom-right corner
      path.lineTo(x + width, y + height);
      path.quadraticBezierTo(x + width, y + height - radiusOutY, x + width - radiusOutX, y + height - radiusOutY);
      // Bottom-left corner
      path.lineTo(x + radiusInX, y + height - radiusOutY);
      path.quadraticBezierTo(x, y + height - radiusOutY, x, y + height - radiusInY);

    case ScreenEdge.left:
      // Top-left corner
      path.moveTo(x, y);
      path.quadraticBezierTo(x, y + radiusOutY, x + radiusOutX, y + radiusOutY);
      // Top-right corner
      path.lineTo(x + width - radiusInX, y + radiusOutY);
      path.quadraticBezierTo(x + width, y + radiusOutY, x + width, y + radiusInY);
      // Bottom-right corner
      path.lineTo(x + width, y + height - radiusInY);
      path.quadraticBezierTo(x + width, y + height - radiusOutY, x + width - radiusInX, y + height - radiusOutY);
      // Bottom-left corner
      path.lineTo(x + radiusOutX, y + height - radiusOutY);
      path.quadraticBezierTo(x, y + height - radiusOutY, x, y + height);

    case ScreenEdge.top:
      // Top-left corner
      path.moveTo(x + radiusOutX, y + radiusOutY);
      path.quadraticBezierTo(x + radiusOutX, y, x, y);
      // Top-right corner
      path.lineTo(x + width, y);
      path.quadraticBezierTo(x + width - radiusOutX, y, x + width - radiusOutX, y + radiusOutY);
      // Bottom-right corner
      path.lineTo(x + width - radiusOutX, y + height - radiusInY);
      path.quadraticBezierTo(x + width - radiusOutX, y + height, x + width - radiusInX, y + height);
      // Bottom-left corner
      path.lineTo(x + radiusInX, y + height);
      path.quadraticBezierTo(x + radiusOutX, y + height, x + radiusOutX, y + height - radiusInY);

    case ScreenEdge.bottom:
      // Top-left corner
      path.moveTo(x, y + height);
      path.quadraticBezierTo(x + radiusOutX, y + height, x + radiusOutX, y + height - radiusOutY);
      // Top-right corner
      path.lineTo(x + radiusOutX, y + radiusInY);
      path.quadraticBezierTo(x + radiusOutX, y, x + radiusInX, y);
      // Bottom-right corner
      path.lineTo(x + width - radiusInX, y);
      path.quadraticBezierTo(x + width - radiusOutX, y, x + width - radiusOutX, y + radiusInY);
      // Bottom-left corner
      path.lineTo(x + width - radiusOutX, y + height - radiusOutY);
      path.quadraticBezierTo(x + width - radiusOutX, y + height, x + width, y + height);
  }

  path.close();
  return path;
}

class DockedRoundedCornersBorder extends ShapeBorder {
  final ScreenEdge dockedSide;
  final double radiusInCross;
  final double radiusInMain;
  final double radiusOutCross;
  final double radiusOutMain;
  final bool? isVertical;

  const DockedRoundedCornersBorder({
    required this.dockedSide,
    required this.radiusInCross,
    required this.radiusInMain,
    this.radiusOutCross = 0,
    this.radiusOutMain = 0,
    this.isVertical,
  });

  @override
  EdgeInsetsGeometry get dimensions {
    // can't infer verticality because we don't have size at this point
    if (isVertical == null) return EdgeInsets.zero;
    return EdgeInsets.symmetric(
      vertical: !isVertical! ? 0 : radiusOutMain.coerceAtLeast(0),
      horizontal: isVertical! ? 0 : radiusOutMain.coerceAtLeast(0),
    );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return getDockedRoundCornersPathForDirection(
      dockedSide: dockedSide,
      rect: rect,
      radiusInCross: radiusInCross,
      radiusInMain: radiusInMain,
      radiusOutCross: radiusOutCross,
      radiusOutMain: radiusOutMain,
      isVertical: isVertical,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return DockedRoundedCornersBorder(
      dockedSide: dockedSide,
      radiusInCross: radiusInCross * t,
      radiusInMain: radiusInMain * t,
      radiusOutCross: radiusOutCross * t,
      radiusOutMain: radiusOutMain * t,
      isVertical: isVertical,
    );
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b == null) {
      return super.lerpTo(b, t);
    }
    if (b is DockedRoundedCornersBorder) {
      return null; // defer to lerpFrom of b
    }
    if (b is RoundedRectangleBorder) {
      if (t < 0.5) {
        return DockedRoundedCornersBorder(
          dockedSide: dockedSide,
          radiusInCross: radiusInCross,
          radiusInMain: radiusInMain,
          radiusOutCross: lerpDouble(radiusOutCross, 0, t * 2)!,
          radiusOutMain: lerpDouble(radiusOutMain, 0, t * 2)!,
          isVertical: isVertical,
        );
      } else {
        return b.lerpFrom(_asRoundedRectangleBorder(), (t - 0.5) * 2);
      }
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
    // if dockedSide and isVertical are the same, we can interpolate gracefully
    if (a is DockedRoundedCornersBorder) {
      if (dockedSide == a.dockedSide && isVertical == a.isVertical) {
        return DockedRoundedCornersBorder(
          dockedSide: dockedSide,
          radiusInCross: lerpDouble(a.radiusInCross, radiusInCross, t)!,
          radiusInMain: lerpDouble(a.radiusInMain, radiusInMain, t)!,
          radiusOutCross: lerpDouble(a.radiusOutCross, radiusOutCross, t)!,
          radiusOutMain: lerpDouble(a.radiusOutMain, radiusOutMain, t)!,
          isVertical: isVertical,
        );
      }
      // if dockedSide is different, we default to removing current border and then adding new one
    }
    if (a is RoundedRectangleBorder) {
      if (t < 0.5) {
        return a.lerpTo(_asRoundedRectangleBorder(), t * 2);
      } else {
        return DockedRoundedCornersBorder(
          dockedSide: dockedSide,
          radiusInCross: radiusInCross,
          radiusInMain: radiusInMain,
          radiusOutCross: lerpDouble(0, radiusOutCross, (t - 0.5) * 2)!,
          radiusOutMain: lerpDouble(0, radiusOutMain, (t - 0.5) * 2)!,
          isVertical: isVertical,
        );
      }
    }
    if (t < 0.5) {
      return a.scale(1 - (t * 2));
    }
    return scale((t - 0.5) * 2);
  }

  RoundedRectangleBorder _asRoundedRectangleBorder() {
    return switch (dockedSide) {
      ScreenEdge.top => RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.zero,
          bottom: Radius.elliptical(radiusInMain, radiusInCross),
        ),
      ),
      ScreenEdge.bottom => RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.zero,
          top: Radius.elliptical(radiusInMain, radiusInCross),
        ),
      ),
      ScreenEdge.left => RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.zero,
          right: Radius.elliptical(radiusInCross, radiusInMain),
        ),
      ),
      ScreenEdge.right => RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.zero,
          left: Radius.elliptical(radiusInCross, radiusInMain),
        ),
      ),
    };
  }
}

class DockedRoundedCornersBorderPerc extends ShapeBorder {
  final ScreenEdge dockedSide;
  final double radiusInPercCross;
  final double radiusInPercMain;
  final double radiusOutPercCross;
  final double radiusOutPercMain;
  final bool? isVertical;

  const DockedRoundedCornersBorderPerc({
    required this.dockedSide,
    required this.radiusInPercCross,
    required this.radiusInPercMain,
    this.radiusOutPercCross = 0,
    this.radiusOutPercMain = 0,
    this.isVertical,
  });

  // can't infer dimensions from percentages because we don't have size at this point
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return getDockedRoundCornersPathPercForDirection(
      dockedSide: dockedSide,
      rect: rect,
      radiusInPercCross: radiusInPercCross,
      radiusInPercMain: radiusInPercMain,
      radiusOutPercCross: radiusOutPercCross,
      radiusOutPercMain: radiusOutPercMain,
      isVertical: isVertical,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return DockedRoundedCornersBorderPerc(
      dockedSide: dockedSide,
      radiusInPercCross: radiusInPercCross * t,
      radiusInPercMain: radiusInPercMain * t,
      radiusOutPercCross: radiusOutPercCross * t,
      radiusOutPercMain: radiusOutPercMain * t,
      isVertical: isVertical,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a == null || a is! DockedRoundedCornersBorderPerc) {
      return super.lerpFrom(a, t);
    }
    // if dockedSide and isVertical are the same, we can interpolate gracefully
    if (dockedSide == a.dockedSide && isVertical == a.isVertical) {
      return DockedRoundedCornersBorderPerc(
        dockedSide: dockedSide,
        radiusInPercCross: lerpDouble(a.radiusInPercCross, radiusInPercCross, t)!,
        radiusInPercMain: lerpDouble(a.radiusInPercMain, radiusInPercMain, t)!,
        radiusOutPercCross: lerpDouble(a.radiusOutPercCross, radiusOutPercCross, t)!,
        radiusOutPercMain: lerpDouble(a.radiusOutPercMain, radiusOutPercMain, t)!,
        isVertical: isVertical,
      );
    }
    // if dockedSide is different, we default to removing current border and then adding new one
    if (t < 0.5) {
      return a.scale(1 - (t * 2));
    }
    return scale((t - 0.5) * 2);
  }
}

class DockedRoundedCornersClipper extends CustomClipper<Path> {
  final ScreenEdge dockedSide;
  final double radiusInCross;
  final double radiusInMain;
  final double radiusOutCross;
  final double radiusOutMain;
  final bool? isVertical;

  const DockedRoundedCornersClipper({
    required this.dockedSide,
    required this.radiusInCross,
    required this.radiusInMain,
    this.radiusOutCross = 0,
    this.radiusOutMain = 0,
    this.isVertical,
  });

  @override
  Path getClip(Size size) {
    return getDockedRoundCornersPathForDirection(
      dockedSide: dockedSide,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      radiusInCross: radiusInCross,
      radiusInMain: radiusInMain,
      radiusOutCross: radiusOutCross,
      radiusOutMain: radiusOutMain,
      isVertical: isVertical,
    );
  }

  @override
  bool shouldReclip(covariant DockedRoundedCornersClipper oldClipper) {
    return dockedSide != oldClipper.dockedSide ||
        radiusInCross != oldClipper.radiusInCross ||
        radiusInMain != oldClipper.radiusInMain ||
        radiusOutCross != oldClipper.radiusOutCross ||
        radiusOutMain != oldClipper.radiusOutMain;
  }
}

class DockedRoundedCornersClipperPerc extends CustomClipper<Path> {
  final ScreenEdge dockedSide;
  final double radiusInPercCross;
  final double radiusInPercMain;
  final double radiusOutPercCross;
  final double radiusOutPercMain;
  final bool? isVertical;

  const DockedRoundedCornersClipperPerc({
    required this.dockedSide,
    required this.radiusInPercCross,
    required this.radiusInPercMain,
    this.radiusOutPercCross = 0,
    this.radiusOutPercMain = 0,
    this.isVertical,
  });

  @override
  Path getClip(Size size) {
    return getDockedRoundCornersPathPercForDirection(
      dockedSide: dockedSide,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      radiusInPercCross: radiusInPercCross,
      radiusInPercMain: radiusInPercMain,
      radiusOutPercCross: radiusOutPercCross,
      radiusOutPercMain: radiusOutPercMain,
      isVertical: isVertical,
    );
  }

  @override
  bool shouldReclip(covariant DockedRoundedCornersClipperPerc oldClipper) {
    return dockedSide != oldClipper.dockedSide ||
        radiusInPercCross != oldClipper.radiusInPercCross ||
        radiusInPercMain != oldClipper.radiusInPercMain ||
        radiusOutPercCross != oldClipper.radiusOutPercCross ||
        radiusOutPercMain != oldClipper.radiusOutPercMain;
  }
}
