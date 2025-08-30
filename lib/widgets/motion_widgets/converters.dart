import "package:flutter/widgets.dart";
import "package:motor/motor.dart";

class EdgeInsetsConverter implements MotionConverter<EdgeInsets> {
  const EdgeInsetsConverter();

  @override
  EdgeInsets denormalize(List<double> v) => EdgeInsets.fromLTRB(v[0], v[1], v[2], v[3]);

  @override
  List<double> normalize(EdgeInsets v) => [v.left, v.top, v.right, v.bottom];
}

class BoxConstraintsConverter implements MotionConverter<BoxConstraints> {
  const BoxConstraintsConverter();

  @override
  BoxConstraints denormalize(List<double> v) =>
      BoxConstraints(minWidth: v[0], minHeight: v[1], maxWidth: v[2], maxHeight: v[3]);

  @override
  List<double> normalize(BoxConstraints v) => [v.minWidth, v.minHeight, v.maxWidth, v.maxHeight];
}

class Matrix4Converter implements MotionConverter<Matrix4> {
  const Matrix4Converter();

  @override
  Matrix4 denormalize(List<double> v) => Matrix4.fromList(v);

  @override
  List<double> normalize(Matrix4 v) => v.storage;
}
