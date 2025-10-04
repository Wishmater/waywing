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
        configBuilder: BarConfig.fromBlock,
      ),
    );
  }

  @override
  String get name => "Bar";

  late List<Feather> startFeathers = config.start?.getFeatherInstances("$uniqueId.Start") ?? [];
  late List<Feather> centerFeathers = config.center?.getFeatherInstances("$uniqueId.Center") ?? [];
  late List<Feather> endFeathers = config.end?.getFeatherInstances("$uniqueId.End") ?? [];

  @override
  List<Feather> getFeathers() => [
    ...startFeathers,
    ...centerFeathers,
    ...endFeathers,
  ];

  void updateFeathers() {
    startFeathers = config.start?.getFeatherInstances("$uniqueId.Start") ?? [];
    centerFeathers = config.center?.getFeatherInstances("$uniqueId.Center") ?? [];
    endFeathers = config.end?.getFeatherInstances("$uniqueId.End") ?? [];
  }

  @override
  Widget buildWing(EdgeInsets rerservedSpace) {
    return Bar(wing: this, rerservedSpace: rerservedSpace);
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
