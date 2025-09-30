import "dart:ui";

import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:motor/motor.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/animation_utils.dart";
import "package:waywing/widgets/motion_widgets/converters.dart";
import "package:waywing/widgets/motion_widgets/motion_utils.dart";
import "package:waywing/widgets/shapes/external_rounded_corners_shape.dart";
import "package:waywing/widgets/shapes/shape_clipper.dart";
import "package:waywing/widgets/winged_widgets/winged_popover_provider.dart";

class WingedContainer extends StatefulWidget {
  final Motion? motion;
  final bool active;
  final ValueChanged<AnimationStatus>? onAnimationStatusChanged;

  final ShapeBorder? shape;
  final GradientBorderSide? activeBorder;
  final GradientBorderSide? inactiveBorder;

  final ShapeBorder? fromShape;

  final double elevation;
  final Offset shadowOffset;
  final Clip clipBehavior;
  final Color? color;
  final Widget? child;

  const WingedContainer({
    this.motion,
    this.active = true,
    this.onAnimationStatusChanged,
    this.shape,
    this.activeBorder,
    this.inactiveBorder,
    this.fromShape,
    this.elevation = 0,
    this.shadowOffset = const Offset(0.66, 1),
    this.clipBehavior = Clip.none,
    this.color,
    this.child,
    super.key,
  });

  @override
  State<WingedContainer> createState() => WingedContainerState();
}

class WingedContainerState extends State<WingedContainer> {
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // TODO: 2 PERFORMANCE don't rebuild on focus change if active/inactive borders are disabled, there are also some things in build method that can be skipped
    focusNode.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    var shape = widget.shape;
    if (shape is ExternalRoundedCornersBorder) {
      shape = shape.copyWith(
        borderSide: focusNode.hasFocus
            ? widget.activeBorder ?? mainConfig.theme.activeBorder
            : widget.inactiveBorder ?? mainConfig.theme.inactiveBorder,
      );
    }
    Widget result = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          final client = context.findAncestorStateOfType<WingedPopoverClientState>();
          if (client != null) {
            client.onEscapePressed();
          } else {
            focusNode.requestFocus();
          }
        },
      },
      child: Focus(
        focusNode: focusNode,
        child: _WingedContainer(
          motion: widget.motion ?? mainConfig.motions.expressive.spatial.slow.multiplySpeed(0.2),
          active: widget.active,
          onAnimationStatusChanged: widget.onAnimationStatusChanged,
          shape: shape,
          fromShape: widget.fromShape,
          elevation: widget.elevation,
          shadowOffset: widget.shadowOffset,
          clipBehavior: widget.clipBehavior,
          color: widget.color,
          usePainter: mainConfig.internalUsePainter,
          child: widget.child,
        ),
      ),
    );
    if (mainConfig.focusContainerOnMouseOver) {
      result = MouseRegion(
        opaque: false,
        onEnter: (_) {
          focusNode.requestFocus();
        },
        onExit: (_) {
          focusNode.unfocus();
        },
        child: result,
      );
    }
    return result;
  }
}

class _WingedContainer extends StatefulWidget {
  final Motion motion;
  final bool active;
  final ValueChanged<AnimationStatus>? onAnimationStatusChanged;

  final ShapeBorder? shape;

  final ShapeBorder? fromShape;

  final double elevation;
  final Offset shadowOffset;
  final Clip clipBehavior;
  final Color? color;
  final Widget? child;

  /// temporary option to use ShapeShadowPainter instead of ShapeShadorClipper
  final bool usePainter;

  const _WingedContainer({
    required this.motion,
    required this.active,
    required this.onAnimationStatusChanged,
    required this.shape,
    required this.fromShape,
    required this.elevation,
    required this.shadowOffset,
    required this.clipBehavior,
    required this.color,
    required this.usePainter,
    required this.child,
  });

  @override
  _WingedContainerState createState() => _WingedContainerState();
}

class _WingedContainerState extends State<_WingedContainer> with TickerProviderStateMixin {
  MotionController<ShapeBorder>? shape;
  BoundedSingleMotionController? shapeManualController;
  Animation<ShapeBorder?>? shapeManual;
  // TODO: 2 color is animated by Theme, but do we need to animate elevation?
  // TODO: 3 Theme animations use normal durations, can we override it to use motion? probably not worth the effort

  void _onControllerTick() => setState(() {});

  AnimationStatus? _lastStatus;
  void _onControllerStatus(_) {
    if (widget.onAnimationStatusChanged == null) return;
    final status = consolidateAnimationStatus([
      shape?.status,
      shapeManualController?.status,
    ]);
    if (status == _lastStatus) return;
    _lastStatus = status;
    widget.onAnimationStatusChanged!(status);
  }

  T registerController<T extends MotionController>(T controller) {
    return controller
      ..addListener(_onControllerTick)
      ..addStatusListener(_onControllerStatus);
  }

  @override
  void initState() {
    super.initState();
    if (widget.shape != null) {
      updateShape(widget.fromShape);
    }
  }

  @override
  void didUpdateWidget(covariant _WingedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        shape?.motion = widget.motion;
        shapeManualController?.motion = widget.motion;
      } else {
        shape?.motion = const InstantMotion();
        shapeManualController?.motion = const InstantMotion();
      }
    }
    if (oldWidget.shape != widget.shape) {
      updateShape(oldWidget.shape);
    }
  }

  void updateShape(ShapeBorder? oldShape) {
    final newShape = widget.shape;
    if (newShape == null) {
      shape?.dispose();
      shape = null;
      shapeManualController?.dispose();
      shapeManualController = null;
      return;
    }

    MotionConverter<ShapeBorder>? converter;
    if (newShape is RoundedRectangleBorder) {
      if (oldShape == null || oldShape is RoundedRectangleBorder) {
        converter = RoundedRectangleBorderMotionConverter();
      }
    } else if (newShape is ExternalRoundedCornersBorder) {
      if (oldShape == null || oldShape is ExternalRoundedCornersBorder) {
        converter = ExternalRoundedCornersBorderMotionConverter();
      }
    }

    if (converter != null) {
      shapeManualController?.dispose();
      shapeManualController = null;
      shape ??= MotionController(
        vsync: this,
        motion: widget.active ? widget.motion : const InstantMotion(),
        converter: converter,
        initialValue: oldShape ?? newShape,
      )..pipe(registerController);
      if (oldShape != null) {
        shape!.animateTo(newShape);
      }
    } else {
      shape?.dispose();
      shape = null;
      shapeManualController ??= BoundedSingleMotionController(
        vsync: this,
        motion: widget.active ? widget.motion : const InstantMotion(),
        initialValue: oldShape != null ? 0 : 1,
      )..pipe(registerController);
      shapeManual = ShapeBorderTween(
        begin: oldShape ?? newShape,
        end: newShape,
      ).animate(shapeManualController!);
      if (oldShape != null) {
        shapeManualController!.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    shape?.dispose();
    shapeManualController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shape = this.shape?.value ?? shapeManual?.value;
    final shapePadding = shape?.dimensions.resolve(TextDirection.ltr) ?? EdgeInsets.zero;
    final shapePaddingRect = RelativeRect.fromLTRB(
      -shapePadding.left,
      -shapePadding.top,
      -shapePadding.right,
      -shapePadding.bottom,
    );
    final elevation = widget.elevation * mainConfig.theme.shadows;
    final offset = widget.shadowOffset * elevation;
    final color = Theme.of(context).shadowColor.withValues(alpha: 0.66);
    return InputRegion(
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.passthrough,
        children: [
          Positioned.fromRelativeRect(
            rect: shapePaddingRect,
            child: Material(
              shape: shape,
              elevation: 0,
              clipBehavior: widget.clipBehavior,
              color: widget.color,
              animationDuration: Duration.zero,
              child: Padding(
                padding: shapePadding,
                child: widget.child,
              ),
            ),
          ),

          // paint shadows
          if (shape != null && elevation > 0)
            Positioned.fromRelativeRect(
              rect: shapePaddingRect,
              child: widget.usePainter
                  ? IgnorePointer(
                      child: CustomPaint(
                        painter: ShapeShadowPainter(
                          shape: shape,
                          elevation: elevation,
                          offset: offset,
                          color: color,
                        ),
                      ),
                    )
                  : ClipPath(
                      clipper: ShapeClipper(
                        shape: shape,
                        contain: false,
                      ),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: elevation,
                          sigmaY: elevation,
                        ),
                        child: ClipPath(
                          clipper: ShapeShadowClipper(
                            shape: shape,
                            offset: offset,
                          ),
                          child: ColoredBox(
                            color: color,
                            child: Transform.translate(
                              offset: offset,
                              child: ColoredBox(
                                color: color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
