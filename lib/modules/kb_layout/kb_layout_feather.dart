import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/services/compositors/compositor.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/icons/symbol_icon.dart";
import "package:waywing/widgets/icons/text_icon.dart";
import "package:waywing/widgets/splash_pulse.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";

class KeyboardLayoutFeather extends Feather {
  late final CompositorService service;

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
    service = await serviceRegistry.requestService<CompositorService>(this);
    if (!service.supportKeyboardLayouts) throw Exception("Keyboard layouts not supported by ${service.runtimeType}");
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
  final CompositorService service;

  const KeyboardLayoutIndicator({
    required this.service,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: service.keyboardLayouts,
      builder: (context, keyboardLayouts, child) {
        final theme = Theme.of(context);
        if (keyboardLayouts == null) return SizedBox.shrink();

        return SplashPulse(
          // TODO: 2 make this configurable
          pulsing: keyboardLayouts.index > 0,
          color: theme.colorScheme.error.withValues(alpha: 0.5),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // final isVertical = constraints.maxHeight > constraints.maxWidth;
              final icon = WingedIcon(
                flutterIcon: SymbolsVaried.keyboard,
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
                flutterBuilder: (context) => SymbolIcon(
                  SymbolsVaried.keyboard,
                  fill: 0,
                  opticalSize: 48,
                  grade: -25,
                  color: theme.textTheme.bodyMedium!.color,
                ),
              );
              final Widget content;
              if (constraints.maxHeight >= 40) {
                content = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      keyboardLayouts.current,
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
                    Text(keyboardLayouts.current, style: theme.textTheme.bodyMedium),
                  ],
                );
              }
              return WingedButton(
                onTapDown: (_) => service.switchLayoutNext(),
                child: content,
              );
            },
          ),
        );
      },
    );
  }
}
