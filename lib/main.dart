import 'package:fl_linux_window_manager/fl_linux_window_manager.dart';
import 'package:fl_linux_window_manager/models/layer.dart';
import 'package:fl_linux_window_manager/models/screen_edge.dart';
import 'package:fl_linux_window_manager/widgets/input_region.dart';
import 'package:flutter/material.dart';

const barWidth = 100; // in pixels

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  print('Setting window title...');
  FlLinuxWindowManager.instance.setTitle(title: 'WayWing');
  print('Setting window transparency enabled...');
  FlLinuxWindowManager.instance.enableTransparency();
  print('Setting window layer...');
  FlLinuxWindowManager.instance.setLayer(WindowLayer.top);
  // we can't set all 4 anchors, because then we can't set exclusive zone
  print('Setting window layer anchors...');
  FlLinuxWindowManager.instance.setLayerAnchor(
    anchor: ScreenEdge.top.value | ScreenEdge.bottom.value | ScreenEdge.right.value,
  );
  // TODO 2 implement option for horizontal bar
  // TODO 1 get monitor size
  print('Setting window size...');
  FlLinuxWindowManager.instance.setSize(width: 800, height: 1920);
  print('Setting window exclusive zone...');
  FlLinuxWindowManager.instance.setLayerExclusiveZone(barWidth);
  // TODO 1 implement options for the user to set fixed monitor

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
          theme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: Colors.deepPurple),
          ),
          home: Scaffold(backgroundColor: Colors.transparent, body: Stack(children: [Bar()])),
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
          child: InkWell(onTap: () {}, child: Center(child: Text('WayWing'))),
        ),
      ),
    );
  }
}
