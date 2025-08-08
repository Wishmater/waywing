import "dart:async";

import "package:flutter/material.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/clock/clock_indicator.dart";
import "package:waywing/modules/clock/clock_popover.dart";
import "package:waywing/modules/clock/clock_tooltip.dart";
import "package:waywing/modules/clock/time_service.dart";
import "package:waywing/core/feather.dart";

class ClockFeather extends Feather {
  late Logger logger;
  late TimeService service;

  ClockFeather._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather("Clock", ClockFeather._);
  }

  @override
  String get name => "Clock";

  @override
  Future<void> init(BuildContext context, Logger logger) async {
    this.logger = logger;
    service = await serviceRegistry.requestService<TimeService>(this);
  }

  @override
  Future<void> dispose() async {
    await logger.destroy(); // TODO: 1 maybe the registry should do this so we don't have to ?
  }

  @override
  late final List<FeatherComponent> components = [clockComponent];

  late final clockComponent = FeatherComponent(
    buildIndicators: (context, popover, tooltip) {
      return [
        ClockIndicator(service: service, popover: popover!),
      ];
    },
    buildTooltip: (context) {
      return ClockTooltip(service: service);
    },
    buildPopover: (context) {
      return ClockPopover(service: service);
    },
  );
}
