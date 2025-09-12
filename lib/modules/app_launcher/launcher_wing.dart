import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:path/path.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/modules/app_launcher/service/application_service.dart";
import "package:waywing/modules/app_launcher/launcher_config.dart";
import "package:waywing/modules/app_launcher/launcher_widget.dart";
import "package:waywing/widgets/keyboard_focus.dart";

class AppLauncherWing extends Wing<LauncherConfig> {
  late ApplicationService service;

  AppLauncherWing._();

  static void registerFeather(RegisterFeatherCallback<AppLauncherWing, LauncherConfig> registerFeather) {
    registerFeather(
      "AppLauncher",
      FeatherRegistration<AppLauncherWing, LauncherConfig>(
        constructor: AppLauncherWing._,
        schemaBuilder: () => LauncherConfig.schema,
        configBuilder: LauncherConfig.fromMap,
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

  @override
  late final Map<String, WaywingRouteCallback>? actions = {
    "activate": (params) {
      showLauncher.value = true;
      return Response.ok();
    },
  };

  ValueNotifier<bool> showLauncher = ValueNotifier(false);

  @override
  Widget buildWing(EdgeInsets rerservedSpace) {
    return ValueListenableBuilder(
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
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: SizedBox(
                      width: config.width.toDouble(),
                      height: config.height.toDouble(),
                      child: FutureBuilder(
                        future: service.applications(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return LauncherWidget(
                              service: service,
                              applications: snapshot.data!,
                              config: config,
                              close: () => showLauncher.value = false,
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
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
