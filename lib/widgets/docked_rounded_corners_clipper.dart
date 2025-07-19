import 'dart:ui';

import 'package:dartx/dartx.dart';
import 'package:fl_linux_window_manager/models/screen_edge.dart';
import 'package:flutter/widgets.dart';

getDockedRoundCornersPathForDirection({
  required ScreenEdge dockedSide,
  required Size size,
  required double radiusInCross,
  required double radiusInMain,
  double radiusOutCross = 0,
  double radiusOutMain = 0,
  bool? isVertical,
}) {
  final double radiusInX, radiusInY, radiusOutX, radiusOutY;
  if (isVertical ?? (size.width < size.height)) {
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
    size: size,
    radiusInX: radiusInX,
    radiusInY: radiusInY,
    radiusOutX: radiusOutX,
    radiusOutY: radiusOutY,
  );
}

getDockedRoundCornersPathPercForDirection({
  required ScreenEdge dockedSide,
  required Size size,
  required double radiusInPercCross,
  required double radiusInPercMain,
  double radiusOutPercCross = 0,
  double radiusOutPercMain = 0,
  bool? isVertical,
}) {
  final width = size.width;
  final height = size.height;
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
    size: size,
    radiusInX: radiusInX,
    radiusInY: radiusInY,
    radiusOutX: radiusOutX,
    radiusOutY: radiusOutY,
  );
}

getDockedRoundCornersPath({
  required ScreenEdge dockedSide,
  required Size size,
  required double radiusInX,
  required double radiusInY,
  double radiusOutX = 0,
  double radiusOutY = 0,
}) {
  final width = size.width;
  final height = size.height;
  final path = Path();

  // do not allow negative values (would probably cause a lot of breakage)
  if (radiusInX < 0) radiusInX = 0;
  if (radiusInY < 0) radiusInY = 0;
  if (radiusOutX < 0) radiusOutX = 0;
  if (radiusOutY < 0) radiusOutY = 0;

  // don't allow radius to exceed size (would probably cause a lot of breakage)
  if (dockedSide == ScreenEdge.left || dockedSide == ScreenEdge.right) {
    // vertical
    if ((radiusInX + radiusOutX) > size.width) {
      final ratio = radiusInX / (radiusInX + radiusOutX);
      radiusInX = size.width * ratio;
      radiusOutX = size.width * (1 - ratio);
    }
    if (radiusInY * 2 > size.height) {
      final ratio = size.height / (radiusInY * 2);
      radiusInY *= ratio;
      radiusOutY *= ratio;
    }
  } else {
    // horizontal
    if (radiusInX * 2 > size.width) {
      final ratio = size.width / (radiusInX * 2);
      radiusInX *= ratio;
      radiusOutX *= ratio;
    }
    if ((radiusInY + radiusOutY) > size.height) {
      final ratio = (radiusInY / (radiusInY + radiusOutY));
      radiusInY = size.height * ratio;
      radiusOutY = size.height * (1 - ratio);
    }
  }

  switch (dockedSide) {
    case ScreenEdge.right:
      // Top-left corner
      path.moveTo(0, radiusInY);
      path.quadraticBezierTo(0, radiusOutY, radiusInX, radiusOutY);
      // Top-right corner
      path.lineTo(width - radiusOutX, radiusOutY);
      path.quadraticBezierTo(width, radiusOutY, width, 0);
      // Bottom-right corner
      path.lineTo(width, height);
      path.quadraticBezierTo(width, height - radiusOutY, width - radiusOutX, height - radiusOutY);
      // Bottom-left corner
      path.lineTo(radiusInX, height - radiusOutY);
      path.quadraticBezierTo(0, height - radiusOutY, 0, height - radiusInY);

    case ScreenEdge.left:
      // Top-left corner
      path.moveTo(0, 0);
      path.quadraticBezierTo(0, radiusOutY, radiusOutX, radiusOutY);
      // Top-right corner
      path.lineTo(width - radiusInX, radiusOutY);
      path.quadraticBezierTo(width, radiusOutY, width, radiusInY);
      // Bottom-right corner
      path.lineTo(width, height - radiusInY);
      path.quadraticBezierTo(width, height - radiusOutY, width - radiusInX, height - radiusOutY);
      // Bottom-left corner
      path.lineTo(radiusOutX, height - radiusOutY);
      path.quadraticBezierTo(0, height - radiusOutY, 0, height);

    case ScreenEdge.top:
      // Top-left corner
      path.moveTo(radiusOutX, radiusOutY);
      path.quadraticBezierTo(radiusOutX, 0, 0, 0);
      // Top-right corner
      path.lineTo(width, 0);
      path.quadraticBezierTo(width - radiusOutX, 0, width - radiusOutX, radiusOutY);
      // Bottom-right corner
      path.lineTo(width - radiusOutX, height - radiusInY);
      path.quadraticBezierTo(width - radiusOutX, height, width - radiusInX, height);
      // Bottom-left corner
      path.lineTo(radiusInX, height);
      path.quadraticBezierTo(radiusOutX, height, radiusOutX, height - radiusInY);

    case ScreenEdge.bottom:
      // Top-left corner
      path.moveTo(0, height);
      path.quadraticBezierTo(radiusOutX, height, radiusOutX, height - radiusOutY);
      // Top-right corner
      path.lineTo(radiusOutX, radiusInY);
      path.quadraticBezierTo(radiusOutX, 0, radiusInX, 0);
      // Bottom-right corner
      path.lineTo(width - radiusInX, 0);
      path.quadraticBezierTo(width - radiusOutX, 0, width - radiusOutX, radiusInY);
      // Bottom-left corner
      path.lineTo(width - radiusOutX, height - radiusOutY);
      path.quadraticBezierTo(width - radiusOutX, height, width, height);
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
    // can't infer verticality because we don'r have size at this point
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
      size: rect.size,
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
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a == null || a is! DockedRoundedCornersBorder) {
      return super.lerpFrom(a, t);
    }
    // if dockedSide and isVertical are the same, we can interpolate gracefully
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
    if (t < 0.5) {
      return scale(1 - (t * 2));
    }
    return a.scale((t - 0.5) * 2);
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
      size: rect.size,
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
      return scale(1 - (t * 2));
    }
    return a.scale((t - 0.5) * 2);
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
      size: size,
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
      size: size,
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
