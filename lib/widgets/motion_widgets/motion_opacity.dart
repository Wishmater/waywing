import "package:flutter/material.dart";
import "package:motor/motor.dart";

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

  @override
  void initState() {
    super.initState();
    opacity = SingleMotionController(
      vsync: this,
      motion: widget.motion,
      initialValue: widget.fromOpacity ?? widget.opacity,
    )..addListener(_onControllerTick);
    if (widget.fromOpacity != null) {
      opacity.animateTo(widget.opacity);
    }
  }

  @override
  void didUpdateWidget(covariant MotionOpacity oldWidget) {
    super.didUpdateWidget(oldWidget);
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
