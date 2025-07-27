import "package:config/config.dart";
import "package:flutter/widgets.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";

class ColorField extends StringFieldBase<Color> {
  const ColorField({
    super.defaultTo,
    super.nullable,
  }) : super(validator: transform);

  static ValidatorResult<Color> transform(String value) {
    try {
      // TODO: 3 also support rgb/rgba colors, and hex with alpha values
      return ValidatorTransform(_fromHex(value));
    } catch (_) {
      return ValidatorError(MyValError("Failed to parse color value"));
    }
  }
}

class MyValError extends ValidationError {
  String msg;
  MyValError(this.msg);
  @override
  String error() => msg;
}

Color _fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write("ff");
  buffer.write(hexString.replaceFirst("#", ""));
  return Color(int.parse(buffer.toString(), radix: 16));
}

class CurveField extends StringFieldBase<Curve> {
  const CurveField({
    super.defaultTo,
    super.nullable,
  }) : super(validator: transform);

  static ValidatorResult<Curve> transform(String value) {
    return switch (value) {
      "linear" => ValidatorTransform(Curves.linear),
      "easeOutCubic" => ValidatorTransform(Curves.easeOutCubic),
      // TODO: 2 add rest of the curves
      _ => ValidatorError(MyValError("Unknown curve: $value")),
    };
  }
}

class FeatherField extends StringFieldBase<Feather> {
  const FeatherField({
    super.defaultTo,
    super.nullable,
  }) : super(validator: transform);

  static ValidatorResult<Feather> transform(String value) {
    try {
      return ValidatorTransform(featherRegistry.getFeatherByName(value));
    } catch (_) {
      return ValidatorError(MyValError("Unknown feather: $value"));
    }
  }
}
