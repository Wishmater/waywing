import "package:config/config.dart";
import "package:config_gen/config_gen.dart";

part "clock_config.g.dart";

@Config()
mixin ClockConfigBase on ClockConfigI {
  static const _militar = BooleanField(defaultTo: false);
}
