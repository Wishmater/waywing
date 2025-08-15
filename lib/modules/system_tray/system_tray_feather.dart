import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/system_tray/service/system_tray_service.dart";
import "package:waywing/modules/system_tray/system_tray_widget.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/util/derived_value_notifier.dart";

class SystemTrayFeather extends Feather {
  SystemTrayFeather._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather(
      "SystemTray",
      FeatherRegistration(
        constructor: SystemTrayFeather._,
      ),
    );
  }

  @override
  String get name => "SystemTray";

  late SystemTrayService service;

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<SystemTrayService>(this);
  }

  // TODO: 1 maybe make each system tray item a component ? (see NMFeather implementation)
  @override
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([systemTrayComponent]);

  late final systemTrayComponent = FeatherComponent(
    buildIndicators: (context, popover, tooltip) {
      return [
        SystemTrayWidget(service: service),
      ];
    },
  );
}
