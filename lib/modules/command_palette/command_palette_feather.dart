import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/command_palette/command_palette_widget.dart";
import "package:waywing/modules/command_palette/user_command_service.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_popover_provider.dart";

class CommandPaletteFeather extends Feather {
  CommandPaletteFeather._();

  static void registerFeather(RegisterFeatherCallback<CommandPaletteFeather, dynamic> registerFeather) {
    registerFeather(
      "CommandPalette",
      FeatherRegistration<CommandPaletteFeather, dynamic>(
        constructor: CommandPaletteFeather._,
      ),
    );
  }

  @override
  String get name => "CommandPalette";

  late UserCommandService commandService;

  @override
  Future<void> init(BuildContext context) async {
    await super.init(context);
    commandService = await serviceRegistry.requestService(this);
  }

  @override
  ValueListenable<List<FeatherComponent>> get components => DummyValueNotifier([component]);

  late final component = FeatherComponent(
    buildIndicators: (context, popover) {
      return [
        WingedButton(
          onTap: (_, _) => popover!.togglePopover(),
          child: WingedIcon(
            flutterIcon: SymbolsVaried.keyboard_command_key,
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
        child: FutureBuilder(
          future: commandService.commands(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CommandPaletteWidget(
                commands: snapshot.requireData,
                close: () {
                  CloseRequestNotification().dispatch(context);
                },
              );
            } else {
              return const Center(
                child: SizedBox(
                  height: 35,
                  width: 35,
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      );
    },
  );
}
