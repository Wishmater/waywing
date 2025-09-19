import "package:dartx/dartx.dart";
import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/util/animation_utils.dart";
import "package:waywing/util/math_utils.dart";
import "package:waywing/widgets/motion_widgets/motion_utils.dart";

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

  final double? minLeft;
  final double? minTop;
  final double? minRight;
  final double? minBottom;
  final double? minWidth;
  final double? minHeight;
  final double? maxLeft;
  final double? maxTop;
  final double? maxRight;
  final double? maxBottom;
  final double? maxWidth;
  final double? maxHeight;

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
    this.minLeft,
    this.minTop,
    this.minRight,
    this.minBottom,
    this.minWidth,
    this.minHeight,
    this.maxLeft,
    this.maxTop,
    this.maxRight,
    this.maxBottom,
    this.maxWidth,
    this.maxHeight,
    required this.child,
    super.key,
  });

  MotionPositioned.fromRect({
    required this.motion,
    this.active = true,
    this.onAnimationStatusChanged,
    required Rect rect,
    Rect? fromRect,
    Rect? minRect,
    Rect? maxRect,
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
       fromBottom = null,
       minLeft = minRect?.left,
       minTop = minRect?.top,
       minWidth = minRect?.width,
       minHeight = minRect?.height,
       minRight = null,
       minBottom = null,
       maxLeft = maxRect?.left,
       maxTop = maxRect?.top,
       maxWidth = maxRect?.width,
       maxHeight = maxRect?.height,
       maxRight = null,
       maxBottom = null;

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

  AnimationStatus? _lastStatus;
  void _onControllerStatus(_) {
    if (widget.onAnimationStatusChanged == null) return;
    final status = consolidateAnimationStatus([
      left?.status,
      top?.status,
      right?.status,
      bottom?.status,
      width?.status,
      height?.status,
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
      motion: widget.active ? widget.motion : const InstantMotion(),
      initialValue: initial ? (widget.fromLeft ?? widget.left!) : widget.left!,
    )..pipe(registerController);
  }

  void initTop({bool initial = false}) {
    top = SingleMotionController(
      vsync: this,
      motion: widget.active ? widget.motion : const InstantMotion(),
      initialValue: initial ? (widget.fromTop ?? widget.top!) : widget.top!,
    )..pipe(registerController);
  }

  void initRight({bool initial = false}) {
    right = SingleMotionController(
      vsync: this,
      motion: widget.active ? widget.motion : const InstantMotion(),
      initialValue: initial ? (widget.fromRight ?? widget.right!) : widget.right!,
    )..pipe(registerController);
  }

  void initBottom({bool initial = false}) {
    bottom = SingleMotionController(
      vsync: this,
      motion: widget.active ? widget.motion : const InstantMotion(),
      initialValue: initial ? (widget.fromBottom ?? widget.bottom!) : widget.bottom!,
    )..pipe(registerController);
  }

  void initWidth({bool initial = false}) {
    width = SingleMotionController(
      vsync: this,
      motion: widget.active ? widget.motion : const InstantMotion(),
      initialValue: initial ? (widget.fromWidth ?? widget.width!) : widget.width!,
    )..pipe(registerController);
  }

  void initHeight({bool initial = false}) {
    height = SingleMotionController(
      vsync: this,
      motion: widget.active ? widget.motion : const InstantMotion(),
      initialValue: initial ? (widget.fromHeight ?? widget.height!) : widget.height!,
    )..pipe(registerController);
  }

  @override
  void didUpdateWidget(covariant MotionPositioned oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        left?.motion = widget.motion;
        top?.motion = widget.motion;
        right?.motion = widget.motion;
        bottom?.motion = widget.motion;
        width?.motion = widget.motion;
        height?.motion = widget.motion;
      } else {
        left?.motion = const InstantMotion();
        top?.motion = const InstantMotion();
        right?.motion = const InstantMotion();
        bottom?.motion = const InstantMotion();
        width?.motion = const InstantMotion();
        height?.motion = const InstantMotion();
      }
    }
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
      left: left?.value.clampNullable(widget.minLeft, widget.maxLeft),
      top: top?.value.clampNullable(widget.minTop, widget.maxTop),
      right: right?.value.clampNullable(widget.minRight, widget.maxRight),
      bottom: bottom?.value.clampNullable(widget.minBottom, widget.maxBottom),
      width: width?.value.clampNullable(minWidth, widget.maxWidth),
      height: height?.value.clampNullable(minHeight, widget.maxHeight),
      child: widget.child,
    );
  }

  double? get minWidth {
    if (widget.minWidth != null) return widget.minWidth!;
    if (widget.minRight != null && left?.value != null) {
      return (widget.minRight! - left!.value).coerceAtLeast(0);
    }
    return null;
  }

  double? get minHeight {
    if (widget.minHeight != null) return widget.minHeight!;
    if (widget.minBottom != null && top?.value != null) {
      return (widget.minBottom! - top!.value).coerceAtLeast(0);
    }
    return null;
  }
}
