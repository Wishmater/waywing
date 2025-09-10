import "package:config/config.dart";
import "package:config_gen/config_gen.dart";

part "launcher_config.config.dart";

@Config()
mixin LauncherConfigBase {
  static const _width = IntegerNumberField(defaultTo: 400, validator: _heightWidth);
  static const _height = IntegerNumberField(defaultTo: 400, validator: _heightWidth);
  static const _showScrollBar = BooleanField(defaultTo: true);

  static ValidatorResult<int> _heightWidth(int value) {
    if (value < 200) {
      return ValidatorError(_RangeValidationError<int>(start: 200, end: -1 >>> 1, actual: value));
    }
    return ValidatorSuccess();
  }
}

class _RangeValidationError<T extends Comparable> extends ValidationError {
  final T start;
  final T end;
  final T actual;

  _RangeValidationError({required this.start, required this.end, required this.actual});

  @override
  String toString() {
    return "Range validation error. Expected to be between $start and $end but got $actual";
  }

  @override
  String error() {
    return toString();
  }
}
