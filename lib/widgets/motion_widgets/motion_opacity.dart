import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/util/animation_utils.dart";
import "package:waywing/widgets/motion_widgets/motion_utils.dart";

class MotionOpacity extends StatefulWidget {
  final Motion motion;
  final bool active;
  final ValueChanged<AnimationStatus>? onAnimationStatusChanged;

  final double opacity;

  final double? fromOpacity;

  final Widget child;

  const MotionOpacity({
    required this.motion,
    this.active = true,
    this.onAnimationStatusChanged,
    required this.opacity,
    this.fromOpacity,
    required this.child,
    super.key,
  });

  @override
  State<MotionOpacity> createState() => _MotionOpacityState();
}

class _MotionOpacityState extends State<MotionOpacity> with TickerProviderStateMixin {
  late final SingleMotionController opacity;

  void _onControllerTick() => setState(() {});

  // AnimationStatus? _lastStatus;
  void _onControllerStatus(status) {
    if (widget.onAnimationStatusChanged == null) return;
    // final status = consolidateAnimationStatus([
    //   opacity.status,
    // ]);
    // if (status == _lastStatus) return;
    // _lastStatus = status;
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
    opacity = SingleMotionController(
      vsync: this,
      motion: widget.active ? widget.motion : const InstantMotion(),
      initialValue: widget.fromOpacity ?? widget.opacity,
    )..pipe(registerController);
    if (widget.fromOpacity != null) {
      opacity.animateTo(widget.opacity);
    }
  }

  @override
  void didUpdateWidget(covariant MotionOpacity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        opacity.motion = widget.motion;
      } else {
        opacity.motion = const InstantMotion();
      }
    }
    if (widget.opacity != oldWidget.opacity) {
      opacity.animateTo(widget.opacity);
    }
  }

  @override
  void dispose() {
    opacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.value.clamp(0, 1),
      child: widget.child,
    );
  }
}
