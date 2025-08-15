// ignore_for_file: prefer_single_quotes

import "package:args/args.dart";
import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/bar.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/logger.dart";
import "package:waywing/widgets/config_changes_watcher.dart";
import "package:waywing/util/window_utils.dart";
import "package:waywing/widgets/winged_popover_provider.dart";

void main(List<String> args) async {
  final cliparser = ArgParser()
    ..addFlag("dummy-layer", help: "Used internally only. Extra layer created just to add exclusive side size.");
  final results = cliparser.parse(args);
  final dummyLayer = results["dummy-layer"] as bool?;
  if (dummyLayer ?? false) {
    return;
  }

  initializeLogger();
  await reloadConfig(await getConfigurationString());
  WidgetsFlutterBinding.ensureInitialized();
  await setupMainWindow();

  mainLogger.log(Level.debug, "Done setting initial window config, running app...");
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return InputRegion.negative(
      child: ConfigChangeWatcher(
        builder: (context) {
          return MaterialApp(
            title: "WayWing",
            debugShowCheckedModeBanner: false,
            themeMode: config.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: config.seedColor,
                surface: config.surfaceColor,
              ),
              splashFactory: InkSparkle.splashFactory,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.dark,
                seedColor: config.seedColor,
                surface: config.surfaceColor,
              ),
              splashFactory: InkSparkle.splashFactory,
              dividerTheme: DividerThemeData(
                color: Colors.grey.shade400.withValues(alpha: 0.66),
              ),
            ),
            home: Scaffold(
              backgroundColor: Colors.transparent,
              body: WingedPopoverProvider(
                child: Stack(
                  children: [
                    Bar(),
                    // TODO: 2 implement Wings
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
