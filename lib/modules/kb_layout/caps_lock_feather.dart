import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:motor/motor.dart";
import "package:waywing/core/config.dart";
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
      buildIndicators: (context, popover) {
        return [
          LayoutBuilder(
            builder: (context, constraints) {
              final isVertical = constraints.maxHeight > constraints.maxWidth;
              return ValueListenableBuilder(
                valueListenable: service.capsLockActive,
                builder: (context, active, child) {
                  return SingleMotionBuilder(
                    value: active ? 1 : 0,
                    motion: mainConfig.motions.expressive.spatial.fast,
                    child: child,
                    builder: (context, value, child) {
                      return ClipRect(
                        child: Align(
                          alignment: isVertical ? AlignmentDirectional(-1, 0) : AlignmentDirectional(0, -1),
                          heightFactor: isVertical ? value : 1,
                          widthFactor: !isVertical ? value : 1,
                          child: child,
                        ),
                      );
                    },
                  );
                },
                child: ColoredBox(color: Theme.of(context).colorScheme.error),
              );
            },
          ),
        ];
      },
    ),
  ]);
}
