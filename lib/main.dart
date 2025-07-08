import 'package:fl_linux_window_manager/fl_linux_window_manager.dart';
import 'package:fl_linux_window_manager/models/layer.dart';
import 'package:fl_linux_window_manager/models/screen_edge.dart';
import 'package:fl_linux_window_manager/widgets/input_region.dart';
import 'package:flutter/material.dart';

const barWidth = 100; // in pixels

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupMainWindow();

  print('Done setting initial window config, running app...');
  runApp(const App());
}

Future<void> setupMainWindow() async {
  // we need to await an arbitrary time in between windowManager calls
  // to avoid race conditions, because Futures returned by the lib cant' be trusted
  const delayDuration = Duration(milliseconds: 100);

  print('Setting window title...');
  await FlLinuxWindowManager.instance.setTitle(title: 'WayWing');
  await Future.delayed(delayDuration);

  print('Setting window transparency enabled...');
  await FlLinuxWindowManager.instance.enableTransparency();
  await Future.delayed(delayDuration);

  print('Setting window layer...');
  await FlLinuxWindowManager.instance.setLayer(WindowLayer.top);
  await Future.delayed(delayDuration);

  // TODO 1 implement options for the user to set fixed monitor
  // TODO 1 get monitor size
  print('Setting window size...');
  await FlLinuxWindowManager.instance.setSize(width: 800, height: 1920);
  await Future.delayed(delayDuration);

  print('Setting window exclusive zone...');
  await FlLinuxWindowManager.instance.setLayerExclusiveZone(barWidth);
  await Future.delayed(delayDuration);

  // calling setLayerAnchor before setSize breaks the app
  // calling setLayerAnchor before setLayerExclusiveZone breaks InputRegions
  print('Setting window layer anchors...');
  // TODO 2 implement option for user to set anchor side, including horizontal bar
  // we can't set all 4 anchors, because then we can't set exclusive zone
  await FlLinuxWindowManager.instance.setLayerAnchor(
    anchor: ScreenEdge.top.value | ScreenEdge.bottom.value | ScreenEdge.right.value,
  );
  await Future.delayed(delayDuration);
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
          theme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: Colors.deepPurple),
          ),
          debugShowCheckedModeBanner: false,
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

class Bar extends StatelessWidget {
  const Bar({super.key});

  @override
  Widget build(BuildContext context) {
    double devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    double barLogicalPixels = barWidth / devicePixelRatio;
    return Positioned(
      top: 200,
      bottom: 200,
      right: 0,
      width: barLogicalPixels,
      child: InputRegion(
        child: Material(
          color: Theme.of(context).canvasColor,
          child: InkWell(
            onTap: () {},
            child: Center(child: Text('WayWing')),
          ),
        ),
      ),
    );
  }
}
