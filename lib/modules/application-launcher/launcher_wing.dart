import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:path/path.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/modules/application-launcher/application_service.dart";
import "package:waywing/modules/application-launcher/launcher_widget.dart";
import "package:waywing/widgets/keyboard_focus.dart";

class AppLauncherWing extends Wing {
  late ApplicationService service;

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
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<ApplicationService>(this);
    await service.initDatbase(join(dataDir.absolute.path, "db"));
  }

  @override
  String get name => "AppLauncher";

  ValueNotifier<bool> showLauncher = ValueNotifier(false);

  @override
  Widget buildWing(EdgeInsets rerservedSpace) {
    return Center(
      child: SizedBox(
        width: 400, // TODO 1: get value from configuration
        height: 400, // TODO 1: get value from configuration
        child: ValueListenableBuilder(
          valueListenable: showLauncher,
          builder: (contex, show, _) {
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
                    child: FutureBuilder(
                      future: service.applications(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return LauncherWidget(service: service, applications: snapshot.data!);
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
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
