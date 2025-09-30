import "dart:async";

import "package:flutter/material.dart";
import "package:waywing/core/config.dart";

class WingedButton<T> extends StatefulWidget {
  final Widget child;

  final Widget Function(BuildContext context, AsyncSnapshot<T?> snapshot, Widget child)? builder;

  final EdgeInsets? padding;

  final BoxConstraints constraints;

  final Alignment? alignment;

  /// Called when the user taps this part of the material.
  final FutureOr<T>? Function()? onTap;

  final Future<T>? initialFuture;

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

  /// If set then a background color will be used
  final Color? color;

  final Clip clipBehavior;

  const WingedButton({
    required this.child,
    this.builder,
    this.padding,
    this.constraints = const BoxConstraints(minWidth: 38, minHeight: 38),
    this.alignment = Alignment.center,
    this.onTap,
    this.initialFuture,
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
    this.clipBehavior = Clip.hardEdge,
    this.color,
    super.key,
  });

  @override
  State<WingedButton> createState() => _WingedButtonState<T>();
}

class _WingedButtonState<T> extends State<WingedButton<T>> {
  late Future<T?> taskFuture = widget.initialFuture ?? Future.value(null);
  final FocusNode focusNode = FocusNode();

  void maybeRequestFocus() {
    final focusScope = FocusScope.of(context, createDependency: false);
    if (focusScope.hasFocus && !focusScope.hasPrimaryFocus) {
      focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: taskFuture,
      builder: (context, snapshot) {
        var borderRadius = widget.borderRadius;
        borderRadius ??= BorderRadius.all(Radius.circular(mainConfig.theme.buttonRounding));
        final Widget child;
        if (widget.builder == null) {
          child = widget.child;
        } else {
          child = widget.builder!(context, snapshot, widget.child);
        }

        return InkResponse(
          focusNode: focusNode,
          highlightShape: BoxShape.rectangle,
          // TODO: 2 remove default inkwell hover effect and implement our own (with blackjack and hookers)
          hoverDuration: mainConfig.animationEnable ? Duration(milliseconds: 200) : Duration.zero,
          // hoverColor: Colors.transparent,
          borderRadius: borderRadius,
          onTap: widget.onTap == null || snapshot.connectionState != ConnectionState.done
              ? null
              : () {
                  maybeRequestFocus();
                  final result = widget.onTap!();
                  if (result is Future<T>) {
                    setState(() {
                      taskFuture = result;
                    });
                  }
                },
          // ignore: sort_child_properties_last
          child: Container(
            padding: widget.padding ?? Theme.of(context).buttonTheme.padding,
            constraints: widget.constraints,
            alignment: widget.alignment,
            clipBehavior: widget.clipBehavior,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: widget.color,
            ),
            child: child,
          ),
          // properties just passed to InkResponse as-is
          containedInkWell: widget.containedInkWell,
          onHover: widget.onHover,
          mouseCursor: widget.mouseCursor,
          radius: widget.radius,
          onTapDown: widget.onTapDown,
          onTapUp: widget.onTapUp,
          onTapCancel: widget.onTapCancel,
          onDoubleTap: widget.onDoubleTap == null
              ? null
              : () {
                  maybeRequestFocus();
                  widget.onDoubleTap!();
                },
          onLongPress: widget.onLongPress == null
              ? null
              : () {
                  maybeRequestFocus();
                  widget.onLongPress!();
                },
          onSecondaryTap: widget.onSecondaryTap == null
              ? null
              : () {
                  maybeRequestFocus();
                  widget.onSecondaryTap!();
                },
          onSecondaryTapUp: widget.onSecondaryTapUp,
          onSecondaryTapDown: widget.onSecondaryTapDown,
          onSecondaryTapCancel: widget.onSecondaryTapCancel,
        );
      },
    );
  }
}
