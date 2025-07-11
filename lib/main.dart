import 'package:fl_linux_window_manager/widgets/input_region.dart';
import 'package:flutter/material.dart';
import 'package:waywing/gui/bar/bar.dart';
import 'package:waywing/util/config.dart';
import 'package:waywing/util/window_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupMainWindow();

  print('Done setting initial window config, running app...');
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return InputRegion.negative(
      child: Center(
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
