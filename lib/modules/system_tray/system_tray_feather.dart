import "dart:async";

import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/system_tray/service/system_tray_service.dart";
import "package:waywing/modules/system_tray/system_tray_indicator.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/modules/system_tray/system_tray_popover.dart";
import "package:waywing/modules/system_tray/system_tray_tooltip.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/icons/text_icon.dart";

part "system_tray_feather.config.dart";

class SystemTrayFeather extends Feather<SystemTrayConfig> {
  SystemTrayFeather._();

  static void registerFeather(RegisterFeatherCallback<SystemTrayFeather, void> registerFeather) {
    registerFeather(
      "SystemTray",
      FeatherRegistration(
        constructor: SystemTrayFeather._,
        configBuilder: SystemTrayConfig.fromBlock,
        schemaBuilder: () => SystemTrayConfig.schema,
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

  @override
  late final ValueListenable<List<FeatherComponent>> components = DerivedValueNotifier(
    dependencies: [service.values.items],
    derive: () {
      final result = <FeatherComponent>[];
      for (final item in service.values.items.value) {
        result.add(
          // TODO: 2 implement reordering system tray icons
          // TODO: 2 implement overflow menu for hidden tray icons
          FeatherComponent(
            uniqueIdentifier: "$uniqueId - ${item.id}",
            buildIndicators: (context, popover) {
              return [
                SystemTrayIndicator(
                  service: service,
                  item: item,
                  popover: popover!,
                  configuration: config,
                ),
              ];
            },
            buildTooltip: (context) {
              return SystemTrayTooltip(service: service, item: item, configuration: config);
            },
            isPopoverEnabled: DummyValueNotifier(item.dbusmenu != null),
            buildPopover: (context) {
              return SystemTrayPopover(service: service, trayItem: item);
            },
          ),
        );
      }
      return result;
    },
  );
}

@Config()
mixin SystemTrayConfigBase on SystemTrayConfigI {
  /// Set the tray icon size
  static const __iconSize = DoubleNumberField(nullable: true);
  late final double iconSize = _iconSize ?? mainConfig.theme.iconSize;
  late final double iconSizeScaleFactor = iconSize / kDefaultFontSize;
  late final double iconSizeAdapted = iconSize * TextIcon.fontToIconSizeRatio;
}
