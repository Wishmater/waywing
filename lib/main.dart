import "dart:async";

import "package:args/args.dart";
import "package:dartx/dartx_io.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:hive_ce/hive.dart";
import "package:path/path.dart" as path;
import "package:waywing/core/config.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/theme.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/util/logger.dart";
import "package:waywing/util/window_utils.dart";
import "package:waywing/widgets/config_changes_watcher.dart";
import "package:waywing/widgets/input_region.dart";
import "package:waywing/widgets/keyboard_focus.dart";
import "package:waywing/widgets/winged_widgets/winged_popover_provider.dart";
import "package:xdg_icons/xdg_icons.dart";
import "package:filo_windowing/filo_windowing.dart";

late final FiloWindowingOwner owner;

void main(List<String> args) async {
  final cliparser = ArgParser()
    ..addOption(
      "config",
      abbr: "c",
      help: "Optional custom path to config file",
    );

  final results = cliparser.parse(args);
  customConfigPath = results["config"];

  runZonedGuarded(
    startApp,
    (dynamic error, StackTrace stackTrace) {
      mainLogger.error(
        "TOP LEVEL RUN ZONE GUARDED ERROR",
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

Future<void> startApp() async {
  await initializeLogger();
  await reloadConfig(await getConfigurationString(), path.normalize(path.absolute(getConfigurationFilePath())));

  WaywingServer.create(
    mainConfig.socket ?? path.join(mainRuntimeDir.path, "waywing.sock"),
    mainLogger.clone(properties: [LogType("WaywingServer")]),
  );
  WaywingServer.instance.init();

  owner = installFiloWindowing();
  windowManager = WaywingWindowManager(owner);

  mainLogger.debug("Done setting initial window config, running app...");

  FlutterError.onError = (details) {
    mainLogger.error(
      "${details.context?.toDescription()} ${details.summary.toDescription()}",
      error: details.exception,
      stackTrace: details.stack,
    );
    if (!kReleaseMode) {
      FlutterError.presentError(details);
    }
  };

  Hive.init(mainDataHomeDir.directory("hivedb").absolute.path);

  runWidget(App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  FiloLayerWindowController? _mainController;
  late KeyboardFocusService _keyboardService;

  @override
  void initState() {
    super.initState();
    windowManager.initialize();
    _syncMainController();
    windowManager.addListener(_syncMainController);
  }

  /// A controller change means the main window was recreated (for example after
  /// a monitor change), so the keyboard service must follow it.
  void _syncMainController() {
    final controller = windowManager.main;
    if (identical(controller, _mainController)) return;
    _mainController = controller;
    _keyboardService = KeyboardFocusService(controller);
  }

  @override
  void dispose() {
    windowManager.removeListener(_syncMainController);
    windowManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: windowManager,
      builder: (context, child) {
        final controller = windowManager.main;
        return ViewCollection(
          views: windowManager.buildViews(
            InputRegion.negative(
              viewId: controller.viewId,
              child: ConfigChangeWatcher(
                builder: (context) => _buildApp(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApp() {
    final waywingTheme = WaywingTheme(mainConfig.theme);
    return KeyboardFocusProvider(
      keyboardService: _keyboardService,
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
            return Theme(
              data: theme.copyWith(
                textTheme: theme.textTheme.apply(
                  fontSizeFactor: mainConfig.theme.fontSizeScaleFactor,
                ),
                iconTheme: theme.iconTheme.copyWith(
                  size: mainConfig.theme.iconSizeAdapted,
                ),
              ),
              child: XdgIconTheme(
                data: XdgIconThemeData(
                  size: mainConfig.theme.iconSizeAdapted.round(),
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
