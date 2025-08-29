import "package:dartx/dartx_io.dart";
import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/util/state_positioning.dart";

class AnimatedIntrinsicSize extends StatefulWidget {
  final Motion motion;
  final Widget child;
  final Alignment alignment;
  final Clip clipBehavior;
  final bool animateWidth;
  final bool animateHeight;
  final Size? from;
  final PositioningNotifierController? positioningController;

  const AnimatedIntrinsicSize({
    required this.child,
    required this.motion,
    this.alignment = Alignment.topLeft,
    this.clipBehavior = Clip.none,
    this.animateWidth = true,
    this.animateHeight = true,
    this.from,
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

  late bool isActive = widget.from != null; // hack to prevent animationg from zero on first size change

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: ValueListenableBuilder(
          valueListenable: positioningController.sizeNotifier,
          child: widget.child,
          builder: (context, size, child) {
            final hasSize = size != null;
            if (!isActive && hasSize) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  isActive = true; // hack to prevent animationg from zero on first size change
                });
              });
            }
            return MotionBuilder(
              motion: widget.motion,
              value: size ?? Size.zero,
              active: isActive,
              converter: SizeMotionConverter(),
              builder: (context, size, child) {
                return SizedBox(
                  width: widget.animateWidth && hasSize ? size.width.coerceAtLeast(0) : null,
                  height: widget.animateHeight && hasSize ? size.height.coerceAtLeast(0) : null,
                  child: child,
                );
              },
              child: OverflowBox(
                maxWidth: widget.animateWidth && hasSize ? double.infinity : null,
                maxHeight: widget.animateHeight && hasSize ? double.infinity : null,
                minWidth: widget.animateWidth && hasSize ? 0 : null,
                minHeight: widget.animateHeight && hasSize ? 0 : null,
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
