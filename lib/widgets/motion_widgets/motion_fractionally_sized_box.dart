import "package:dartx/dartx.dart";
import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/widgets/motion_widgets/motion_utils.dart";

class MotionFractionallySizedBox extends StatefulWidget {
  final Motion motion;
  final bool active;
  final ValueChanged<AnimationStatus>? onAnimationStatusChanged;

  final AlignmentGeometry alignment;
  final double? widthFactor;
  final double? heightFactor;

  final AlignmentGeometry? fromAlignment;
  final double? fromWidthFactor;
  final double? fromHeightFactor;

  final Widget child;

  const MotionFractionallySizedBox({
    required this.motion,
    this.active = true,
    this.onAnimationStatusChanged,
    required this.alignment,
    this.widthFactor,
    this.heightFactor,
    this.fromAlignment,
    this.fromWidthFactor,
    this.fromHeightFactor,
    required this.child,
    super.key,
  });

  @override
  State<MotionFractionallySizedBox> createState() => _MotionFractionallySizedBoxState();
}

class _MotionFractionallySizedBoxState extends State<MotionFractionallySizedBox> with TickerProviderStateMixin {
  late final MotionController<AlignmentGeometry> alignment;
  SingleMotionController? widthFactor;
  SingleMotionController? heightFactor;

  void _onControllerTick() => setState(() {});

  AnimationStatus? _lastStatus;
  void _onControllerStatus(_) {
    if (widget.onAnimationStatusChanged == null) return;
    final status = consolidateAnimationStatus([
      alignment.status,
      widthFactor?.status,
      heightFactor?.status,
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
    alignment = MotionController(
      vsync: this,
      motion: widget.motion,
      converter: AlignmentMotionConverter(),
      initialValue: widget.fromAlignment ?? widget.alignment,
    )..pipe(registerController);
    if (widget.fromAlignment != null) {
      alignment.animateTo(widget.alignment);
    }
    if (widget.widthFactor != null) {
      initWidthFactor(initial: true);
      if (widget.fromWidthFactor != null) {
        widthFactor!.animateTo(widget.widthFactor!);
      }
    }
    if (widget.heightFactor != null) {
      initHeightFactor(initial: true);
      if (widget.fromHeightFactor != null) {
        heightFactor!.animateTo(widget.heightFactor!);
      }
    }
  }

  void initWidthFactor({bool initial = false}) {
    widthFactor = SingleMotionController(
      vsync: this,
      motion: widget.motion,
      initialValue: initial ? (widget.fromWidthFactor ?? widget.widthFactor!) : widget.widthFactor!,
    )..pipe(registerController);
  }

  void initHeightFactor({bool initial = false}) {
    heightFactor = SingleMotionController(
      vsync: this,
      motion: widget.motion,
      initialValue: initial ? (widget.fromHeightFactor ?? widget.heightFactor!) : widget.heightFactor!,
    )..pipe(registerController);
  }

  @override
  void didUpdateWidget(covariant MotionFractionallySizedBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alignment != oldWidget.alignment) {
      alignment.animateTo(widget.alignment);
    }
    if (widget.widthFactor != oldWidget.widthFactor) {
      if (widget.widthFactor == null) {
        widthFactor!.dispose();
        widthFactor = null;
      } else if (oldWidget.widthFactor == null) {
        initWidthFactor();
      } else {
        widthFactor!.animateTo(widget.widthFactor!);
      }
    }
    if (widget.heightFactor != oldWidget.heightFactor) {
      if (widget.heightFactor == null) {
        heightFactor!.dispose();
        heightFactor = null;
      } else if (oldWidget.heightFactor == null) {
        initHeightFactor();
      } else {
        heightFactor!.animateTo(widget.heightFactor!);
      }
    }
  }

  @override
  void dispose() {
    alignment.dispose();
    widthFactor?.dispose();
    heightFactor?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: alignment.value,
      widthFactor: widthFactor?.value.coerceAtLeast(0),
      heightFactor: heightFactor?.value.coerceAtLeast(0),
      child: widget.child,
    );
  }
}
