import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/core/config.dart";

typedef MotionTransitionBuilder =
    Widget Function(BuildContext context, Widget child, BoundedSingleMotionController controller);

class Hideable extends StatefulWidget {
  final bool show;
  final TransitionBuilder builder;
  final Widget? child;
  final MotionTransitionBuilder transitionBuilder;

  final Motion? motion;
  final ValueChanged<AnimationStatus>? onAnimationStatusChanged;

  const Hideable({
    required this.show,
    required this.builder,
    this.motion,
    this.transitionBuilder = defaultTransitionBuilder,
    this.onAnimationStatusChanged,
    this.child,
    super.key,
  });

  @override
  State<Hideable> createState() => _HideableState();

  static Widget defaultTransitionBuilder(BuildContext context, Widget child, BoundedSingleMotionController controller) {
    return FadeTransition(
      opacity: controller,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1).animate(controller),
        child: child,
      ),
    );
  }
}

class _HideableState extends State<Hideable> with SingleTickerProviderStateMixin {
  late bool showing = widget.show;
  late final controller = BoundedSingleMotionController(
    vsync: this,
    motion: widget.motion ?? mainConfig.motions.expressive.spatial.normal,
    lowerBound: 0,
    upperBound: 1,
    initialValue: widget.show ? 1 : 0,
  );

  @override
  void initState() {
    super.initState();
    controller.addStatusListener(onAnimationStatusChanged);
  }

  @override
  void dispose() {
    controller.removeStatusListener(onAnimationStatusChanged);
    super.dispose();
  }

  void onAnimationStatusChanged(AnimationStatus status) {
    widget.onAnimationStatusChanged?.call(status);
    final newShowing = controller.isAnimating || controller.value != 0;
    if (newShowing != showing) {
      setState(() {
        showing = newShowing;
      });
    }
  }

  @override
  void didUpdateWidget(covariant Hideable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.motion != oldWidget.motion) {
      controller.motion = widget.motion ?? mainConfig.motions.standard.spatial.normal;
    }
    if (widget.show != oldWidget.show) {
      controller.animateTo(widget.show ? 1 : 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!showing) {
      return SizedBox.shrink();
    }
    Widget result = widget.builder(context, widget.child);
    result = widget.transitionBuilder(context, result, controller);
    return result;
  }
}
