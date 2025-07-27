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
      return ValidatorTransform(parseColor(value));
    } catch (_) {
      return ValidatorError(MyValError("Failed to parse color value"));
    }
  }

  static Color parseColor(String colorString) {
    // Remove whitespace and convert to lowercase
    colorString = colorString.replaceAll(' ', '').toLowerCase();
    // Handle hex format
    if (colorString.startsWith('#') || RegExp(r'^[0-9a-fA-F]{6,8}$').hasMatch(colorString)) {
      String hex = colorString.replaceFirst('#', '');
      if (hex.length == 6) hex += 'ff'; // Add opaque alpha if not provided
      // ignore: prefer_interpolation_to_compose_strings
      if (hex.length == 3) hex = hex.split('').map((c) => c + c).join() + 'ff';
      return Color(int.parse('0xff$hex'));
    }
    // Handle rgb/rgba format
    RegExp rgbPattern = RegExp(r'^(rgb|rgba)\((\d+),(\d+),(\d+)(?:,([0-1]?\.?\d*))?\)$');
    var match = rgbPattern.firstMatch(colorString);
    if (match != null) {
      int r = int.parse(match.group(2)!);
      int g = int.parse(match.group(3)!);
      int b = int.parse(match.group(4)!);
      double a = match.group(5) != null ? double.parse(match.group(5)!) : 1.0;
      if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255 || a < 0 || a > 1) {
        throw FormatException('Invalid color values');
      }
      return Color.fromRGBO(r, g, b, a);
    }
    throw FormatException('Invalid color format');
  }
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

class MyValError extends ValidationError {
  String msg;
  MyValError(this.msg);
  @override
  String error() => msg;
  @override
  String toString() => 'ValidationError($msg)';
}
