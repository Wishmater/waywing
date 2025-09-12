import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_font_icons/flutter_font_icons.dart" show MaterialCommunityIcons;
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/kb_layout/caps_lock_feather.dart";
import "package:waywing/modules/kb_layout/kb_layout_service.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/text_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";

class KeyboardLayoutFeather extends Feather {
  late final KeyboardLayoutService service;

  KeyboardLayoutFeather._();

  static void registerFeather(RegisterFeatherCallback<KeyboardLayoutFeather, void> registerFeather) {
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
          KeyboardLayoutIndicator(service: service),
          // TODO: 2 implement tooltip showing full selected layout name and popover showing picker
        ];
      },
    ),
  ]);
}

class KeyboardLayoutIndicator extends StatelessWidget {
  final KeyboardLayoutService service;

  const KeyboardLayoutIndicator({
    required this.service,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: service.availableLayouts,
      builder: (context, availableLayouts, child) {
        return ValueListenableBuilder(
          valueListenable: service.layout,
          builder: (context, layout, _) {
            final theme = Theme.of(context);
            return SplashPulse(
              pulsing: availableLayouts.indexOf(layout) > 0,
              color: theme.colorScheme.error.withValues(alpha: 0.5),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // final isVertical = constraints.maxHeight > constraints.maxWidth;
                  final icon = WingedIcon(
                    flutterIcon: MaterialCommunityIcons.keyboard_variant,
                    iconNames: ["input-keyboard-cirtual-off", "input-keyboard"],
                    textIcon: "󰌓", // nf-md-keyboard_variant
                    size: theme.textTheme.bodyMedium!.fontSize! * 1.66,
                    color: theme.textTheme.bodyMedium!.color,
                    textIconBuilder: (context) => TextIcon(
                      text: "󰌓", // nf-md-keyboard_variant
                      alignment: Alignment(-0.66, 0),
                      size: theme.textTheme.bodyMedium!.fontSize! * 1.66,
                      color: theme.textTheme.bodyMedium!.color,
                    ),
                  );
                  final Widget content;
                  if (constraints.maxHeight >= 40) {
                    content = Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          layout,
                          style: theme.textTheme.bodyMedium!.copyWith(height: 0.1),
                        ),
                        Transform.translate(
                          offset: Offset(0, 4),
                          child: icon,
                        ),
                      ],
                    );
                  } else {
                    content = Row(
                      children: [
                        Transform.translate(
                          offset: Offset(0, 1),
                          child: icon,
                        ),
                        SizedBox(width: 2),
                        Text(layout, style: theme.textTheme.bodyMedium),
                      ],
                    );
                  }
                  return WingedButton(
                    // onTap: () {
                    //   popover.togglePopover();
                    // },
                    child: content,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
