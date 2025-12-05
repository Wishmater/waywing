import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:path/path.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/app_launcher/service/application.dart";
import "package:waywing/modules/app_launcher/service/application_service.dart";
import "package:waywing/modules/app_launcher/launcher_config.dart";
import "package:waywing/modules/app_launcher/launcher_widget.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_popover_provider.dart";

class AppLauncherFeather extends Feather<LauncherConfig> {
  late ApplicationService service;

  AppLauncherFeather._();

  static void registerFeather(RegisterFeatherCallback<AppLauncherFeather, LauncherConfig> registerFeather) {
    registerFeather(
      "AppLauncher",
      FeatherRegistration<AppLauncherFeather, LauncherConfig>(
        constructor: AppLauncherFeather._,
        schemaBuilder: () => LauncherConfig.schema,
        configBuilder: LauncherConfig.fromBlock,
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
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([component]);

  late final component = FeatherComponent(
    buildIndicators: (context, popover) {
      return [
        WingedButton(
          onTap: (_, _) => popover!.togglePopover(),
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
        child: _Apps(service, config),
      );
    },
  );
}

class _Apps extends StatefulWidget {
  final ApplicationService service;
  final LauncherConfig config;

  const _Apps(this.service, this.config);

  @override
  State<_Apps> createState() => _AppsState();
}

class _AppsState extends State<_Apps> {
  late Future<List<Application>> applications;

  @override
  void initState() {
    super.initState();
    applications = widget.service.applications();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: applications,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LauncherWidget(
            service: widget.service,
            applications: snapshot.data!,
            config: widget.config,
            close: () {
              CloseRequestNotification().dispatch(context);
            },
          );
        } else {
          if (snapshot.hasError) {
            return ErrorWidget.withDetails(message:"${snapshot.error!}\n${snapshot.stackTrace}");
          }
          return const Center(
            child: SizedBox(
              height: 35,
              width: 35,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
