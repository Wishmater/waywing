import "package:dartx/dartx.dart";
import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/widgets/shapes/external_rounded_corners_shape.dart";

class EdgeInsetsMotionConverter implements MotionConverter<EdgeInsets> {
  const EdgeInsetsMotionConverter();

  @override
  EdgeInsets denormalize(List<double> v) => EdgeInsets.fromLTRB(
    v[0].coerceAtLeast(0),
    v[1].coerceAtLeast(0),
    v[2].coerceAtLeast(0),
    v[3].coerceAtLeast(0),
  );

  @override
  List<double> normalize(EdgeInsets v) => [v.left, v.top, v.right, v.bottom];
}

class BoxConstraintsMotionConverter implements MotionConverter<BoxConstraints> {
  const BoxConstraintsMotionConverter();

  @override
  BoxConstraints denormalize(List<double> v) => BoxConstraints(
    minWidth: v[0].coerceAtLeast(0),
    minHeight: v[1].coerceAtLeast(0),
    maxWidth: v[2].coerceAtLeast(0),
    maxHeight: v[3].coerceAtLeast(0),
  );

  @override
  List<double> normalize(BoxConstraints v) => [v.minWidth, v.minHeight, v.maxWidth, v.maxHeight];
}

class Matrix4MotionConverter implements MotionConverter<Matrix4> {
  const Matrix4MotionConverter();

  @override
  Matrix4 denormalize(List<double> v) => Matrix4.fromList(v);

  @override
  List<double> normalize(Matrix4 v) => v.storage;
}

class BorderRadiusMotionConverter implements MotionConverter<BorderRadius> {
  const BorderRadiusMotionConverter();

  @override
  BorderRadius denormalize(List<double> v) {
    return BorderRadius.only(
      topLeft: Radius.elliptical(v[0], v[1]),
      topRight: Radius.elliptical(v[2], v[3]),
      bottomLeft: Radius.elliptical(v[4], v[5]),
      bottomRight: Radius.elliptical(v[6], v[7]),
    );
  }

  @override
  List<double> normalize(BorderRadius v) => [
    v.topLeft.x,
    v.topLeft.y,
    v.topRight.x,
    v.topRight.y,
    v.bottomLeft.x,
    v.bottomLeft.y,
    v.bottomRight.x,
    v.bottomRight.y,
  ];
}

class ColorMotionConverter implements MotionConverter<Color> {
  const ColorMotionConverter();

  @override
  Color denormalize(List<double> v) {
    return Color.fromARGB(v[0].round(), v[1].round(), v[2].round(), v[3].round());
  }

  @override
  List<double> normalize(Color v) => [v.a, v.r, v.g, v.b];
}

class RoundedRectangleBorderMotionConverter implements MotionConverter<RoundedRectangleBorder> {
  const RoundedRectangleBorderMotionConverter();

  @override
  RoundedRectangleBorder denormalize(List<double> v) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.elliptical(v[0], v[1]),
        topRight: Radius.elliptical(v[2], v[3]),
        bottomLeft: Radius.elliptical(v[4], v[5]),
        bottomRight: Radius.elliptical(v[6], v[7]),
      ),
      side: BorderSide(
        strokeAlign: v[8],
        width: v[9],
        style: BorderStyle.values.firstWhere((e) => e.index == v[10].round()),
        color: Color.fromARGB(v[11].round(), v[12].round(), v[13].round(), v[14].round()),
      ),
    );
  }

  @override
  List<double> normalize(RoundedRectangleBorder v) {
    final borderRadius = v.borderRadius as BorderRadius;
    return [
      borderRadius.topLeft.x,
      borderRadius.topLeft.y,
      borderRadius.topRight.x,
      borderRadius.topRight.y,
      borderRadius.bottomLeft.x,
      borderRadius.bottomLeft.y,
      borderRadius.bottomRight.x,
      borderRadius.bottomRight.y,
      v.side.strokeAlign,
      v.side.width,
      v.side.style.index.toDouble(),
      v.side.color.a,
      v.side.color.r,
      v.side.color.g,
      v.side.color.b,
    ];
  }
}

class ExternalRoundedCornersBorderMotionConverter implements MotionConverter<ExternalRoundedCornersBorder> {
  const ExternalRoundedCornersBorderMotionConverter();

  @override
  ExternalRoundedCornersBorder denormalize(List<double> v) {
    return ExternalRoundedCornersBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.elliptical(v[0], v[1]),
        topRight: Radius.elliptical(v[2], v[3]),
        bottomLeft: Radius.elliptical(v[4], v[5]),
        bottomRight: Radius.elliptical(v[6], v[7]),
      ),
      borderSide: GradientBorderSide(
        width: v[8],
        angle: v[9],
        // TODO: 1 this still crashes when changing the color count in config for some reason
        colors: List.generate(v[10].round(), (i) {
          final initialIndex = 11 + i * 4;
          if (initialIndex + 3 >= v.length) return Colors.transparent;
          return Color.from(
            alpha: v[initialIndex],
            red: v[initialIndex + 1],
            green: v[initialIndex + 2],
            blue: v[initialIndex + 3],
          );
        }),
      ),
    );
  }

  @override
  List<double> normalize(ExternalRoundedCornersBorder v) {
    return [
      v.borderRadius.topLeft.x,
      v.borderRadius.topLeft.y,
      v.borderRadius.topRight.x,
      v.borderRadius.topRight.y,
      v.borderRadius.bottomLeft.x,
      v.borderRadius.bottomLeft.y,
      v.borderRadius.bottomRight.x,
      v.borderRadius.bottomRight.y,
      v.borderSide.width,
      v.borderSide.angle,
      v.borderSide.colors.length.toDouble(),
      for (final e in v.borderSide.colors) ...[e.a, e.r, e.g, e.b],
    ];
  }
}
