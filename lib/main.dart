import 'package:fl_linux_window_manager/widgets/input_region.dart';
import 'package:flutter/material.dart';
import 'package:waywing/gui/bar/bar.dart';
import 'package:waywing/util/config.dart';
import 'package:waywing/gui/widgets/config_changes_watcher.dart';
import 'package:waywing/util/window_utils.dart';

void main() async {
  final configFuture = readConfig();

  WidgetsFlutterBinding.ensureInitialized();

  config = await configFuture; // everything below here needs config to already be loaded

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
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: config.seedColor),
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
