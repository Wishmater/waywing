import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/clock/clock_config.dart";
import "package:waywing/modules/clock/clock_indicator.dart";
import "package:waywing/modules/clock/clock_popover.dart";
import "package:waywing/modules/clock/clock_tooltip.dart";
import "package:waywing/modules/clock/time_service.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/util/derived_value_notifier.dart";

class ClockFeather extends Feather<ClockConfig> {
  late TimeService service;

  ClockFeather._();

  static void registerFeather(RegisterFeatherCallback<ClockFeather, ClockConfig> registerFeather) {
    registerFeather(
      "Clock",
      FeatherRegistration(
        constructor: ClockFeather._,
        schemaBuilder: () => ClockConfig.schema,
        configBuilder: ClockConfig.fromBlock,
      ),
    );
  }

  @override
  String get name => "Clock";

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<TimeService>(this);
  }

  @override
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([component]);

  late final component = FeatherComponent(
    buildIndicators: (context, popover) {
      return [
        ClockIndicator(config: config, service: service, popover: popover!),
      ];
    },
    buildTooltip: (context) {
      return ClockTooltip(config: config, service: service);
    },
    buildPopover: (context) {
      return ClockPopover(service: service);
    },
  );
}
