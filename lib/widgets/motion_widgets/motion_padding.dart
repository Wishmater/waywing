import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/widgets/motion_widgets/converters.dart";

class MotionPadding extends StatefulWidget {
  final Motion motion;
  final bool active;
  final ValueChanged<AnimationStatus>? onAnimationStatusChanged;

  final EdgeInsetsGeometry padding;

  final EdgeInsetsGeometry? fromPadding;

  final Widget? child;

  const MotionPadding({
    required this.motion,
    this.active = true,
    this.onAnimationStatusChanged,
    required this.padding,
    this.fromPadding,
    this.child,
    super.key,
  });

  @override
  State<MotionPadding> createState() => _MotionPaddingState();
}

class _MotionPaddingState extends State<MotionPadding> with TickerProviderStateMixin {
  late final MotionController<EdgeInsetsGeometry> padding;

  void _onControllerTick() => setState(() {});

  @override
  void initState() {
    super.initState();
    padding = MotionController(
      vsync: this,
      motion: widget.motion,
      converter: EdgeInsetsMotionConverter(),
      initialValue: widget.fromPadding ?? widget.padding,
    )..addListener(_onControllerTick);
    if (widget.fromPadding != null) {
      padding.animateTo(widget.padding);
    }
  }

  @override
  void didUpdateWidget(covariant MotionPadding oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.padding != oldWidget.padding) {
      padding.animateTo(widget.padding);
    }
  }

  @override
  void dispose() {
    padding.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding.value.clamp(EdgeInsets.zero, const EdgeInsets.all(double.infinity)),
      child: widget.child,
    );
  }
}
