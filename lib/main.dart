import "dart:io";

import "package:args/args.dart";
import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:path/path.dart" as path;
import "package:tronco/tronco.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/theme.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/util/logger.dart";
import "package:waywing/widgets/config_changes_watcher.dart";
import "package:waywing/util/window_utils.dart";
import "package:waywing/widgets/keyboard_focus.dart";
import "package:waywing/widgets/icons/text_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_popover_provider.dart";
import "package:xdg_icons/xdg_icons.dart";

void main(List<String> args) async {
  final cliparser = ArgParser()
    ..addFlag(
      "dummy-layer",
      hide: true,
      help: "Used internally only. Extra layer created just to add exclusive side size.",
    )
    ..addOption(
      "config",
      abbr: "c",
      help: "Optional custom path to config file",
    );
  final results = cliparser.parse(args);
  final dummyLayer = results["dummy-layer"] as bool?;
  if (dummyLayer ?? false) {
    return;
  }
  customConfigPath = results["config"];

  await initializeLogger();
  await reloadConfig(await getConfigurationString());

  WaywingServer.create(
    mainConfig.socket ?? path.join(Platform.environment["XDG_RUNTIME_DIR"]!, "waywing", "waywing.sock"),
    mainLogger.clone(properties: [LogType("WaywingServer")]),
  );
  WaywingServer.instance.init();

  WidgetsFlutterBinding.ensureInitialized();
  await setupMainWindow();

  mainLogger.debug("Done setting initial window config, running app...");

  FlutterError.onError = (details) {
    if (kReleaseMode) {
      mainLogger.error(
        "${details.context?.toDescription()} ${details.summary.toDescription()}",
        error: details.exception,
        stackTrace: details.stack,
      );
      exit(1);
    } else {
      FlutterError.presentError(details);
    }
  };
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return InputRegion.negative(
      child: ConfigChangeWatcher(
        builder: (context) {
          final waywingTheme = WaywingTheme(mainConfig.theme);
          return KeyboardFocusProvider(
            keyboardService: KeyboardFocusService(),
            child: MaterialApp(
              title: "WayWing",
              debugShowCheckedModeBanner: false,
              themeMode: mainConfig.theme.mode,
              theme: waywingTheme.themeLight,
              darkTheme: waywingTheme.themeDark,
              themeAnimationStyle: mainConfig.animationEnable ? null : AnimationStyle.noAnimation,
              themeAnimationDuration: Duration(milliseconds: 1000),
              themeAnimationCurve: Curves.easeOutCubic,
              home: Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  // The text/icon size configuration needs to happen here because the default
                  // text has all sizes in null... aparently is MaterialApp who fill the sizes
                  final defaultIconSize = TextIcon.getIconEffectiveSize(context, iconTheme: theme.iconTheme).round();
                  final iconSize = defaultIconSize * mainConfig.theme.iconSizeScaleFactor;
                  return Theme(
                    data: theme.copyWith(
                      textTheme: theme.textTheme.apply(
                        fontSizeFactor: mainConfig.theme.fontSizeScaleFactor,
                      ),
                      iconTheme: theme.iconTheme.copyWith(
                        size: iconSize,
                      ),
                    ),
                    child: XdgIconTheme(
                      data: XdgIconThemeData(
                        size: iconSize.round(),
                      ),
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        body: WingedPopoverProvider(
                          child: _WingsWidget(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WingsWidget extends StatefulWidget {
  const _WingsWidget();

  @override
  State<_WingsWidget> createState() => _WingsWidgetState();
}

class _WingsWidgetState extends State<_WingsWidget> {
  Map<Wing, GlobalKey> savedGlobalKeys = {};

  @override
  Widget build(BuildContext context) {
    final wingWidgets = <Widget>[];
    final Map<Wing, GlobalKey> globalKeys = {};
    for (int i = 0; i < mainConfig.wings.length; i++) {
      final wing = mainConfig.wings[i];
      final previousWings = mainConfig.wings.sublist(0, i);
      final reservedSpace = DerivedValueNotifier(
        dependencies: previousWings.map((e) => e.exclusiveSize).toList(),
        derive: () => previousWings.map((e) => e.exclusiveSize.value).fold(EdgeInsets.zero, (a, b) => a + b),
      );
      final globalKey = savedGlobalKeys[wing] ?? GlobalKey();
      globalKeys[wing] = globalKey;
      wingWidgets.add(
        FutureBuilder(
          key: globalKey,
          future: featherRegistry.awaitInitialization(wing),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // TODO: 1 Implement proper error handling in featherRegistry and remove this
              mainLogger.log(
                Level.error,
                "Error caught when initializing wing ${wing.name}",
                error: snapshot.error,
                stackTrace: snapshot.stackTrace,
              );
              return SizedBox.shrink();
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return SizedBox.shrink();
            }
            return ValueListenableBuilder(
              valueListenable: reservedSpace,
              builder: (context, rerservedSpace, _) {
                return wing.buildWing(context, rerservedSpace);
              },
            );
          },
        ),
      );
    }
    savedGlobalKeys = globalKeys;
    return Stack(
      fit: StackFit.expand,
      children: wingWidgets.reversed.toList(),
    );
  }
}
