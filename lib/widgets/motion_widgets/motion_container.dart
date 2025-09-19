import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/util/animation_utils.dart";
import "package:waywing/widgets/motion_widgets/converters.dart";
import "package:waywing/widgets/motion_widgets/motion_utils.dart";

class MotionContainer extends StatefulWidget {
  final Motion motion;
  final bool active;
  final ValueChanged<AnimationStatus>? onAnimationStatusChanged;

  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;

  final AlignmentGeometry? fromAlignment;
  final EdgeInsetsGeometry? fromPadding;
  final Decoration? fromDecoration;
  final Decoration? fromForegroundDecoration;
  final BoxConstraints? fromConstraints;
  final EdgeInsetsGeometry? fromMargin;
  final Matrix4? fromTransform;
  final AlignmentGeometry? fromTransformAlignment;

  final Clip clipBehavior;

  final Widget? child;

  MotionContainer({
    required this.motion,
    this.active = true,
    this.onAnimationStatusChanged,
    this.alignment,
    this.padding,
    Color? color,
    Decoration? decoration,
    this.foregroundDecoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.fromAlignment,
    this.fromPadding,
    Color? fromColor,
    Decoration? fromDecoration,
    this.fromForegroundDecoration,
    double? fromWidth,
    double? fromHeight,
    BoxConstraints? fromConstraints,
    this.fromMargin,
    this.fromTransform,
    this.fromTransformAlignment,
    this.clipBehavior = Clip.none,
    this.child,
    super.key,
  }) : assert(margin == null || margin.isNonNegative),
       assert(padding == null || padding.isNonNegative),
       assert(decoration == null || decoration.debugAssertIsValid()),
       assert(constraints == null || constraints.debugAssertIsValid()),
       assert(
         color == null || decoration == null,
         "Cannot provide both a color and a decoration\n"
         'The color argument is just a shorthand for "decoration: BoxDecoration(color: color)".',
       ),
       decoration = decoration ?? (color != null ? BoxDecoration(color: color) : null),
       constraints = (width != null || height != null)
           ? constraints?.tighten(width: width, height: height) ?? BoxConstraints.tightFor(width: width, height: height)
           : constraints,
       assert(fromMargin == null || fromMargin.isNonNegative),
       assert(fromPadding == null || fromPadding.isNonNegative),
       assert(fromDecoration == null || fromDecoration.debugAssertIsValid()),
       assert(fromConstraints == null || fromConstraints.debugAssertIsValid()),
       assert(
         fromColor == null || fromDecoration == null,
         "Cannot provide both a fromColor and a fromDecoration\n"
         'The fromColor argument is just a shorthand for "fromDecoration: BoxDecoration(color: fromColor)".',
       ),
       fromDecoration = fromDecoration ?? (fromColor != null ? BoxDecoration(color: fromColor) : null),
       fromConstraints = (fromWidth != null || fromHeight != null)
           ? fromConstraints?.tighten(width: fromWidth, height: fromHeight) ??
                 BoxConstraints.tightFor(width: fromWidth, height: fromHeight)
           : fromConstraints;

  @override
  State<MotionContainer> createState() => _MotionContainerState();
}

class _MotionContainerState extends State<MotionContainer> with TickerProviderStateMixin {
  MotionController<AlignmentGeometry>? alignment;
  MotionController<EdgeInsetsGeometry>? padding;
  BoundedSingleMotionController? decorationController;
  Animation<Decoration>? decoration;
  BoundedSingleMotionController? foregroundDecorationController;
  Animation<Decoration>? foregroundDecoration;
  MotionController<BoxConstraints>? constraints;
  MotionController<EdgeInsetsGeometry>? margin;
  MotionController<Matrix4>? transform;
  MotionController<AlignmentGeometry>? transformAlignment;

  void _onControllerTick() => setState(() {});

  AnimationStatus? _lastStatus;
  void _onControllerStatus(_) {
    if (widget.onAnimationStatusChanged == null) return;
    final status = consolidateAnimationStatus([
      alignment?.status,
      padding?.status,
      decorationController?.status,
      foregroundDecorationController?.status,
      constraints?.status,
      margin?.status,
      transform?.status,
      transformAlignment?.status,
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
    // TODO: 2 if the motion animation vaules are changed in the config, MotionControllers
    // that are already initialized won't be updated and will stay with the old motion
    super.initState();
    if (widget.alignment != null) {
      initAlignment(initial: true);
      if (widget.fromAlignment != null) {
        alignment!.animateTo(widget.alignment!);
      }
    }
    if (widget.padding != null) {
      initPadding(initial: true);
      if (widget.fromPadding != null) {
        padding!.animateTo(widget.padding!);
      }
    }
    if (widget.decoration != null) {
      initDecoration(initial: true);
    }
    if (widget.foregroundDecoration != null) {
      initForegroundDecoration(initial: true);
    }
    if (widget.constraints != null) {
      initConstraints(initial: true);
      if (widget.fromConstraints != null) {
        constraints!.animateTo(widget.constraints!);
      }
    }
    if (widget.margin != null) {
      initMargin(initial: true);
      if (widget.fromMargin != null) {
        margin!.animateTo(widget.margin!);
      }
    }
    if (widget.transform != null) {
      initTransform(initial: true);
      if (widget.fromTransform != null) {
        transform!.animateTo(widget.transform!);
      }
    }
    if (widget.transformAlignment != null) {
      initTransformAlignment(initial: true);
      if (widget.fromTransformAlignment != null) {
        transformAlignment!.animateTo(widget.transformAlignment!);
      }
    }
  }

  void initAlignment({bool initial = false}) {
    alignment = MotionController(
      vsync: this,
      motion: widget.active ? widget.motion : const InstantMotion(),
      converter: AlignmentMotionConverter(),
      initialValue: initial ? (widget.fromAlignment ?? widget.alignment!) : widget.alignment!,
    )..pipe(registerController);
  }

  void initPadding({bool initial = false}) {
    padding = MotionController(
      vsync: this,
      motion: widget.active ? widget.motion : const InstantMotion(),
      converter: EdgeInsetsMotionConverter(),
      initialValue: initial ? (widget.fromPadding ?? widget.padding!) : widget.padding!,
    )..pipe(registerController);
  }

  void initDecoration({bool initial = false}) {
    decorationController = BoundedSingleMotionController(
      vsync: this,
      motion: widget.active ? widget.motion : const InstantMotion(),
      initialValue: widget.fromDecoration != null ? 0 : 1,
    )..pipe(registerController);
    updateDecoration(initial: initial);
  }

  void updateDecoration({bool initial = false}) {
    decoration = DecorationTween(
      begin: (initial ? widget.fromDecoration : decoration?.value) ?? widget.decoration!,
      end: widget.decoration!,
    ).animate(decorationController!);
    if (!initial || widget.fromDecoration != null) {
      decorationController!.forward(from: 0);
    }
  }

  void initForegroundDecoration({bool initial = false}) {
    foregroundDecorationController = BoundedSingleMotionController(
      vsync: this,
      motion: widget.active ? widget.motion : const InstantMotion(),
      initialValue: widget.fromForegroundDecoration != null ? 0 : 1,
    )..pipe(registerController);
    updateForegroundDecoration(initial: initial);
  }

  void updateForegroundDecoration({bool initial = false}) {
    foregroundDecoration = DecorationTween(
      begin: (initial ? widget.fromForegroundDecoration : foregroundDecoration?.value) ?? widget.foregroundDecoration!,
      end: widget.foregroundDecoration!,
    ).animate(foregroundDecorationController!);
    if (!initial || widget.fromForegroundDecoration != null) {
      foregroundDecorationController!.forward(from: 0);
    }
  }

  void initConstraints({bool initial = false}) {
    constraints = MotionController(
      vsync: this,
      motion: widget.active ? widget.motion : const InstantMotion(),
      converter: BoxConstraintsMotionConverter(),
      initialValue: initial ? (widget.fromConstraints ?? widget.constraints!) : widget.constraints!,
    )..pipe(registerController);
  }

  void initMargin({bool initial = false}) {
    margin = MotionController(
      vsync: this,
      motion: widget.active ? widget.motion : const InstantMotion(),
      converter: EdgeInsetsMotionConverter(),
      initialValue: initial ? (widget.fromMargin ?? widget.margin!) : widget.margin!,
    )..pipe(registerController);
  }

  void initTransform({bool initial = false}) {
    transform = MotionController(
      vsync: this,
      motion: widget.active ? widget.motion : const InstantMotion(),
      converter: Matrix4MotionConverter(),
      initialValue: initial ? (widget.fromTransform ?? widget.transform!) : widget.transform!,
    )..pipe(registerController);
  }

  void initTransformAlignment({bool initial = false}) {
    transformAlignment = MotionController(
      vsync: this,
      motion: widget.active ? widget.motion : const InstantMotion(),
      converter: AlignmentMotionConverter(),
      initialValue: initial
          ? (widget.fromTransformAlignment ?? widget.transformAlignment!)
          : widget.transformAlignment!,
    )..pipe(registerController);
  }

  @override
  void didUpdateWidget(covariant MotionContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        alignment?.motion = widget.motion;
        padding?.motion = widget.motion;
        decorationController?.motion = widget.motion;
        foregroundDecorationController?.motion = widget.motion;
        constraints?.motion = widget.motion;
        margin?.motion = widget.motion;
        transform?.motion = widget.motion;
        transformAlignment?.motion = widget.motion;
      } else {
        alignment?.motion = const InstantMotion();
        padding?.motion = const InstantMotion();
        decorationController?.motion = const InstantMotion();
        foregroundDecorationController?.motion = const InstantMotion();
        constraints?.motion = const InstantMotion();
        margin?.motion = const InstantMotion();
        transform?.motion = const InstantMotion();
        transformAlignment?.motion = const InstantMotion();
      }
    }
    if (widget.alignment != oldWidget.alignment) {
      if (widget.alignment == null) {
        alignment!.dispose();
        alignment = null;
      } else if (oldWidget.alignment == null) {
        initAlignment();
      } else {
        alignment!.animateTo(widget.alignment!);
      }
    }
    if (widget.padding != oldWidget.padding) {
      if (widget.padding == null) {
        padding!.dispose();
        padding = null;
      } else if (oldWidget.padding == null) {
        initPadding();
      } else {
        padding!.animateTo(widget.padding!);
      }
    }
    if (widget.decoration != oldWidget.decoration) {
      if (widget.decoration == null) {
        decorationController!.dispose();
        decoration = null;
      } else if (oldWidget.decoration == null) {
        initDecoration();
      } else {
        updateDecoration();
      }
    }
    if (widget.foregroundDecoration != oldWidget.foregroundDecoration) {
      if (widget.foregroundDecoration == null) {
        foregroundDecorationController!.dispose();
        foregroundDecoration = null;
      } else if (oldWidget.foregroundDecoration == null) {
        initForegroundDecoration();
      } else {
        updateForegroundDecoration();
      }
    }
    if (widget.constraints != oldWidget.constraints) {
      if (widget.constraints == null) {
        constraints!.dispose();
        constraints = null;
      } else if (oldWidget.constraints == null) {
        initConstraints();
      } else {
        constraints!.animateTo(widget.constraints!);
      }
    }
    if (widget.margin != oldWidget.margin) {
      if (widget.margin == null) {
        margin!.dispose();
        margin = null;
      } else if (oldWidget.margin == null) {
        initMargin();
      } else {
        margin!.animateTo(widget.margin!);
      }
    }
    if (widget.transform != oldWidget.transform) {
      if (widget.transform == null) {
        transform!.dispose();
        transform = null;
      } else if (oldWidget.transform == null) {
        initTransform();
      } else {
        transform!.animateTo(widget.transform!);
      }
    }
    if (widget.transformAlignment != oldWidget.transformAlignment) {
      if (widget.transformAlignment == null) {
        transformAlignment!.dispose();
        transformAlignment = null;
      } else if (oldWidget.transformAlignment == null) {
        initTransformAlignment();
      } else {
        transformAlignment!.animateTo(widget.transformAlignment!);
      }
    }
  }

  @override
  void dispose() {
    alignment?.dispose();
    padding?.dispose();
    decorationController?.dispose();
    foregroundDecorationController?.dispose();
    constraints?.dispose();
    margin?.dispose();
    transform?.dispose();
    transformAlignment?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment?.value,
      padding: padding?.value,
      decoration: decoration?.value,
      foregroundDecoration: foregroundDecoration?.value,
      constraints: constraints?.value,
      margin: margin?.value,
      transform: transform?.value,
      transformAlignment: transformAlignment?.value,
      clipBehavior: widget.clipBehavior,
      child: widget.child,
    );
  }
}
