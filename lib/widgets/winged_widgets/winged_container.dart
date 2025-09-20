import "dart:ui";

import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/animation_utils.dart";
import "package:waywing/widgets/motion_widgets/converters.dart";
import "package:waywing/widgets/motion_widgets/motion_utils.dart";
import "package:waywing/widgets/shapes/docked_rounded_corners_shape.dart";
import "package:waywing/widgets/shapes/shape_clipper.dart";

class WingedContainer extends StatelessWidget {
  final Motion? motion;
  final bool active;
  final ValueChanged<AnimationStatus>? onAnimationStatusChanged;

  final ShapeBorder? shape;

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
    this.fromShape,
    this.elevation = 0,
    this.shadowOffset = const Offset(0.66, 1),
    this.clipBehavior = Clip.none,
    this.color,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _WingedContainer(
      motion: motion ?? mainConfig.motions.expressive.spatial.fast,
      active: active,
      onAnimationStatusChanged: onAnimationStatusChanged,
      shape: shape,
      fromShape: fromShape,
      elevation: elevation,
      shadowOffset: shadowOffset,
      clipBehavior: clipBehavior,
      color: color,
      child: child,
    );
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
      if ((oldShape == null || oldShape is RoundedRectangleBorder)) {
        converter = RoundedRectangleBorderMotionConverter();
      }
    } else if (newShape is DockedRoundedCornersBorder) {
      if (oldShape == null || oldShape is DockedRoundedCornersBorder) {
        // TODO: 1 animations: implement converters for DockedShapePerc
      }
    } else if (newShape is DockedRoundedCornersBorderPerc) {
      if (oldShape == null || oldShape is DockedRoundedCornersBorderPerc) {
        // TODO: 1 animations: implement converters for DockedShapePerc
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
    final elevation = widget.elevation * mainConfig.theme.shadows;
    final offset = widget.shadowOffset * elevation;
    final color = Theme.of(context).shadowColor.withValues(alpha: 0.66);
    return InputRegion(
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.passthrough,
        children: [
          Material(
            shape: shape,
            elevation: 0,
            clipBehavior: widget.clipBehavior,
            color: widget.color,
            animationDuration: Duration.zero,
            child: widget.child,
          ),
          if (shape != null && widget.elevation > 0)
            Positioned.fill(
              child: ClipPath(
                clipper: ShapeClipper(
                  shape: shape,
                  contain: false,
                ),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: widget.elevation,
                    sigmaY: widget.elevation,
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
