import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:flutter/foundation.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/bitwarden/bitwarden_popover.dart";
import "package:waywing/modules/bitwarden/bitwarden_service.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_popover_provider.dart";

class BitwardenLauncherFeather extends Feather {
  late BitwardenService service;

  BitwardenLauncherFeather._();

  static void registerFeather(RegisterFeatherCallback<BitwardenLauncherFeather, dynamic> registerFeather) {
    registerFeather(
      "BitwardenLauncher",
      FeatherRegistration<BitwardenLauncherFeather, dynamic>(
        constructor: BitwardenLauncherFeather._,
      ),
    );
  }

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<BitwardenService>(this);
  }

  @override
  String get name => "BitwardenLauncher";

  @override
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([component]);

  late final component = FeatherComponent(
    buildIndicators: (context, popover) {
      return [
        WingedButton(
          onTap: () => popover!.togglePopover(),
          child: WingedIcon(
            // iconNames: [],
            // textIcon: "",
            flutterIcon: SymbolsVaried.apps,
          ),
        ),
      ];
    },
    buildPopover: (context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 500,
          maxWidth: 256 + 128,
        ),
        child: BitwardenPopover(
          service: service,
          close: () {
            CloseRequestNotification().dispatch(context);
          },
        ),
      );
    },
  );
}
