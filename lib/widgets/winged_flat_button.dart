import 'package:flutter/material.dart';
import 'package:waywing/core/config.dart';

class WingedFlatButton extends StatelessWidget {
  final Widget child;

  /// Called when the user taps this part of the material.
  final GestureTapCallback? onTap;

  /// Called when the user taps down this part of the material.
  final GestureTapDownCallback? onTapDown;

  /// Called when the user releases a tap that was started on this part of the
  /// material. [onTap] is called immediately after.
  final GestureTapUpCallback? onTapUp;

  /// Called when the user cancels a tap that was started on this part of the
  /// material.
  final GestureTapCallback? onTapCancel;

  /// Called when the user double taps this part of the material.
  final GestureTapCallback? onDoubleTap;

  /// Called when the user long-presses on this part of the material.
  final GestureLongPressCallback? onLongPress;

  /// Called when the user taps this part of the material with a secondary button.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  final GestureTapCallback? onSecondaryTap;

  /// Called when the user taps down on this part of the material with a
  /// secondary button.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  final GestureTapDownCallback? onSecondaryTapDown;

  /// Called when the user releases a secondary button tap that was started on
  /// this part of the material. [onSecondaryTap] is called immediately after.
  ///
  /// See also:
  ///
  ///  * [onSecondaryTap], a handler triggered right after this one that doesn't
  ///    pass any details about the tap.
  ///  * [kSecondaryButton], the button this callback responds to.
  final GestureTapUpCallback? onSecondaryTapUp;

  /// Called when the user cancels a secondary button tap that was started on
  /// this part of the material.
  ///
  /// See also:
  ///
  ///  * [kSecondaryButton], the button this callback responds to.
  final GestureTapCallback? onSecondaryTapCancel;

  /// Called when a pointer enters or exits the ink response area.
  ///
  /// The value passed to the callback is true if a pointer has entered this
  /// part of the material and false if a pointer has exited this part of the
  /// material.
  final ValueChanged<bool>? onHover;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [WidgetStateMouseCursor],
  /// [WidgetStateProperty.resolve] is used for the following [WidgetState]s:
  ///
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.focused].
  ///  * [WidgetState.disabled].
  ///
  /// If this property is null, [WidgetStateMouseCursor.clickable] will be used.
  final MouseCursor? mouseCursor;

  /// Whether this ink response should be clipped its bounds.
  ///
  /// This flag also controls whether the splash migrates to the center of the
  /// [InkResponse] or not. If [containedInkWell] is true, the splash remains
  /// centered around the tap location. If it is false, the splash migrates to
  /// the center of the [InkResponse] as it grows.
  ///
  /// See also:
  ///
  ///  * [highlightShape], the shape of the focus, hover, and pressed
  ///    highlights.
  ///  * [borderRadius], which controls the corners when the box is a rectangle.
  ///  * [getRectCallback], which controls the size and position of the box when
  ///    it is a rectangle.
  final bool containedInkWell;

  /// The radius of the ink splash.
  ///
  /// Splashes grow up to this size. By default, this size is determined from
  /// the size of the rectangle provided by [getRectCallback], or the size of
  /// the [InkResponse] itself.
  ///
  /// See also:
  ///
  ///  * [splashColor], the color of the splash.
  ///  * [splashFactory], which defines the appearance of the splash.
  final double? radius;

  /// The border radius of the containing rectangle. This is effective only if
  /// [highlightShape] is [BoxShape.rectangle].
  ///
  /// If this is null, it is interpreted as [BorderRadius.zero].
  final BorderRadius? borderRadius;

  const WingedFlatButton({
    required this.child,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.onSecondaryTapUp,
    this.onSecondaryTapDown,
    this.onSecondaryTapCancel,
    this.onHover,
    this.mouseCursor,
    this.containedInkWell = false,
    this.radius,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var borderRadius = this.borderRadius;
    if (borderRadius == null) {
      // TODO: 1 add these (and maybe other) commonly used values to config
      final radiusX = config.barRadiusInCross * 0.5;
      final radiusY = config.barRadiusInMain * 0.5;
      borderRadius = BorderRadius.all(Radius.elliptical(radiusX, radiusY));
    }
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      hoverDuration: config.animationDuration * 0.5,
      borderRadius: borderRadius,
      child: child, // ignore: sort_child_properties_last
      // properties just passed to InkResponse as-is
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onSecondaryTap: onSecondaryTap,
      onSecondaryTapUp: onSecondaryTapUp,
      onSecondaryTapDown: onSecondaryTapDown,
      onSecondaryTapCancel: onSecondaryTapCancel,
      onHover: onHover,
      mouseCursor: mouseCursor,
      containedInkWell: containedInkWell,
      radius: radius,
    );
  }
}
