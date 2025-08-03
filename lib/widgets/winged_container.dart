import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:waywing/core/config.dart";

class WingedContainer extends StatelessWidget {
  final Widget? child;
  final ShapeBorder? shape;
  final double elevation;
  final Curve? animationCurve;
  final Duration? animationDuration;
  final Clip clipBehavior;

  const WingedContainer({
    this.shape,
    this.elevation = 0,
    this.child,
    this.animationCurve,
    this.animationDuration,
    this.clipBehavior = Clip.none,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _WingedContainer(
      shape: shape,
      elevation: elevation,
      curve: animationCurve ?? config.animationCurve,
      duration: animationDuration ?? config.animationDuration * 0.8,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

class _WingedContainer extends ImplicitlyAnimatedWidget {
  final Widget? child;
  final ShapeBorder? shape;
  final double elevation;
  final Clip clipBehavior;

  const _WingedContainer({
    required this.shape,
    required this.elevation,
    required this.child,
    required this.clipBehavior,
    required super.curve,
    required super.duration,
  });

  @override
  _WingedContainerState createState() => _WingedContainerState();
}

class _WingedContainerState extends AnimatedWidgetBaseState<_WingedContainer> {
  ShapeBorderTween? _shape;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _shape =
        visitor(
              _shape,
              widget.shape,
              (dynamic value) => ShapeBorderTween(begin: value as ShapeBorder),
            )
            as ShapeBorderTween?;
  }

  @override
  Widget build(BuildContext context) {
    return InputRegion(
      child: Material(
        shape: _shape!.evaluate(animation)!,
        elevation: widget.elevation,
        clipBehavior: widget.clipBehavior,
        animationDuration: Duration.zero,
        child: widget.child,
      ),
    );
  }
}
