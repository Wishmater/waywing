import "dart:async";

import "package:fl_linux_window_manager/fl_linux_window_manager.dart";
import "package:fl_linux_window_manager/models/layer.dart";
import "package:fl_linux_window_manager/models/screen_edge.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/logger.dart";

final _logger = mainLogger.clone(properties: [LogType("FlLinuxWindowManager")]);

// we need to await an arbitrary time in between windowManager calls
// to avoid race conditions, because Futures returned by the lib cant' be trusted
const _delayDuration = Duration(milliseconds: 100);

Future<void> setupMainWindow() async {
  _logger.log(Level.debug, "Setting main window title...");
  await FlLinuxWindowManager.instance.setTitle(title: "WayWings");
  await Future.delayed(_delayDuration);

  // // this doesn't seem to be necessary
  // logger.log(Level.debug, "Setting main window transparency enabled...");
  // await FlLinuxWindowManager.instance.enableTransparency();
  // await Future.delayed(_delayDuration);

  _logger.log(Level.debug, "Setting main window layer...");
  await FlLinuxWindowManager.instance.setLayer(WindowLayer.top);
  await Future.delayed(_delayDuration);

  // TODO: 1 ??? implement options for the user to set fixed monitor(s?) ??? each wing specifies its monitor ???

  _logger.log(Level.debug, "Setting main window anchors...");
  await FlLinuxWindowManager.instance.setLayerAnchor(
    anchor: ScreenEdge.values.map((e) => e.value).reduce((a, b) => a | b), // all anchors
  );
  await Future.delayed(_delayDuration);

  _logger.log(Level.debug, "Setting main window exclusive zone...");
  // setting -1 exclusiveSize makes this layer ignore exclusiveZones set by other layers
  await FlLinuxWindowManager.instance.setLayerExclusiveZone(-1);
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
    futures.add(updateEdgeWindow(side, config));
  }
  await Future.wait(futures);
}

Set<ScreenEdge> _existingDummyLayers = {};

Future<void> updateEdgeWindow(ScreenEdge side, MainConfig config) async {
  final exclusiveSize = config.getExclusiveSizeForSide(side)?.round() ?? 0;
  final windowId = "WayWings$side";

  // // removing a window crashes the app for some reason, so just init all at the start
  if (exclusiveSize == 0) {
    if (_existingDummyLayers.contains(side)) {
      _logger.log(Level.debug, "Closing window layer for side $side...");
      _existingDummyLayers.remove(side);
      await FlLinuxWindowManager.instance.closeWindow(
        windowId: windowId,
      );
      await Future.delayed(_delayDuration);
    }
    return;
  }

  bool create = !_existingDummyLayers.contains(side);
  if (create) {
    _logger.log(Level.debug, "Creating window layer for side $side...");
    _existingDummyLayers.add(side);
    await FlLinuxWindowManager.instance.createWindow(
      windowId: windowId,
      isLayer: true,
      initializeFlutter: false,
      args: ["--dummy-layer"],
      title: windowId,
      width: 0,
      height: 0,
    );
    await Future.delayed(_delayDuration);

    _logger.log(Level.debug, "Setting window layer for side $side...");
    await FlLinuxWindowManager.instance.setLayer(
      WindowLayer.background,
      windowId: windowId,
    );
    await Future.delayed(_delayDuration);
  }

  _logger.log(Level.debug, "Setting window layer exclusive zone = $exclusiveSize for side $side...");
  await FlLinuxWindowManager.instance.setLayerExclusiveZone(
    exclusiveSize,
    windowId: windowId,
  );
  await Future.delayed(_delayDuration);

  if (create) {
    _logger.log(Level.debug, "Setting window layer anchors for side $side...");
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
}
