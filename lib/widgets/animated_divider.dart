import "package:flutter/material.dart";

class AnimatedDivider extends ImplicitlyAnimatedWidget {
  final double? height;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final BorderRadiusGeometry? radius;
  final Color? color;

  const AnimatedDivider({
    required super.duration,
    super.curve,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
    this.radius,
    super.onEnd,
    super.key,
  });

  @override
  AnimatedWidgetBaseState<AnimatedDivider> createState() => _AnimatedDividerState();
}

class _AnimatedDividerState extends AnimatedWidgetBaseState<AnimatedDivider> {
  Tween<double>? _height;
  Tween<double>? _thickness;
  Tween<double>? _indent;
  Tween<double>? _endIndent;
  BorderRadiusTween? _radius;
  ColorTween? _color;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _height =
        visitor(
              _height,
              widget.height,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _thickness =
        visitor(
              _thickness,
              widget.thickness,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _indent =
        visitor(
              _indent,
              widget.indent,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _endIndent =
        visitor(
              _endIndent,
              widget.endIndent,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _radius =
        visitor(
              _radius,
              widget.radius,
              (dynamic value) => BorderRadiusTween(begin: value as BorderRadius),
            )
            as BorderRadiusTween?;
    _color =
        visitor(
              _color,
              widget.color,
              (dynamic value) => ColorTween(begin: value as Color),
            )
            as ColorTween?;
  }

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: _height?.evaluate(animation),
      thickness: _thickness?.evaluate(animation),
      indent: _indent?.evaluate(animation),
      endIndent: _endIndent?.evaluate(animation),
      radius: _radius?.evaluate(animation),
      color: _color?.evaluate(animation),
    );
  }
}
