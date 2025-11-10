import "dart:async";

import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/modules/hyprland/hyprland_service.dart";
import "package:waywing/modules/kb_layout/caps_lock_feather.dart";
import "package:waywing/modules/kb_layout/kb_layout_service.dart";
import "package:waywing/util/derived_value_notifier.dart";

part "num_lock_feather.config.dart";

class NumLockFeather extends Feather<NumLockConfig> {
  late KeyboardLayoutService service;

  NumLockFeather._();

  static void registerFeather(RegisterFeatherCallback<NumLockFeather, NumLockConfig> registerFeather) {
    registerFeather(
      "NumLock",
      FeatherRegistration(
        constructor: NumLockFeather._,
        configBuilder: NumLockConfig.fromBlock,
        schemaBuilder: () => NumLockConfig.schema,
      ),
    );
  }

  @override
  String get name => "NumLock";

  @override
  Future<void> init(BuildContext context) async {
    await serviceRegistry.requestService<HyprlandService>(this);
    service = await serviceRegistry.requestService<KeyboardLayoutService>(this);
    service.requestNumCapsPull();
  }

  late final isIndicatorEnabled = DerivedValueNotifier(
    dependencies: [service.numsLockActive],
    derive: () => config.reserveSpace ? true : !service.numsLockActive.value,
  );

  @override
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([
    FeatherComponent(
      isIndicatorEnabled: isIndicatorEnabled,
      buildIndicators: (context, popover) {
        return [
          ValueListenableBuilder(
            valueListenable: service.numsLockActive,
            builder: (context, numsLockActive, child) {
              return ErrorStateIndicator(
                name: "num lock",
                value: "OFF",
                visible: !config.reserveSpace ? true : !numsLockActive,
              );
            },
          ),
        ];
      },
    ),
  ]);

  @override
  void onConfigUpdated(NumLockConfig oldConfig) {
    if (oldConfig.reserveSpace != config.reserveSpace) {
      isIndicatorEnabled.value = isIndicatorEnabled.derive();
    }
  }
}

@Config()
mixin NumLockConfigBase on NumLockConfigI {
  static const _reserveSpace = BooleanField(defaultTo: false);
}
