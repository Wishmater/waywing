import "package:flutter/material.dart";
import "package:waywing/util/state_positioning.dart";

class AnimatedIntrinsicSize extends StatefulWidget {
  final Duration duration;
  final Curve curve;
  final Widget child;
  final Alignment alignment;
  final Clip clipBehavior;
  final bool animateWidth;
  final bool animateHeight;
  final PositioningNotifierController? positioningController;

  const AnimatedIntrinsicSize({
    required this.child,
    required this.duration,
    this.curve = Curves.easeOutCubic,
    this.alignment = Alignment.topLeft,
    this.clipBehavior = Clip.none,
    this.animateWidth = true,
    this.animateHeight = true,
    this.positioningController,
    super.key,
  });

  @override
  State<AnimatedIntrinsicSize> createState() => _AnimatedIntrinsicSizeState();
}

class _AnimatedIntrinsicSizeState extends State<AnimatedIntrinsicSize> {
  late final PositioningNotifierController _statePositioningController = PositioningNotifierController();
  PositioningNotifierController get positioningController =>
      widget.positioningController ?? _statePositioningController;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: ValueListenableBuilder(
          valueListenable: positioningController.sizeNotifier,
          child: widget.child,
          builder: (context, size, child) {
            return AnimatedContainer(
              width: widget.animateWidth ? size?.width : null,
              height: widget.animateHeight ? size?.height : null,
              duration: widget.duration,
              curve: widget.curve,
              child: OverflowBox(
                maxWidth: widget.animateWidth && size != null ? double.infinity : null,
                maxHeight: widget.animateHeight && size != null ? double.infinity : null,
                minWidth: widget.animateWidth && size != null ? 0 : null,
                minHeight: widget.animateHeight && size != null ? 0 : null,
                alignment: widget.alignment,
                child: PositioningNotifierMonitor(
                  controller: positioningController,
                  child: child!,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
