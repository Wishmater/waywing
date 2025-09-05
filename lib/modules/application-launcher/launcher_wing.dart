import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/widgets/keyboard_focus.dart";

class AppLauncherWing extends Wing {
  AppLauncherWing._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather(
      "AppLauncher",
      FeatherRegistration(
        constructor: AppLauncherWing._,
        actions: {
          "activate": (params, feather) {
            final self = (feather as AppLauncherWing);
            self.showLauncher.value = true;
            return (200, "".codeUnits);
          },
        },
      ),
    );
  }

  @override
  String get name => "AppLauncher";

  ValueNotifier<bool> showLauncher = ValueNotifier(false);

  @override
  Widget buildWing(EdgeInsets rerservedSpace) {
    return Center(
      child: ValueListenableBuilder(
        valueListenable: showLauncher,
        builder: (contex, show, widget) {
          if (show) {
            return InputRegion(
              child: KeyboardFocus(
                mode: KeyboardFocusMode.exclusive,
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.escape): () {
                      showLauncher.value = false;
                    },
                  },
                  child: widget!,
                ),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        },
        child: Container(color: Colors.blue, height: 400, width: 400, child: TextFormField()),
      ),
    );
  }
}
