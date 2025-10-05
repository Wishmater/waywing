import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/util/derived_value_notifier.dart";

part "divider.config.dart";

class DividerFeather extends Feather<DividerConfig> {
  DividerFeather._();

  static void registerFeather(RegisterFeatherCallback<DividerFeather, DividerConfig> registerFeather) {
    registerFeather(
      "Divider",
      FeatherRegistration(
        constructor: DividerFeather._,
        schemaBuilder: () => DividerConfig.schema,
        configBuilder: DividerConfig.fromBlock,
      ),
    );
  }

  @override
  String get name => "Divider";

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
              return Divider(
                height: config.size,
                thickness: config.thickness,
                indent: config.indent,
                endIndent: config.indent,
                radius: BorderRadius.all(Radius.circular(config.thickness / 2)),
              );
            } else {
              return VerticalDivider(
                width: config.size,
                thickness: config.thickness,
                indent: config.indent,
                endIndent: config.indent,
                radius: BorderRadius.all(Radius.circular(config.thickness / 2)),
              );
            }
          },
        ),
      ];
    },
  );
}

@Config()
mixin DividerConfigBase on DividerConfigI {
  static const _size = DoubleNumberField(defaultTo: 12);
  static const _thickness = DoubleNumberField(defaultTo: 2);
  static const _indent = DoubleNumberField(defaultTo: 6);
}
