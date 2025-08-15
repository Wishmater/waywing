import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

class OpacityGradient extends StatelessWidget {
  static const left = 0;
  static const right = 1;
  static const top = 2;
  static const bottom = 3;
  static const horizontal = 4;
  static const vertical = 5;

  final Widget child;
  final int direction;
  final double? size;
  final double? percentage;

  const OpacityGradient({
    required this.child,
    this.direction = vertical,
    double? size,
    this.percentage,
    super.key,
  }) : assert(size == null || percentage == null, "Can't set both a hard size and a percentage."),
       size = size == null && percentage == null ? 16 : size;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return child;
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: direction == top || direction == bottom || direction == vertical
            ? Alignment.topCenter
            : Alignment.centerLeft,
        end: direction == top || direction == bottom || direction == vertical
            ? Alignment.bottomCenter
            : Alignment.centerRight,
        stops: [
          0,
          direction == bottom || direction == right
              ? 0
              : size == null
              ? percentage!
              : size! /
                    (direction == top || direction == bottom || direction == vertical ? bounds.height : bounds.width),
          direction == top || direction == left
              ? 1
              : size == null
              ? 1 - percentage!
              : 1 -
                    size! /
                        (direction == top || direction == bottom || direction == vertical
                            ? bounds.height
                            : bounds.width),
          1,
        ],
        colors: const [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
      ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}

class ScrollOpacityGradient extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;
  final double maxSize;
  final int direction;
  final bool applyAtStart;
  final bool applyAtEnd;

  const ScrollOpacityGradient({
    required this.scrollController,
    required this.child,
    this.maxSize = 16,
    this.direction = OpacityGradient.vertical,
    this.applyAtEnd = true,
    this.applyAtStart = true,
    super.key,
  });

  @override
  ScrollOpacityGradientState createState() => ScrollOpacityGradientState();
}

class ScrollOpacityGradientState extends State<ScrollOpacityGradient> {
  double size1 = 0;
  double size2 = 0;

  @override
  void initState() {
    super.initState();
    _addListener(widget.scrollController);
    _updateScroll();
  }

  @override
  void didUpdateWidget(ScrollOpacityGradient oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _removeListener(oldWidget.scrollController);
      _addListener(widget.scrollController);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _removeListener(widget.scrollController);
  }

  void _addListener(ScrollController scrollController) {
    scrollController.addListener(_updateScroll);
  }

  void _removeListener(ScrollController scrollController) {
    scrollController.removeListener(_updateScroll);
  }

  void _updateScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        double newSize1, newSize2;
        try {
          newSize1 = widget.scrollController.position.pixels.clamp(0, widget.maxSize);
          newSize2 = (widget.scrollController.position.maxScrollExtent - widget.scrollController.position.pixels).clamp(
            0,
            widget.maxSize,
          );
        } catch (e) {
          newSize1 = 0;
          newSize2 = 0;
        }
        if (newSize1 != size1 || newSize2 != size2) {
          setState(() {
            size1 = newSize1;
            size2 = newSize2;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = NotificationListener(
      child: widget.child,
      onNotification: (notification) {
        if (notification is ScrollMetricsNotification || notification is ScrollNotification) {
          _updateScroll();
        }
        return false;
      },
    );
    if (widget.direction == OpacityGradient.horizontal || widget.direction == OpacityGradient.vertical) {
      return OpacityGradient(
        size: widget.applyAtStart ? size1 : 0,
        direction: widget.direction == OpacityGradient.horizontal ? OpacityGradient.left : OpacityGradient.top,
        child: OpacityGradient(
          size: widget.applyAtEnd ? size2 : 0,
          direction: widget.direction == OpacityGradient.horizontal ? OpacityGradient.right : OpacityGradient.bottom,
          child: child,
        ),
      );
    } else {
      return OpacityGradient(
        size: widget.direction == OpacityGradient.left || widget.direction == OpacityGradient.top ? size1 : size2,
        direction: widget.direction,
        child: child,
      );
    }
  }
}
