import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_font_icons/flutter_font_icons.dart" show MaterialCommunityIcons;
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/kb_layout/kb_layout_service.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";

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
              return LayoutBuilder(
                builder: (context, constraints) {
                  // final isVertical = constraints.maxHeight > constraints.maxWidth;
                  return WingedButton(
                    // onTap: () {
                    //   popover.togglePopover();
                    // },
                    child: Column(
                      children: [
                        Icon(
                          MaterialCommunityIcons.keyboard_variant,
                          size: Theme.of(context).textTheme.bodyMedium!.fontSize,
                        ),
                        Text(layout),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ];
      },
    ),
  ]);
}
