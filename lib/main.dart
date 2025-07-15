import 'package:fl_linux_window_manager/widgets/input_region.dart';
import 'package:flutter/material.dart';
import 'package:waywing/core/bar.dart';
import 'package:waywing/core/config.dart';
import 'package:waywing/widgets/config_changes_watcher.dart';
import 'package:waywing/util/window_utils.dart';

void main() async {
  final configFuture = reloadConfig();

  WidgetsFlutterBinding.ensureInitialized();

  await configFuture; // everything below here needs config to already be loaded

  await setupMainWindow();

  print('Done setting initial window config, running app...');
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return InputRegion.negative(
      child: ConfigChangeWatcher(
        child: MaterialApp(
          title: 'WayWing',
          debugShowCheckedModeBanner: false,
          themeMode: config.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: config.seedColor),
            splashFactory: InkSparkle.splashFactory,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: config.seedColor),
            splashFactory: InkSparkle.splashFactory,
          ),
          home: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Bar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
