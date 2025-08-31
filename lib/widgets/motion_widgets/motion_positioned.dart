import "package:flutter/material.dart";
import "package:motor/motor.dart";

class MotionPositioned extends StatefulWidget {
  final Motion motion;
  final bool active;
  final ValueChanged<AnimationStatus>? onAnimationStatusChanged;

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;

  final double? fromLeft;
  final double? fromTop;
  final double? fromRight;
  final double? fromBottom;
  final double? fromWidth;
  final double? fromHeight;

  final Widget child;

  const MotionPositioned({
    required this.motion,
    this.active = true,
    this.onAnimationStatusChanged,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.fromLeft,
    this.fromTop,
    this.fromRight,
    this.fromBottom,
    this.fromWidth,
    this.fromHeight,
    required this.child,
    super.key,
  });

  MotionPositioned.fromRect({
    required this.motion,
    this.active = true,
    this.onAnimationStatusChanged,
    required Rect rect,
    Rect? fromRect,
    required this.child,
    super.key,
  }) : left = rect.left,
       top = rect.top,
       width = rect.width,
       height = rect.height,
       right = null,
       bottom = null,
       fromLeft = fromRect?.left,
       fromTop = fromRect?.top,
       fromWidth = fromRect?.width,
       fromHeight = fromRect?.height,
       fromRight = null,
       fromBottom = null;

  @override
  State<MotionPositioned> createState() => _MotionPositionedState();
}

class _MotionPositionedState extends State<MotionPositioned> with TickerProviderStateMixin {
  SingleMotionController? left;
  SingleMotionController? top;
  SingleMotionController? right;
  SingleMotionController? bottom;
  SingleMotionController? width;
  SingleMotionController? height;

  void _onControllerTick() => setState(() {});

  @override
  void initState() {
    super.initState();
    if (widget.left != null) {
      initLeft(initial: true);
      if (widget.fromLeft != null) {
        left!.animateTo(widget.left!);
      }
    }
    if (widget.top != null) {
      initTop(initial: true);
      if (widget.fromTop != null) {
        top!.animateTo(widget.top!);
      }
    }
    if (widget.right != null) {
      initRight(initial: true);
      if (widget.fromRight != null) {
        right!.animateTo(widget.right!);
      }
    }
    if (widget.bottom != null) {
      initBottom(initial: true);
      if (widget.fromBottom != null) {
        bottom!.animateTo(widget.bottom!);
      }
    }
    if (widget.width != null) {
      initWidth(initial: true);
      if (widget.fromWidth != null) {
        width!.animateTo(widget.width!);
      }
    }
    if (widget.height != null) {
      initHeight(initial: true);
      if (widget.fromHeight != null) {
        height!.animateTo(widget.height!);
      }
    }
  }

  void initLeft({bool initial = false}) {
    left = SingleMotionController(
      vsync: this,
      motion: widget.motion,
      initialValue: initial ? (widget.fromLeft ?? widget.left!) : widget.left!,
    )..addListener(_onControllerTick);
  }

  void initTop({bool initial = false}) {
    top = SingleMotionController(
      vsync: this,
      motion: widget.motion,
      initialValue: initial ? (widget.fromTop ?? widget.top!) : widget.top!,
    )..addListener(_onControllerTick);
  }

  void initRight({bool initial = false}) {
    right = SingleMotionController(
      vsync: this,
      motion: widget.motion,
      initialValue: initial ? (widget.fromRight ?? widget.right!) : widget.right!,
    )..addListener(_onControllerTick);
  }

  void initBottom({bool initial = false}) {
    bottom = SingleMotionController(
      vsync: this,
      motion: widget.motion,
      initialValue: initial ? (widget.fromBottom ?? widget.bottom!) : widget.bottom!,
    )..addListener(_onControllerTick);
  }

  void initWidth({bool initial = false}) {
    width = SingleMotionController(
      vsync: this,
      motion: widget.motion,
      initialValue: initial ? (widget.fromWidth ?? widget.width!) : widget.width!,
    )..addListener(_onControllerTick);
  }

  void initHeight({bool initial = false}) {
    height = SingleMotionController(
      vsync: this,
      motion: widget.motion,
      initialValue: initial ? (widget.fromHeight ?? widget.height!) : widget.height!,
    )..addListener(_onControllerTick);
  }

  @override
  void didUpdateWidget(covariant MotionPositioned oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.left != oldWidget.left) {
      if (widget.left == null) {
        left!.dispose();
        left = null;
      } else if (oldWidget.left == null) {
        initLeft();
      } else {
        left!.animateTo(widget.left!);
      }
    }
    if (widget.top != oldWidget.top) {
      if (widget.top == null) {
        top!.dispose();
        top = null;
      } else if (oldWidget.top == null) {
        initTop();
      } else {
        top!.animateTo(widget.top!);
      }
    }
    if (widget.right != oldWidget.right) {
      if (widget.right == null) {
        right!.dispose();
        right = null;
      } else if (oldWidget.right == null) {
        initRight();
      } else {
        right!.animateTo(widget.right!);
      }
    }
    if (widget.bottom != oldWidget.bottom) {
      if (widget.bottom == null) {
        bottom!.dispose();
        bottom = null;
      } else if (oldWidget.bottom == null) {
        initBottom();
      } else {
        bottom!.animateTo(widget.bottom!);
      }
    }
    if (widget.width != oldWidget.width) {
      if (widget.width == null) {
        width!.dispose();
        width = null;
      } else if (oldWidget.width == null) {
        initWidth();
      } else {
        width!.animateTo(widget.width!);
      }
    }
    if (widget.height != oldWidget.height) {
      if (widget.height == null) {
        height!.dispose();
        height = null;
      } else if (oldWidget.height == null) {
        initHeight();
      } else {
        height!.animateTo(widget.height!);
      }
    }
  }

  @override
  void dispose() {
    left?.dispose();
    top?.dispose();
    right?.dispose();
    bottom?.dispose();
    width?.dispose();
    height?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left?.value,
      top: top?.value,
      right: right?.value,
      bottom: bottom?.value,
      width: width?.value,
      height: height?.value,
      child: widget.child,
    );
  }
}
