import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/modules/aria2/aria2_service.dart";
import "package:waywing/modules/aria2/widgets/aria2_tooltip.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";

part "aria2_feather.config.dart";

class Aria2Feather extends Feather<Aria2Config> {
  late Aria2Service service;

  Aria2Feather._();

  static void registerFeather(RegisterFeatherCallback<Aria2Feather, Aria2Config> registerFeather) {
    registerFeather(
      "Aria2",
      FeatherRegistration(
        constructor: Aria2Feather._,
        schemaBuilder: () => Aria2Config.schema,
        configBuilder: Aria2Config.fromBlock,
      ),
    );
  }

  @override
  String get name => "Aria2";

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<Aria2Service>(this);
  }

  @override
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([component]);

  late final component = FeatherComponent(
    buildIndicators: (context, popover) {
      return [
        WingedButton(
          child: WingedIcon(
            flutterIcon: SymbolsVaried.cloud,
          ),
        ),
      ];
    },
    buildTooltip: (context) => Aria2Tooltip(feather: this),
    // buildPopover: (context) {
    //   return Aria2Popover(service: service);
    // },
  );
}

@Config()
mixin Aria2ConfigBase on Aria2ConfigI {
  static const _showUploadsSeparate = BooleanField(defaultTo: true);
}
