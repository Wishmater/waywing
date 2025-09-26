import "package:config/config.dart";
import "package:flutter/widgets.dart";

// Hack because Color class breaks codegen for some reason :)))
class MyColor extends Color {
  const MyColor(super.value);
  const MyColor.from({required super.alpha, required super.red, required super.green, required super.blue})
    : super.from();
  const MyColor.fromARGB(super.a, super.r, super.g, super.b) : super.fromARGB();
  const MyColor.fromRGBO(super.r, super.g, super.b, super.opacity) : super.fromRGBO();
}

class ColorField extends StringFieldBase<MyColor> {
  const ColorField({
    super.defaultTo,
    super.nullable,
  }) : super(validator: transform);

  static ValidatorResult<MyColor> transform(String value) {
    try {
      return ValidatorTransform(parseColor(value));
    } catch (_) {
      return ValidatorError(MyValError("Failed to parse color value"));
    }
  }

  static MyColor parseColor(String colorString) {
    // Remove whitespace and convert to lowercase
    colorString = colorString.replaceAll(" ", "").toLowerCase();
    // Handle hex format
    if (colorString.startsWith("#") || RegExp(r"^[0-9a-f]{6,8}$").hasMatch(colorString)) {
      String hex = colorString.replaceFirst("#", "");
      if (hex.length == 3) hex = hex.split("").map((c) => c + c).join(); // ???
      if (hex.length == 6) hex = "ff$hex"; // Add opaque alpha if not provided
      return MyColor(int.parse("0xff$hex"));
    }
    // Handle rgb/rgba format
    RegExp rgbPattern = RegExp(r"^(rgb|rgba)\((\d+),(\d+),(\d+)(?:,([0-1]?\.?\d*))?\)$");
    var match = rgbPattern.firstMatch(colorString);
    if (match != null) {
      int r = int.parse(match.group(2)!);
      int g = int.parse(match.group(3)!);
      int b = int.parse(match.group(4)!);
      double a = match.group(5) != null ? double.parse(match.group(5)!) : 1.0;
      if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255 || a < 0 || a > 1) {
        throw FormatException("Invalid color values");
      }
      return MyColor.fromRGBO(r, g, b, a);
    }
    throw FormatException("Invalid color format");
  }
}

// class CurveField extends StringFieldBase<Curve> {
//   const CurveField({
//     super.defaultTo,
//     super.nullable,
//   }) : super(validator: transform);
//
//   static ValidatorResult<Curve> transform(String value) {
//     return switch (value) {
//       "linear" => ValidatorTransform(Curves.linear),
//       "easeOutCubic" => ValidatorTransform(Curves.easeOutCubic),
//       // TODO: 2 add rest of the curves
//       _ => ValidatorError(MyValError("Unknown curve: $value")),
//     };
//   }
// }

class AlignmentField extends StringFieldBase<Alignment> {
  const AlignmentField({
    super.defaultTo,
    super.nullable,
  }) : super(validator: transform);

  static ValidatorResult<Alignment> transform(String value) {
    return switch (value) {
      "topLeft" => ValidatorTransform(Alignment.topLeft),
      "topCenter" => ValidatorTransform(Alignment.topCenter),
      "topRight" => ValidatorTransform(Alignment.topRight),
      "centerLeft" => ValidatorTransform(Alignment.centerLeft),
      "center" => ValidatorTransform(Alignment.center),
      "centerRight" => ValidatorTransform(Alignment.centerRight),
      "bottomLeft" => ValidatorTransform(Alignment.bottomLeft),
      "bottomCenter" => ValidatorTransform(Alignment.bottomCenter),
      "bottomRight" => ValidatorTransform(Alignment.bottomRight),
      _ => ValidatorError(MyValError("Unknown alignment: $value")),
    };
  }
}

class MyValError extends ValidationError {
  String msg;
  MyValError(this.msg);
  @override
  String error() => msg;
  @override
  String toString() => "ValidationError($msg)";
}
