import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/modules/kb_layout/kb_layout_service.dart";
import "package:waywing/util/derived_value_notifier.dart";

class NumLockFeather extends Feather {
  late KeyboardLayoutService service;

  NumLockFeather._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather(
      "NumLock",
      FeatherRegistration(
        constructor: NumLockFeather._,
      ),
    );
  }

  @override
  String get name => "NumLock";

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<KeyboardLayoutService>(this);
  }

  @override
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([
    FeatherComponent(
      isIndicatorVisible: DerivedValueNotifier(
        dependencies: [service.numsLockActive],
        derive: () => !service.numsLockActive.value,
      ),
      buildIndicators: (context, popover) {
        return [
          ColoredBox(
            color: Theme.of(context).colorScheme.error,
            child: Text("Num"),
          ),
        ];
      },
    ),
  ]);
}
