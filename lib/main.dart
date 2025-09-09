import "dart:io";

import "package:args/args.dart";
import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:path/path.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/theme.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/util/logger.dart";
import "package:waywing/widgets/config_changes_watcher.dart";
import "package:waywing/util/window_utils.dart";
import "package:waywing/widgets/keyboard_focus.dart";
import "package:waywing/widgets/text_icon.dart";
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
    mainConfig.socket ?? join(Platform.environment["XDG_RUNTIME_DIR"]!, "waywing", "waywing.sock"),
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
                      // TODO: 2 get icon theme from gsettings
                      size: TextIcon.getIconEffectiveSize(context).round(),
                    ),
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      body: CallbackShortcuts(
                        bindings: {
                          const SingleActivator(LogicalKeyboardKey.escape): () {
                            FocusScope.of(context).requestScopeFocus();
                          },
                        },
                        child: WingedPopoverProvider(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ...wingWidgets,
                              Positioned.fill(child: MouseFocusListener()),
                            ],
                          ),
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

class MouseFocusListener extends StatefulWidget {
  const MouseFocusListener({super.key});

  @override
  State<MouseFocusListener> createState() => _MouseFocusListenerState();
}

class _MouseFocusListenerState extends State<MouseFocusListener> {
  bool hasMouseFocus = false;
  bool hadFocus = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: false,
      onEnter: (_) {
        final focusScope = FocusScope.of(context, createDependency: false);
        if (hadFocus) {
          focusScope.requestFocus();
        } else {
          focusScope.requestScopeFocus();
        }
        hasMouseFocus = true;
      },
      onExit: (_) {
        final focusScope = FocusScope.of(context, createDependency: false);
        hadFocus = !focusScope.hasPrimaryFocus;
        if (focusScope.hasFocus) {
          focusScope.unfocus();
        }
        hasMouseFocus = false;
      },
    );
  }
}
