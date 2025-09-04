// ignore_for_file: prefer_single_quotes

import "package:args/args.dart";
import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/theme.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/util/logger.dart";
import "package:waywing/widgets/config_changes_watcher.dart";
import "package:waywing/util/window_utils.dart";
import "package:waywing/widgets/keyboard_focus.dart";
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

  initializeLogger();
  await reloadConfig(await getConfigurationString());
  WidgetsFlutterBinding.ensureInitialized();
  await setupMainWindow();

  mainLogger.log(Level.debug, "Done setting initial window config, running app...");
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return InputRegion.negative(
      child: ConfigChangeWatcher(
        builder: (context) {
          final themeConfig = ThemeConfig.fromMap(rawMainConfig["Theme"]);
          final waywingTheme = WaywingTheme(themeConfig);
          final wingWidgets = <Widget>[];
          for (int i = 0; i < mainConfig.wings.length; i++) {
            final wing = mainConfig.wings[i];
            final previousWings = mainConfig.wings.sublist(0, i);
            final reservedSpace = DerivedValueNotifier(
              dependencies: previousWings.map((e) => e.exclusiveSize).toList(),
              derive: () => previousWings.map((e) => e.exclusiveSize.value).fold(EdgeInsets.zero, (a, b) => a + b),
            );
            wingWidgets.add(
              FutureBuilder(
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
                      return wing.buildWing(rerservedSpace);
                    },
                  );
                },
              ),
            );
          }
          return KeyboardFocusProvider(
            keyboardService: KeyboardFocusService(),
            child: MaterialApp(
              title: "WayWing",
              debugShowCheckedModeBanner: false,
              themeMode: themeConfig.mode,
              theme: waywingTheme.themeLight,
              darkTheme: waywingTheme.themeDark,
              home: Builder(
                builder: (context) {
                  return XdgIconTheme(
                    data: XdgIconThemeData(
                      // TODO 2: get icon theme from gsettings
                      size: (Theme.of(context).iconTheme.size ?? kDefaultFontSize).round(),
                    ),
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      body: WingedPopoverProvider(
                        child: Stack(
                          children: wingWidgets,
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
