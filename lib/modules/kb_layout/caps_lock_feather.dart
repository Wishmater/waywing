import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/modules/kb_layout/kb_layout_service.dart";
import "package:waywing/util/derived_value_notifier.dart";

class CapsLockFeather extends Feather {
  late KeyboardLayoutService service;

  CapsLockFeather._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather(
      "CapsLock",
      FeatherRegistration(
        constructor: CapsLockFeather._,
      ),
    );
  }

  @override
  String get name => "CapsLock";

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<KeyboardLayoutService>(this);
  }

  @override
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([
    FeatherComponent(
      isIndicatorVisible: service.capsLockActive,
      buildIndicators: (context, popover) {
        return [
          ColoredBox(
            color: Theme.of(context).colorScheme.error,
            child: Text("Caps"),
          ),
        ];
      },
    ),
  ]);
}
