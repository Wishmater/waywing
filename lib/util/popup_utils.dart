import "dart:math";

import "package:flutter/widgets.dart";

Offset getPopoverPosition({
  required Alignment anchorAlignment,
  required Alignment popupAlignment,
  required Offset hostPosition,
  required Size hostSize,
  required Size childSize,
  required Size screenSize,
  Offset offsetCorrection = Offset.zero,
  EdgeInsets padding = EdgeInsets.zero,
}) {
  const animationValue = 1; // probably not needed in this project
  final maxWidth = screenSize.width - padding.horizontal;
  final maxWidthWithPaddingLeft = maxWidth + padding.left;
  final maxHeight = screenSize.height - padding.vertical;
  final maxHeightWithPaddingTop = maxHeight + padding.top;
  final popupWidth = childSize.width; // ??? should this be childConstraints.maxWidth ???
  double currentChildWidth = popupWidth * animationValue;
  double currentChildHeight = childSize.height * animationValue;
  double x;
  double y;
  x = hostPosition.dx
      + hostSize.width*((anchorAlignment.x+1)/2)
      - popupWidth*((popupAlignment.x-1)/-2)
      + offsetCorrection.dx;
  y = hostPosition.dy
      + hostSize.height*((anchorAlignment.y+1)/2)
      - childSize.height*((popupAlignment.y-1)/-2)
      + offsetCorrection.dy;
  x = x.clamp(padding.left, maxWidthWithPaddingLeft);
  y = y.clamp(padding.top, maxHeightWithPaddingTop);
  if (maxWidthWithPaddingLeft-x < popupWidth) {
    x = maxWidthWithPaddingLeft - popupWidth;
  }
  if (maxHeightWithPaddingTop-y < childSize.height) {
    y = maxHeightWithPaddingTop - childSize.height;
  }
  final overlappingWidth = Rectangle(hostPosition.dx, 0, hostSize.width, 1)
      .intersection(Rectangle(x, 0, popupWidth, 1))?.width.toDouble() ?? 0;
  final overlappingHeight = Rectangle(0, hostPosition.dy, 1, hostSize.height)
      .intersection(Rectangle(0, y, 1, childSize.height))?.height.toDouble() ?? 0;
  currentChildWidth = overlappingWidth + ((popupWidth-overlappingWidth) * animationValue);
  currentChildHeight = overlappingHeight + ((childSize.height-overlappingHeight) * animationValue);
  final overlappingCorrectionX = (x < hostPosition.dx  // add offsetCorrection only if not already accounted for in overlappingMeassure
      ? x - hostPosition.dx
      : x - (hostPosition.dx + hostSize.width)).smartClamp(0, offsetCorrection.dx);
  final overlappingCorrectionY = (y < hostPosition.dy  // add offsetCorrection only if not already accounted for in overlappingMeassure
      ? y - hostPosition.dy
      : y - (hostPosition.dy + hostSize.height)).smartClamp(0, offsetCorrection.dy);
  if (overlappingWidth >= hostSize.width) {
    x = hostPosition.dx - ((currentChildWidth-hostSize.width) * ((popupAlignment.x-1)/-2));
  } else if (hostPosition.dx < x) {
    x = hostPosition.dx + hostSize.width - overlappingWidth;
  } else {
    x = hostPosition.dx - ((currentChildWidth-overlappingWidth) * ((popupAlignment.x-1)/-2));
  }
  if (overlappingHeight >= hostSize.height) {
    y = hostPosition.dy - ((currentChildHeight-hostSize.height) * ((popupAlignment.y-1)/-2));
  } else if (hostPosition.dy < y) {
    y = hostPosition.dy + hostSize.height - overlappingHeight;
  } else {
    y = hostPosition.dy - ((currentChildHeight-overlappingHeight) * ((popupAlignment.y-1)/-2));
  }
  x = (x + overlappingCorrectionX).clamp(padding.left, maxWidthWithPaddingLeft);
  y = (y + overlappingCorrectionY).clamp(padding.top, maxHeightWithPaddingTop);
  if (maxWidthWithPaddingLeft-x < currentChildWidth) {
    x = (maxWidthWithPaddingLeft - currentChildWidth).clamp(padding.left, maxWidthWithPaddingLeft);
  }
  if (maxHeightWithPaddingTop-y < currentChildHeight) {
    y = (maxHeightWithPaddingTop - currentChildHeight).clamp(padding.top, maxHeightWithPaddingTop);
  }
  return Offset(x, y);
}


extension SmartClamp on double {
  num smartClamp(double x, double y) {
    return x<y ? clamp(x, y) : clamp(y, x);
  }
}
