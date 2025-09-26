import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/modules/bar/bar_config.dart";
import "package:waywing/modules/bar/bar_widget.dart";

class BarWing extends Wing<BarConfig> {
  BarWing._();

  static void registerFeather(RegisterFeatherCallback<BarWing, BarConfig> registerFeather) {
    registerFeather(
      "Bar",
      FeatherRegistration(
        constructor: BarWing._,
        schemaBuilder: () => BarConfig.schema,
        configBuilder: BarConfig.fromMap,
      ),
    );
  }

  @override
  String get name => "Bar";

  late List<Feather> startFeathers;
  late List<Feather> centerFeathers;
  late List<Feather> endFeathers;

  @override
  List<Feather> getFeathers() => [
    ...startFeathers,
    ...centerFeathers,
    ...endFeathers,
  ];

  @override
  Future<void> init(BuildContext context) async {
    updateFeathers();
  }

  void updateFeathers() {
    // TODO: 1 differentiate bar index
    startFeathers = config.start?.getFeatherInstances("Bar[0].Start") ?? [];
    centerFeathers = config.center?.getFeatherInstances("Bar[0].Center") ?? [];
    endFeathers = config.end?.getFeatherInstances("Bar[0].End") ?? [];
  }

  @override
  Widget buildWing(EdgeInsets rerservedSpace) {
    // TODO: 1 apply rerservedSpace in Bar
    return Bar(
      startFeathers: startFeathers,
      centerFeathers: centerFeathers,
      endFeathers: endFeathers,
      config: config,
      logger: logger,
    );
  }

  @override
  ValueListenable<EdgeInsets> get exclusiveSize => _exclusiveSize;
  late final ValueNotifier<EdgeInsets> _exclusiveSize = ValueNotifier(_getExclusiveSize());
  _getExclusiveSize() => EdgeInsets.fromLTRB(
    config.exclusiveSizeLeft,
    config.exclusiveSizeTop,
    config.exclusiveSizeRight,
    config.exclusiveSizeBottom,
  );

  @override
  onConfigUpdated(BarConfig oldConfig) {
    _exclusiveSize.value = _getExclusiveSize();
    updateFeathers();
  }
}
