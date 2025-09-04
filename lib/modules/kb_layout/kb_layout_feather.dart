import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/modules/kb_layout/kb_layout_service.dart";
import "package:waywing/util/derived_value_notifier.dart";

class KeyboardLayoutFeather extends Feather {
  late KeyboardLayoutService service;

  KeyboardLayoutFeather._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather(
      "KeyboardLayout",
      FeatherRegistration(
        constructor: KeyboardLayoutFeather._,
      ),
    );
  }

  @override
  String get name => "KeyboardLayout";

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<KeyboardLayoutService>(this);
  }

  @override
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([
    FeatherComponent(
      buildIndicators: (context, popover) {
        return [
          ValueListenableBuilder(
            valueListenable: service.layout,
            builder: (context, layout, _) {
              print("Layout: $layout");
              print(service.availableLayouts.value);
              return Text(layout);
            },
          ),
        ];
      },
    ),
  ]);
}
