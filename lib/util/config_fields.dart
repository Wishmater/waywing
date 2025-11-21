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

class AdaptativeColor {
  final Color light;
  final Color dark;

  const AdaptativeColor(this.light, this.dark);

  Color color(Brightness brightness) {
    return switch(brightness) {
      Brightness.dark => dark,
      Brightness.light => light,
    };
  }
}

class AdaptativeColorField extends UntypedField<AdaptativeColor> {
  const AdaptativeColorField({
    super.defaultTo,
    super.nullable,
  }) : super(validator: transform);

  static ValidatorResult<AdaptativeColor> transform(Value value) {
    switch (value) {
      case StringValue():
        final color = ColorField.parseColor(value.value);
        return ValidatorTransform(AdaptativeColor(color, color));
      case ListValue():
        if (value.value.length != 2) {
          return ValidatorError(
            MyValError(
              "AdaptiveColor exepect list to be two elements large but was of ${value.value.length}",
              value.position,
            ),
          );
        }
        for (final v in value.value) {
          if (v is! StringValue) {
            return ValidatorError(
              MyValError(
                "AdaptiveColor list values to be of type strings",
                v.position,
              ),
            );
          }
        }
        final colorL = ColorField.parseColor(value.value[0].toValue() as String);
        final colorD = ColorField.parseColor(value.value[1].toValue() as String);
        return ValidatorTransform(AdaptativeColor(colorL, colorD));
      case MapValue():
        final result = <String, MyColor?>{"light": null, "dark": null};

        for (final entry in value.value.entries) {
          if (entry.key is! StringValue) {
            return ValidatorError(
              MyValError("AdaptiveColor expect map to have keys of type string", entry.key.position),
            );
          }
          if (entry.value is! StringValue) {
            return ValidatorError(
              MyValError("AdaptiveColor expect map to have values of type string", entry.value.position),
            );
          }
          final key = entry.key.value as String;
          if (result.containsKey(key)) {
            try {
              result[key] = ColorField.parseColor(entry.value.value as String);
            } catch (_) {
              return ValidatorError(MyValError("Failed to parse color value", entry.value.position));
            }
          }
        }
        if (result["light"] == null) {
          return ValidatorError(MyValError("Missing key light", value.position));
        }
        if (result["dark"] == null) {
          return ValidatorError(MyValError("Missing key dark", value.position));
        }
        return ValidatorTransform(AdaptativeColor(result["light"]!, result["dark"]!));
      case DurationValue():
      case BooleanValue():
      case BlockValue():
      case NumberDoubleValue():
      case NumberIntegerValue():
        return ValidatorError(MyValError("Expected to be of type String | List | Map", value.position));
    }
  }
}

class ColorField extends StringFieldBase<MyColor> {
  const ColorField({
    super.defaultTo,
    super.nullable,
  }) : super(validator: transform);

  static ValidatorResult<MyColor> transform(String value, Position position) {
    try {
      return ValidatorTransform(parseColor(value));
    } catch (_) {
      return ValidatorError(MyValError("Failed to parse color value", position));
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

  static ValidatorResult<Alignment> transform(String value, Position position) {
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
      _ => ValidatorError(MyValError("Unknown alignment: $value", position)),
    };
  }
}

class MyValError extends ValidationError {
  String msg;
  Position position;

  @override
  List<Position> get positions => [position];

  MyValError(this.msg, this.position);

  @override
  String error() => msg;

  @override
  String toString() => "ValidationError($msg)";

  @override
  String help() => "";
}
