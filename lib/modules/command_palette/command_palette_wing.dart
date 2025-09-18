import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/widgets/keyboard_focus.dart";

class CommandPaletteWing extends Wing {
  CommandPaletteWing._();

  static void registerFeather(RegisterFeatherCallback<CommandPaletteWing, dynamic> registerFeather) {
    registerFeather(
      "CommandPalette",
      FeatherRegistration<CommandPaletteWing, dynamic>(
        constructor: CommandPaletteWing._,
      ),
    );
  }

  @override
  String get name => "CommandPalette";

  ValueNotifier<bool> showCommandPalette = ValueNotifier(false);

  @override
  late final Map<String, WaywingAction>? actions = {
    "activate": WaywingAction(
      "Show the command palette",
      (params) {
        showCommandPalette.value = true;
        return Response.ok();
      },
    ),
  };

  @override
  Widget buildWing(EdgeInsets rerservedSpace) {
    return ValueListenableBuilder(
      valueListenable: showCommandPalette,
      builder: (context, show, _) {
        if (!show) {
          return SizedBox.shrink();
        }
        return InputRegion(
          child: KeyboardFocus(
            mode: KeyboardFocusMode.exclusive,
            child:  CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape): () {
                  showCommandPalette.value = false;
                },
              },
              child: Center(
                child: Container(
                  color: Colors.blue,
                  width: 400,
                  height: 400,
                ),
              ),
            ),
          )
        );
      }
    );
  }

}
