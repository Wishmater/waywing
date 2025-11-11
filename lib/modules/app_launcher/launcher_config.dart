import "package:config/config.dart";
import "package:config_gen/config_gen.dart";

part "launcher_config.config.dart";

@Config()
mixin LauncherConfigBase {
  static const _iconSize = IntegerNumberField(nullable: true, validator: _mustBePositive);
  static const _showScrollBar = BooleanField(defaultTo: true);

  static ValidatorResult<int> _mustBePositive(int value) {
    if (value < 0) {
      return ValidatorError(_RangeValidationError<int>(start: 0, end: -1 >>> 1, actual: value));
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
    return error();
  }

  @override
  String error() {
    return "Range validation error. Expected to be between $start and $end but got $actual";
  }

  @override
  String help() {
    return "Make sure the value is between $start and $end";
  }
}
