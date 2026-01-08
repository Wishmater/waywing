import "package:config/config.dart";
import "package:config_gen/config_gen.dart";

part "launcher_config.config.dart";

@Config()
mixin LauncherConfigBase {
  static const _terminal = StringField(nullable: true);
  static const _iconSize = IntegerNumberField(nullable: true);
}
