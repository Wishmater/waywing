import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/modules/command_palette/command_palette_widget.dart";
import "package:waywing/modules/command_palette/user_command_service.dart";
import "package:waywing/util/focus_grab/widget.dart";
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

  @override
  late final Map<String, WaywingAction>? actions = {
    "activate": WaywingAction(
      "Show the command palette",
      (params) {
        showCommandPalette.value = true;
        controller.grabFocus();
        return WaywingResponse.ok();
      },
    ),
  };

  late UserCommandService commandService;

  @override
  Future<void> init(BuildContext context) async {
    await super.init(context);
    commandService = await serviceRegistry.requestService(this);
  }

  ValueNotifier<bool> showCommandPalette = ValueNotifier(false);
  late final controller = FocusGrabController(
    onCleared: () {
      showCommandPalette.value = false;
    },
  );

  @override
  Widget buildWing(EdgeInsets rerservedSpace) {
    return ValueListenableBuilder(
      valueListenable: showCommandPalette,
      builder: (context, show, _) {
        if (!show) {
          return SizedBox.shrink();
        }
        return Center(
          child: InputRegion(
            child: KeyboardFocus(
              mode: KeyboardFocusMode.onDemand,
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.escape): () {
                    showCommandPalette.value = false;
                    controller.ungrabFocus();
                  },
                },
                child: FocusGrab(
                  controller: controller,
                  child: SizedBox(
                    width: 400,
                    height: 400,
                    child: FutureBuilder(
                      future: commandService.commands(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return CommandPaletteWidget(
                            commands: snapshot.data!,
                            close: () {
                              showCommandPalette.value = false;
                              controller.ungrabFocus();
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
