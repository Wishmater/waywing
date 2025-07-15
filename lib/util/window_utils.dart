import 'dart:async';

import 'package:fl_linux_window_manager/fl_linux_window_manager.dart';
import 'package:fl_linux_window_manager/models/layer.dart';
import 'package:fl_linux_window_manager/models/screen_edge.dart';
import 'package:flutter/foundation.dart';
import 'package:waywing/core/config.dart';

const _delayDuration = Duration(milliseconds: 100);

Future<void> setupMainWindow() async {
  // we need to await an arbitrary time in between windowManager calls
  // to avoid race conditions, because Futures returned by the lib cant' be trusted

  print('Setting main window title...');
  await FlLinuxWindowManager.instance.setTitle(title: 'WayWings');
  await Future.delayed(_delayDuration);

  print('Setting main window transparency enabled...');
  await FlLinuxWindowManager.instance.enableTransparency();
  await Future.delayed(_delayDuration);

  print('Setting main window layer...');
  await FlLinuxWindowManager.instance.setLayer(WindowLayer.overlay);
  await Future.delayed(_delayDuration);

  // TODO: 1 implement options for the user to set fixed monitor(s?)

  // TODO: 2 get monitor info from the WindowManager library, instead of this hack, which always returns 1st monitor (not focuset one)
  print('Setting main window size...');
  final display = PlatformDispatcher.instance.displays.first;
  final physicalSize = display.size; // Physical pixels
  final scaleFactor = display.devicePixelRatio; // Pixels per logical pixel
  final resolution = (physicalSize.width ~/ scaleFactor, physicalSize.height ~/ scaleFactor);
  print('  Detected monitor resolution: $resolution with scale $scaleFactor');
  await FlLinuxWindowManager.instance.setSize(width: resolution.$1, height: resolution.$2);
  await Future.delayed(_delayDuration);

  print('Setting main window layer anchors...');
  await FlLinuxWindowManager.instance.setLayerAnchor(
    anchor: switch (config.barSide) {
      ScreenEdge.top => ScreenEdge.left.value | ScreenEdge.right.value | ScreenEdge.top.value,
      ScreenEdge.bottom => ScreenEdge.left.value | ScreenEdge.right.value | ScreenEdge.bottom.value,
      ScreenEdge.left => ScreenEdge.top.value | ScreenEdge.bottom.value | ScreenEdge.left.value,
      ScreenEdge.right => ScreenEdge.top.value | ScreenEdge.bottom.value | ScreenEdge.right.value,
    },
  );

  // print('Setting main window anchors...');
  // await FlLinuxWindowManager.instance.setLayerAnchor(
  //   anchor: ScreenEdge.values.map((e) => e.value).reduce((a, b) => a | b), // all anchors
  // );
  // await Future.delayed(_delayDuration);

  print('Setting main window exclusive zone...');
  await FlLinuxWindowManager.instance.setLayerExclusiveZone(
    -1, // setting -1 exclusiveSize makes this layer ignore exclusiveZones set by other layers
  );
  await Future.delayed(_delayDuration);

  return updateEdgeWindows();
}

Future<void>? _runningEdgeWindowsUpdate; // rudimentary safety mechanism to make sure updates don't run at the same time
Future<void>? _waitingEdgeWindowsUpdate; // if another update is already waiting, this one is just not necessary
Future<void> updateEdgeWindows() async {
  final completer = Completer();
  if (_runningEdgeWindowsUpdate != null) {
    if (_waitingEdgeWindowsUpdate != null) {
      return _waitingEdgeWindowsUpdate;
    }
    _waitingEdgeWindowsUpdate = completer.future;
    await _runningEdgeWindowsUpdate;
    _waitingEdgeWindowsUpdate = null;
  }
  _runningEdgeWindowsUpdate = completer.future;
  await _updateEdgeWindows();
  completer.complete();
  _runningEdgeWindowsUpdate = null;
}

Future<void> _updateEdgeWindows() async {
  final futures = <Future>[];
  for (final side in ScreenEdge.values) {
    updateEdgeWindow(side);
  }
  await Future.wait(futures);
}

Set<ScreenEdge> _existingExclusiveScreenEdgeWindows = {};

Future<void> updateEdgeWindow(ScreenEdge side) async {
  final exclusiveSize = config.getExclusiveSizeForSide(side)?.round() ?? 0;
  final windowId = 'WayWings$side';

  if (exclusiveSize == 0) {
    if (_existingExclusiveScreenEdgeWindows.contains(side)) {
      print('Closing window layer for side $side...');
      _existingExclusiveScreenEdgeWindows.remove(side);
      await FlLinuxWindowManager.instance.closeWindow(
        windowId: windowId,
      );
      await Future.delayed(_delayDuration);
    }
    return;
  }

  if (!_existingExclusiveScreenEdgeWindows.contains(side)) {
    print('Creating window layer for side $side...');
    _existingExclusiveScreenEdgeWindows.add(side);
    await FlLinuxWindowManager.instance.createWindow(
      windowId: windowId,
      isLayer: true,
      args: ['--dummy-layer'],
      title: windowId,
      width: 0,
      height: 0,
    );
    await Future.delayed(_delayDuration);
  }

  print('Setting window layer for side $side...');
  await FlLinuxWindowManager.instance.setLayer(
    WindowLayer.background,
    windowId: windowId,
  );
  await Future.delayed(_delayDuration);

  print('Setting window exclusive zone for side $side...');
  await FlLinuxWindowManager.instance.setLayerExclusiveZone(
    exclusiveSize,
    windowId: windowId,
  );
  await Future.delayed(_delayDuration);

  print('Setting window layer anchors for side $side...');
  await FlLinuxWindowManager.instance.setLayerAnchor(
    windowId: windowId,
    anchor: switch (side) {
      ScreenEdge.top => ScreenEdge.left.value | ScreenEdge.right.value | ScreenEdge.top.value,
      ScreenEdge.bottom => ScreenEdge.left.value | ScreenEdge.right.value | ScreenEdge.bottom.value,
      ScreenEdge.left => ScreenEdge.top.value | ScreenEdge.bottom.value | ScreenEdge.left.value,
      ScreenEdge.right => ScreenEdge.top.value | ScreenEdge.bottom.value | ScreenEdge.right.value,
    },
  );
  await Future.delayed(_delayDuration);
}
