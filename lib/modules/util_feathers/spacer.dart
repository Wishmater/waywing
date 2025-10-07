import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/util/derived_value_notifier.dart";

part "spacer.config.dart";

class SpacerFeather extends Feather<SpacerConfig> {
  SpacerFeather._();

  static void registerFeather(RegisterFeatherCallback<SpacerFeather, SpacerConfig> registerFeather) {
    registerFeather(
      "Spacer",
      FeatherRegistration(
        constructor: SpacerFeather._,
        schemaBuilder: () => SpacerConfig.schema,
        configBuilder: SpacerConfig.fromBlock,
      ),
    );
  }

  @override
  String get name => "Spacer";

  @override
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([component]);

  late final component = FeatherComponent(
    buildIndicators: (context, popover) {
      return [
        // TODO: 2 PERFORMANCE here, and everywhere that uses LayoutBuilder only to check isVertical,
        // implement a new widget that only rebuilds when that value changes
        LayoutBuilder(
          builder: (context, constraints) {
            final isVertical = constraints.maxHeight > constraints.maxWidth;
            if (isVertical) {
              return SizedBox(height: config.size);
            } else {
              return SizedBox(width: config.size);
            }
          },
        ),
      ];
    },
  );
}

@Config()
mixin SpacerConfigBase on SpacerConfigI {
  static const _size = DoubleNumberField(defaultTo: 12);
}
