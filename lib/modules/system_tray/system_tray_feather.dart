import "dart:async";

import "package:flutter/material.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/system_tray/system_tray_service.dart";
import "package:waywing/modules/system_tray/system_tray_widget.dart";
import "package:waywing/core/feather.dart";

class SystemTrayFeather extends Feather {
  late Logger logger;
  SystemTrayFeather._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather("SystemTray", SystemTrayFeather._);
  }

  @override
  String get name => "SystemTray";

  late SystemTrayService service;

  @override
  Future<void> init(BuildContext context, Logger logger) async {
    this.logger = logger;
    service = await serviceRegistry.requestService<SystemTrayService>(this);
  }

  @override
  late final List<FeatherComponent> components = [systemTrayComponent];

  late final systemTrayComponent = FeatherComponent(
    buildIndicators: (context, popover, tooltip) {
      return [
        SystemTrayWidget(service: service),
      ];
    },
  );
}
