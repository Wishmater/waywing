import 'package:fl_linux_window_manager/fl_linux_window_manager.dart';
import 'package:fl_linux_window_manager/models/layer.dart';
import 'package:fl_linux_window_manager/models/screen_edge.dart';
import 'package:waywing/util/config.dart';

const _delayDuration = Duration(milliseconds: 100);

Future<void> setupMainWindow() async {
  // we need to await an arbitrary time in between windowManager calls
  // to avoid race conditions, because Futures returned by the lib cant' be trusted

  print('Setting window title...');
  await FlLinuxWindowManager.instance.setTitle(title: 'WayWing');
  await Future.delayed(_delayDuration);

  print('Setting window transparency enabled...');
  await FlLinuxWindowManager.instance.enableTransparency();
  await Future.delayed(_delayDuration);

  print('Setting window layer...');
  await FlLinuxWindowManager.instance.setLayer(WindowLayer.overlay);
  await Future.delayed(_delayDuration);

  // TODO: 1 implement options for the user to set fixed monitor(s?)
  // TODO: 1 get monitor size
  print('Setting window size...');
  await FlLinuxWindowManager.instance.setSize(width: 1080, height: 1920);
  await Future.delayed(_delayDuration);

  return updateMainWindow();
}

Future<void> updateMainWindow() async {
  print('Setting window exclusive zone...');
  await FlLinuxWindowManager.instance.setLayerExclusiveZone(config.barWidth);
  await Future.delayed(_delayDuration);

  // calling setLayerAnchor before setSize breaks the app
  // calling setLayerAnchor before setLayerExclusiveZone breaks InputRegions
  print('Setting window layer anchors...');
  // we can't set all 4 anchors, because then we can't set exclusive zone
  await FlLinuxWindowManager.instance.setLayerAnchor(
    anchor: switch (config.barSide) {
      ScreenEdge.top => ScreenEdge.left.value | ScreenEdge.right.value | ScreenEdge.top.value,
      ScreenEdge.bottom => ScreenEdge.left.value | ScreenEdge.right.value | ScreenEdge.bottom.value,
      ScreenEdge.left => ScreenEdge.top.value | ScreenEdge.bottom.value | ScreenEdge.left.value,
      ScreenEdge.right => ScreenEdge.top.value | ScreenEdge.bottom.value | ScreenEdge.right.value,
    },
  );
  await Future.delayed(_delayDuration);
}
