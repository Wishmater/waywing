import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/widgets/motion_widgets/converters.dart";

class MotionDivider extends StatefulWidget {
  final Motion motion;
  final bool active;
  final ValueChanged<AnimationStatus>? onAnimationStatusChanged;

  final double? size;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final BorderRadiusGeometry? radius;
  final Color? color;

  final double? fromSize;
  final double? fromThickness;
  final double? fromIndent;
  final double? fromEndIndent;
  final BorderRadiusGeometry? fromRadius;
  final Color? fromColor;

  final bool isVertical;

  const MotionDivider({
    required this.motion,
    this.active = true,
    this.onAnimationStatusChanged,
    this.size,
    this.thickness,
    this.indent,
    this.endIndent,
    this.radius,
    this.color,
    this.fromSize,
    this.fromThickness,
    this.fromIndent,
    this.fromEndIndent,
    this.fromRadius,
    this.fromColor,
    required this.isVertical,
    super.key,
  });

  const MotionDivider.horizontal({
    required this.motion,
    this.active = true,
    this.onAnimationStatusChanged,
    double? height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.radius,
    this.color,
    double? fromHeight,
    this.fromThickness,
    this.fromIndent,
    this.fromEndIndent,
    this.fromRadius,
    this.fromColor,
    super.key,
  }) : size = height,
       fromSize = fromHeight,
       isVertical = false;

  const MotionDivider.vertical({
    required this.motion,
    this.active = true,
    this.onAnimationStatusChanged,
    double? width,
    this.thickness,
    this.indent,
    this.endIndent,
    this.radius,
    this.color,
    double? fromWidth,
    this.fromThickness,
    this.fromIndent,
    this.fromEndIndent,
    this.fromRadius,
    this.fromColor,
    super.key,
  }) : size = width,
       fromSize = fromWidth,
       isVertical = true;

  @override
  State<MotionDivider> createState() => _MotionDividerState();
}

class _MotionDividerState extends State<MotionDivider> with TickerProviderStateMixin {
  SingleMotionController? size;
  SingleMotionController? thickness;
  SingleMotionController? indent;
  SingleMotionController? endIndent;
  MotionController<BorderRadiusGeometry>? radius;
  MotionController<Color>? color;

  void _onControllerTick() => setState(() {});

  @override
  void initState() {
    super.initState();
    if (widget.size != null) {
      initHeight(initial: true);
      if (widget.fromSize != null) {
        size!.animateTo(widget.size!);
      }
    }
    if (widget.thickness != null) {
      initThickness(initial: true);
      if (widget.fromThickness != null) {
        thickness!.animateTo(widget.thickness!);
      }
    }
    if (widget.indent != null) {
      initIndent(initial: true);
      if (widget.fromIndent != null) {
        indent!.animateTo(widget.indent!);
      }
    }
    if (widget.endIndent != null) {
      initEndIndent(initial: true);
      if (widget.fromEndIndent != null) {
        endIndent!.animateTo(widget.endIndent!);
      }
    }
    if (widget.radius != null) {
      initRadius(initial: true);
      if (widget.fromRadius != null) {
        radius!.animateTo(widget.radius!);
      }
    }
    if (widget.color != null) {
      initColor(initial: true);
      if (widget.fromColor != null) {
        color!.animateTo(widget.color!);
      }
    }
  }

  void initHeight({bool initial = false}) {
    size = SingleMotionController(
      vsync: this,
      motion: widget.motion,
      initialValue: initial ? (widget.fromSize ?? widget.size!) : widget.size!,
    )..addListener(_onControllerTick);
  }

  void initThickness({bool initial = false}) {
    thickness = SingleMotionController(
      vsync: this,
      motion: widget.motion,
      initialValue: initial ? (widget.fromThickness ?? widget.thickness!) : widget.thickness!,
    )..addListener(_onControllerTick);
  }

  void initIndent({bool initial = false}) {
    indent = SingleMotionController(
      vsync: this,
      motion: widget.motion,
      initialValue: initial ? (widget.fromIndent ?? widget.indent!) : widget.indent!,
    )..addListener(_onControllerTick);
  }

  void initEndIndent({bool initial = false}) {
    endIndent = SingleMotionController(
      vsync: this,
      motion: widget.motion,
      initialValue: initial ? (widget.fromEndIndent ?? widget.endIndent!) : widget.endIndent!,
    )..addListener(_onControllerTick);
  }

  void initRadius({bool initial = false}) {
    radius = MotionController(
      vsync: this,
      motion: widget.motion,
      converter: BorderRadiusMotionConverter(),
      initialValue: initial ? (widget.fromRadius ?? widget.radius!) : widget.radius!,
    )..addListener(_onControllerTick);
  }

  void initColor({bool initial = false}) {
    color = MotionController(
      vsync: this,
      motion: widget.motion,
      converter: ColorMotionConverter(),
      initialValue: initial ? (widget.fromColor ?? widget.color!) : widget.color!,
    )..addListener(_onControllerTick);
  }

  @override
  void didUpdateWidget(covariant MotionDivider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.size != oldWidget.size) {
      if (widget.size == null) {
        size!.dispose();
        size = null;
      } else if (oldWidget.size == null) {
        initHeight();
      } else {
        size!.animateTo(widget.size!);
      }
    }
    if (widget.thickness != oldWidget.thickness) {
      if (widget.thickness == null) {
        thickness!.dispose();
        thickness = null;
      } else if (oldWidget.thickness == null) {
        initThickness();
      } else {
        thickness!.animateTo(widget.thickness!);
      }
    }
    if (widget.indent != oldWidget.indent) {
      if (widget.indent == null) {
        indent!.dispose();
        indent = null;
      } else if (oldWidget.indent == null) {
        initIndent();
      } else {
        indent!.animateTo(widget.indent!);
      }
    }
    if (widget.endIndent != oldWidget.endIndent) {
      if (widget.endIndent == null) {
        endIndent!.dispose();
        endIndent = null;
      } else if (oldWidget.endIndent == null) {
        initEndIndent();
      } else {
        endIndent!.animateTo(widget.endIndent!);
      }
    }
    if (widget.radius != oldWidget.radius) {
      if (widget.radius == null) {
        radius!.dispose();
        radius = null;
      } else if (oldWidget.radius == null) {
        initRadius();
      } else {
        radius!.animateTo(widget.radius!);
      }
    }
    if (widget.color != oldWidget.color) {
      if (widget.color == null) {
        color!.dispose();
        color = null;
      } else if (oldWidget.color == null) {
        initColor();
      } else {
        color!.animateTo(widget.color!);
      }
    }
  }

  @override
  void dispose() {
    size?.dispose();
    thickness?.dispose();
    indent?.dispose();
    endIndent?.dispose();
    radius?.dispose();
    color?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVertical) {
      return VerticalDivider(
        width: size?.value,
        thickness: thickness?.value,
        indent: indent?.value,
        endIndent: endIndent?.value,
        radius: radius?.value,
        color: color?.value,
      );
    } else {
      return Divider(
        height: size?.value,
        thickness: thickness?.value,
        indent: indent?.value,
        endIndent: endIndent?.value,
        radius: radius?.value,
        color: color?.value,
      );
    }
  }
}
